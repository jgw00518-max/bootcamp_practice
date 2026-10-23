import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;
import 'package:mysql_todo_list_app/data/todo_api.dart';
import 'package:mysql_todo_list_app/model/todo_item.dart';

class DeleteList extends StatefulWidget {
  const DeleteList({
    super.key,
    this.client,
    this.baseUrl = TodoApi.defaultBaseUrl,
  });

  final http.Client? client;
  final String baseUrl;

  @override
  State<DeleteList> createState() => _DeleteListState();
}

class _DeleteListState extends State<DeleteList> {
  late final TodoApi _api;
  List<DeletedTodoItem> _deletedTodos = const [];
  bool _isLoading = true;
  String? _errorMessage;

  /// 화면 진입 시 최근 삭제 순서의 목록을 불러온다.
  @override
  void initState() {
    super.initState();
    _api = TodoApi(client: widget.client, baseUrl: widget.baseUrl);
    _loadDeletedTodos();
  }

  /// 삭제 목록의 로딩, 성공, 오류 상태를 갱신한다.
  Future<void> _loadDeletedTodos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final deletedTodos = await _api.fetchDeletedTodos();
      if (!mounted) return;

      setState(() {
        _deletedTodos = deletedTodos;
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

  /// 선택한 삭제 Todo를 현재 목록으로 복구하고 휴지통에서 제거한다.
  Future<void> _restoreTodo(DeletedTodoItem todo) async {
    try {
      await _api.restoreTodo(todo.seq);
      if (!mounted) return;

      setState(() {
        _deletedTodos = _deletedTodos
            .where((item) => item.seq != todo.seq)
            .toList();
      });
      _showMessage('Todo를 복구했습니다.');
    } catch (error) {
      if (!mounted) return;
      _showMessage(error.toString());
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
      appBar: AppBar(title: const Text('Delete Lists')),
      body: _buildBody(),
    );
  }

  /// API 상태에 따라 삭제 목록의 내용을 구분해 표시한다.
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _loadDeletedTodos,
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }

    if (_deletedTodos.isEmpty) {
      return const Center(child: Text('삭제된 Todo가 없습니다.'));
    }

    return RefreshIndicator(
      onRefresh: _loadDeletedTodos,
      child: SlidableAutoCloseBehavior(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _deletedTodos.length,
          itemBuilder: (context, index) {
            final todo = _deletedTodos[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Slidable(
                key: ValueKey(todo.seq),
                startActionPane: ActionPane(
                  motion: const DrawerMotion(),
                  extentRatio: 0.25,
                  children: [
                    SlidableAction(
                      key: Key('restoreTodo_${todo.seq}'),
                      onPressed: (_) => _restoreTodo(todo),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      icon: Icons.restore,
                      label: '복구',
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ],
                ),
                child: Card(
                  color: const Color(0xFFF8F0FA),
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    leading: const Icon(Icons.event_note_outlined),
                    title: Text('${todo.title} / ${todo.todoDate}'),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
