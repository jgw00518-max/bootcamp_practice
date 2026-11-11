import 'package:flutter/material.dart';

import '../model/todo.dart';
import '../repository/todo_repository.dart';
import '../theme/app_colors.dart';

/// 휴지통 항목 조회, 개별 영구 삭제, 전체 비우기를 제공하는 화면이다.
class TrashPage extends StatefulWidget {
  const TrashPage({super.key, required this.repository});

  /// 휴지통 데이터를 읽고 삭제할 저장소다.
  final TodoRepository repository;

  @override
  State<TrashPage> createState() => _TrashPageState();
}

class _TrashPageState extends State<TrashPage> {
  /// 화면에 표시할 휴지통 항목 목록이다.
  List<DeletedTodoItem> _deletedTodos = const [];

  /// 최초 휴지통 조회 중인지 나타낸다.
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDeletedTodos();
  }

  /// 저장소에서 휴지통 데이터를 불러와 화면을 갱신한다.
  Future<void> _loadDeletedTodos() async {
    final deletedTodos = await widget.repository.getDeletedTodos();
    if (!mounted) return;
    setState(() {
      _deletedTodos = deletedTodos;
      _isLoading = false;
    });
  }

  /// 사용자 확인 후 선택한 휴지통 항목을 영구 삭제한다.
  Future<bool> _permanentlyDelete(DeletedTodoItem todo) async {
    final confirmed = await _showConfirmDialog(
      title: '영구 삭제',
      message: '“${todo.content}” 항목을 완전히 삭제할까요?',
      confirmText: '삭제',
    );
    if (!confirmed) return false;

    await widget.repository.permanentlyDeleteTodo(todo.id);
    return true;
  }

  /// 선택한 휴지통 항목을 Todo 목록 최상단으로 복구한다.
  Future<void> _restoreTodo(DeletedTodoItem todo) async {
    await widget.repository.restoreTodo(todo.id);
  }

  /// 스와이프 처리가 끝난 항목을 휴지통 화면에서 제거한다.
  void _removeFromTrash(DeletedTodoItem todo) {
    setState(() {
      _deletedTodos = _deletedTodos
          .where((item) => item.id != todo.id)
          .toList();
    });
  }

  /// 사용자 확인 후 휴지통의 모든 항목을 영구 삭제한다.
  Future<void> _emptyTrash() async {
    final confirmed = await _showConfirmDialog(
      title: '휴지통 비우기',
      message: '휴지통의 모든 항목을 완전히 삭제할까요?\n이 작업은 되돌릴 수 없습니다.',
      confirmText: '모두 삭제',
    );
    if (!confirmed) return;

    await widget.repository.emptyTrash();
    if (!mounted) return;
    setState(() => _deletedTodos = const []);
  }

  /// 영구 삭제 전에 사용자의 최종 확인을 받는다.
  Future<bool> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmText,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('취소'),
              ),
              FilledButton(
                key: const Key('confirm_permanent_delete'),
                onPressed: () => Navigator.pop(dialogContext, true),
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: Text(confirmText),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: const Text('휴지통', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            key: const Key('empty_trash_button'),
            onPressed: _deletedTodos.isEmpty ? null : _emptyTrash,
            tooltip: '휴지통 비우기',
            icon: const Icon(Icons.delete_sweep_outlined),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _deletedTodos.isEmpty
          ? const _EmptyTrashView()
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              itemCount: _deletedTodos.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final todo = _deletedTodos[index];
                return _DeletedTodoCard(
                  todo: todo,
                  onRestore: () => _restoreTodo(todo),
                  onDelete: () => _permanentlyDelete(todo),
                  onDismissed: () => _removeFromTrash(todo),
                );
              },
            ),
    );
  }
}

/// 양방향 스와이프로 복구와 영구 삭제를 제공하는 휴지통 카드다.
class _DeletedTodoCard extends StatelessWidget {
  const _DeletedTodoCard({
    required this.todo,
    required this.onRestore,
    required this.onDelete,
    required this.onDismissed,
  });

  final DeletedTodoItem todo;
  final Future<void> Function() onRestore;
  final Future<bool> Function() onDelete;
  final VoidCallback onDismissed;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('deleted-${todo.id}'),
      direction: DismissDirection.horizontal,
      background: const _SwipeActionBackground(
        alignment: Alignment.centerLeft,
        color: Color(0xFF39B980),
        icon: Icons.restore_rounded,
        label: '복구',
      ),
      secondaryBackground: const _SwipeActionBackground(
        alignment: Alignment.centerRight,
        color: Color(0xFFFF647C),
        icon: Icons.delete_forever_outlined,
        label: '영구 삭제',
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await onRestore();
          return true;
        }
        return onDelete();
      },
      onDismissed: (_) => onDismissed(),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFEEEFF5)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFFFECEF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.red,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    todo.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '등록 ${todo.createdDate} · 삭제 ${todo.deletedDate}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.swipe_rounded, color: Color(0xFFC5C7D0)),
          ],
        ),
      ),
    );
  }
}

/// 복구와 영구 삭제 방향을 안내하는 스와이프 배경이다.
class _SwipeActionBackground extends StatelessWidget {
  const _SwipeActionBackground({
    required this.alignment,
    required this.color,
    required this.icon,
    required this.label,
  });

  final Alignment alignment;
  final Color color;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isLeft = alignment == Alignment.centerLeft;
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: isLeft
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// 휴지통이 비어 있을 때 표시하는 안내 화면이다.
class _EmptyTrashView extends StatelessWidget {
  const _EmptyTrashView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.delete_outline_rounded,
            size: 72,
            color: Color(0xFFC5C7D0),
          ),
          SizedBox(height: 16),
          Text(
            '휴지통이 비어 있어요',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 7),
          Text(
            '삭제한 할 일이 이곳에 보관됩니다.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
