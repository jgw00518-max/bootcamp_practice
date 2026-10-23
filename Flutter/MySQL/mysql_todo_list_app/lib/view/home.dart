import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;
import 'package:mysql_todo_list_app/data/todo_api.dart';
import 'package:mysql_todo_list_app/model/todo_item.dart';
import 'package:mysql_todo_list_app/view/delete_list.dart';

class Home extends StatefulWidget {
  const Home({super.key, this.client, this.baseUrl = TodoApi.defaultBaseUrl});

  final http.Client? client;
  final String baseUrl;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late final TodoApi _api;
  List<TodoItem> _todos = const [];
  bool _isLoading = true;
  String? _errorMessage;

  /// 화면이 시작되면 API 연결과 첫 목록 조회를 준비한다.
  @override
  void initState() {
    super.initState();
    _api = TodoApi(client: widget.client, baseUrl: widget.baseUrl);
    _loadTodos();
  }

  /// 현재 Todo 목록을 다시 받아 로딩, 오류, 성공 상태를 갱신한다.
  Future<void> _loadTodos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final todos = await _api.fetchTodos();
      if (!mounted) return;

      setState(() {
        _todos = todos;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  /// 제목 입력 Dialog를 열고 유효한 제목을 서버에 추가한다.
  Future<void> _showAddDialog() async {
    var inputTitle = '';
    String? validationMessage;

    final title = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Todo List'),
          content: TextField(
            key: const Key('todoTitleField'),
            autofocus: true,
            decoration: InputDecoration(
              labelText: '추가할 내용',
              errorText: validationMessage,
            ),
            textInputAction: TextInputAction.done,
            onChanged: (value) => inputTitle = value,
            onSubmitted: (_) => _submitDialogTitle(
              context,
              inputTitle,
              (message) => setDialogState(() => validationMessage = message),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              key: const Key('addTodoButton'),
              onPressed: () => _submitDialogTitle(
                context,
                inputTitle,
                (message) => setDialogState(() => validationMessage = message),
              ),
              child: const Text('추가하기'),
            ),
          ],
        ),
      ),
    );

    if (title == null || !mounted) return;

    try {
      await _api.addTodo(title);
      await _loadTodos();
    } catch (error) {
      if (!mounted) return;
      _showMessage(error.toString());
    }
  }

  /// 공백 제목은 Dialog에 남기고 유효한 제목만 반환한다.
  void _submitDialogTitle(
    BuildContext dialogContext,
    String inputTitle,
    ValueChanged<String?> setValidationMessage,
  ) {
    final title = inputTitle.trim();
    if (title.isEmpty) {
      setValidationMessage('내용을 입력해 주세요.');
      return;
    }

    Navigator.pop(dialogContext, title);
  }

  /// 스와이프 액션에서 선택한 Todo를 삭제하고 목록을 즉시 갱신한다.
  Future<void> _deleteTodo(TodoItem todo) async {
    try {
      await _api.deleteTodo(todo.seq);
      if (!mounted) return;

      setState(() {
        _todos = _todos.where((item) => item.seq != todo.seq).toList();
      });
      _showMessage('삭제 목록으로 이동했습니다.');
    } catch (error) {
      if (!mounted) return;
      _showMessage(error.toString());
    }
  }

  /// 삭제 목록 화면에도 같은 테스트용 Client와 서버 주소를 전달한다.
  Future<void> _openDeletedTodos() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DeleteList(client: widget.client, baseUrl: widget.baseUrl),
      ),
    );

    if (mounted) {
      await _loadTodos();
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _api.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo Lists'),
        actions: [
          IconButton(
            key: const Key('openDeletedTodosButton'),
            tooltip: '삭제 목록',
            onPressed: _openDeletedTodos,
            icon: const Icon(Icons.delete_outline),
          ),
          IconButton(
            key: const Key('openAddTodoButton'),
            tooltip: 'Todo 추가',
            onPressed: _showAddDialog,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  /// API 상태에 따라 로딩, 오류, 빈 목록, Todo 목록을 구분해 표시한다.
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _MessageState(
        icon: Icons.cloud_off,
        message: _errorMessage!,
        actionLabel: '다시 시도',
        onAction: _loadTodos,
      );
    }

    if (_todos.isEmpty) {
      return const _MessageState(
        icon: Icons.check_circle_outline,
        message: '등록된 Todo가 없습니다.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTodos,
      child: SlidableAutoCloseBehavior(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _todos.length,
          itemBuilder: (context, index) {
            final todo = _todos[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Slidable(
                key: ValueKey(todo.seq),
                endActionPane: ActionPane(
                  motion: const DrawerMotion(),
                  extentRatio: 0.25,
                  children: [
                    SlidableAction(
                      key: Key('deleteTodo_${todo.seq}'),
                      onPressed: (_) => _deleteTodo(todo),
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: '삭제',
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ],
                ),
                child: _TodoCard(todo: todo),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TodoCard extends StatelessWidget {
  const _TodoCard({required this.todo});

  final TodoItem todo;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFF8F0FA),
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: const Icon(Icons.event_note_outlined),
        title: Text('${todo.title} / ${todo.todoDate}'),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 12),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
