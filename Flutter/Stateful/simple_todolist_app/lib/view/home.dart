import 'package:flutter/material.dart';

import '../database/todo_database.dart';
import '../model/todo.dart';
import '../repository/todo_repository.dart';
import '../theme/app_colors.dart';
import '../widget/add_todo_bottom_sheet.dart';
import '../widget/app_icon_box.dart';
import '../widget/todo_card.dart';
import 'trash.dart';

/// Todo 조회, 추가, 재정렬, 휴지통 이동을 관리하는 메인 화면이다.
class Home extends StatefulWidget {
  const Home({super.key, this.repository});

  /// 테스트에서는 메모리 저장소, 실제 앱에서는 SQLite 저장소를 사용한다.
  final TodoRepository? repository;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late final TodoRepository _repository;
  List<TodoItem> _todos = const [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? TodoDatabase.instance;
    _loadTodos();
  }

  /// 저장된 Todo를 조회해 화면 목록을 갱신한다.
  Future<void> _loadTodos() async {
    final todos = await _repository.getTodos();
    if (!mounted) return;
    setState(() {
      _todos = todos;
      _isLoading = false;
    });
  }

  /// 현재 날짜를 DB 저장 형식으로 반환한다.
  String _today() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  /// 헤더에 표시할 한글 날짜를 반환한다.
  String _headerDate() {
    final now = DateTime.now();
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return '${now.year}년 ${now.month}월 ${now.day}일 '
        '${weekdays[now.weekday - 1]}요일';
  }

  /// 입력 시트의 결과를 저장하고 목록 최상단에 추가한다.
  Future<void> _showAddBottomSheet() async {
    final content = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black45,
      builder: (_) => const AddTodoBottomSheet(),
    );
    if (content == null || content.isEmpty) return;

    final savedTodo = await _repository.addTodo(
      TodoItem(content: content, createdDate: _today()),
    );
    if (mounted) setState(() => _todos = [savedTodo, ..._todos]);
  }

  /// 변경된 화면 순서를 저장소에도 반영한다.
  Future<void> _reorderTodos(int oldIndex, int newIndex) async {
    final reordered = List<TodoItem>.of(_todos);
    reordered.insert(newIndex, reordered.removeAt(oldIndex));
    setState(() => _todos = reordered);
    await _repository.updateTodoOrder(
      reordered.map((todo) => todo.id).whereType<int>().toList(),
    );
  }

  /// 스와이프한 Todo를 휴지통으로 이동한다.
  Future<void> _moveTodoToTrash(TodoItem todo) async {
    final id = todo.id;
    if (id == null) return;
    await _repository.moveTodoToTrash(id, _today());
    if (mounted) {
      setState(() => _todos = _todos.where((item) => item.id != id).toList());
    }
  }

  /// 휴지통 화면에서 돌아오면 복구된 Todo를 다시 조회한다.
  Future<void> _openTrash() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => TrashPage(repository: _repository)),
    );
    await _loadTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('open_add_dialog'),
        onPressed: _showAddBottomSheet,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('할 일 추가'),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  /// 제목, 날짜, Todo 개수를 표시하는 헤더다.
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AppIconBox(icon: Icons.check_rounded),
              const SizedBox(width: 12),
              const Text(
                'Todo Lists',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              IconButton(
                key: const Key('open_trash_button'),
                onPressed: _openTrash,
                tooltip: '휴지통',
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            '오늘도 하나씩 해볼까요?',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _headerDate(),
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xFF7A70EC)],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              _todos.isEmpty
                  ? '새로운 할 일을 계획해 보세요'
                  : '오늘 할 일 ${_todos.length}개가 있어요',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 로딩, 빈 목록, Todo 목록 상태에 맞는 본문을 반환한다.
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (_todos.isEmpty) return const _EmptyTodoView();

    return ReorderableListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 100),
      itemCount: _todos.length,
      buildDefaultDragHandles: false,
      onReorderItem: _reorderTodos,
      itemBuilder: (context, index) {
        final todo = _todos[index];
        return Padding(
          key: ValueKey('reorder-${todo.id}'),
          padding: const EdgeInsets.only(bottom: 12),
          child: TodoCard(
            todo: todo,
            reorderIndex: index,
            onDismissed: () => _moveTodoToTrash(todo),
          ),
        );
      },
    );
  }
}

/// 등록된 Todo가 없을 때 표시하는 안내 화면이다.
class _EmptyTodoView extends StatelessWidget {
  const _EmptyTodoView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.task_alt_rounded, size: 72, color: AppColors.primary),
          SizedBox(height: 18),
          Text(
            '아직 등록된 할 일이 없어요',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 7),
          Text(
            '아래 버튼을 눌러 첫 할 일을 추가해 보세요.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
