import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:project_todolist/controller/todo_controller.dart';
import 'package:project_todolist/model/todo.dart';
import 'package:project_todolist/theme/app_theme.dart';

/// 삭제된 Todo를 확인하고 복구하거나 영구 삭제하는 휴지통 화면입니다.
class TrashPage extends GetView<TodoController> {
  const TrashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('휴지통'),
        centerTitle: true,
        actions: [
          Obx(
            () => IconButton(
              key: const ValueKey('restore_all_todos'),
              tooltip: '전체 복구',
              onPressed: controller.deletedTodos.isEmpty
                  ? null
                  : () => _confirmRestoreAll(context),
              icon: const Icon(Icons.restore_page_rounded),
            ),
          ),
          Obx(
            () => IconButton(
              key: const ValueKey('delete_all_todos'),
              tooltip: '전체 영구 삭제',
              onPressed: controller.deletedTodos.isEmpty
                  ? null
                  : () => _confirmPermanentDeleteAll(context),
              color: AppColors.red,
              icon: const Icon(Icons.delete_sweep_rounded),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Obx(() {
        if (controller.deletedTodos.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.delete_outline_rounded,
                  size: 58,
                  color: AppColors.muted,
                ),
                SizedBox(height: 14),
                Text(
                  '휴지통이 비어 있어요',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 6),
                Text(
                  '삭제한 할 일이 여기에 표시됩니다.',
                  style: TextStyle(color: AppColors.muted),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(AppDimensions.screenPadding),
          itemCount: controller.deletedTodos.length,
          itemBuilder: (context, index) => _TrashCard(
            item: controller.deletedTodos[index],
            onRestore: () => _restore(controller.deletedTodos[index]),
            onDelete: () => _confirmPermanentDelete(
              context,
              controller.deletedTodos[index],
            ),
          ),
        );
      }),
    );
  }

  Future<void> _restore(DeletedTodo item) async {
    final restored = await controller.restoreTodo(item.todo.id!);
    if (!restored) return;
    Get.snackbar(
      '복구 완료',
      '할 일이 원래 일정 위치로 복구되었어요.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// 실수로 누르는 일을 막기 위해 확인 후 휴지통 전체를 복구합니다.
  Future<void> _confirmRestoreAll(BuildContext context) async {
    final count = controller.deletedTodos.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('모두 복구할까요?'),
        content: Text('휴지통의 할 일 $count개를 목록으로 복구합니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: AppDialogStyles.cancelAction,
            child: const Text('취소'),
          ),
          FilledButton(
            key: const ValueKey('confirm_restore_all_button'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('모두 복구'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final restored = await controller.restoreAllTodos();
    if (!restored) return;
    Get.snackbar(
      '전체 복구 완료',
      '할 일 $count개를 복구했어요.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  /// 되돌릴 수 없는 전체 영구 삭제를 명확히 안내한 뒤 실행합니다.
  Future<void> _confirmPermanentDeleteAll(BuildContext context) async {
    final count = controller.deletedTodos.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('휴지통을 비울까요?'),
        content: Text('할 일 $count개가 영구 삭제되며 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: AppDialogStyles.cancelAction,
            child: const Text('취소'),
          ),
          FilledButton(
            key: const ValueKey('confirm_delete_all_button'),
            onPressed: () => Navigator.pop(context, true),
            style: AppDialogStyles.destructiveAction,
            child: const Text('휴지통 비우기'),
          ),
        ],
      ),
    );
    if (confirmed == true) await controller.permanentlyDeleteAllTodos();
  }

  Future<void> _confirmPermanentDelete(
    BuildContext context,
    DeletedTodo item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('영구 삭제할까요?'),
        content: Text('‘${item.todo.title}’은 삭제 후 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: AppDialogStyles.cancelAction,
            child: const Text('취소'),
          ),
          FilledButton(
            key: const ValueKey('confirm_permanent_delete_button'),
            onPressed: () => Navigator.pop(context, true),
            style: AppDialogStyles.destructiveAction,
            child: const Text('영구 삭제'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await controller.permanentlyDeleteTodo(item.todo.id!);
    }
  }
}

class _TrashCard extends StatelessWidget {
  const _TrashCard({
    required this.item,
    required this.onRestore,
    required this.onDelete,
  });

  final DeletedTodo item;
  final VoidCallback onRestore;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      border: Border.all(color: AppColors.border),
    ),
    child: ListTile(
      contentPadding: const EdgeInsets.fromLTRB(16, 7, 6, 7),
      minVerticalPadding: 0,
      title: Text(
        item.todo.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          '${item.todo.category} · ${item.todo.hasTime ? DateFormat('M월 d일 HH:mm', 'ko').format(item.todo.dueAt) : DateFormat('M월 d일 · 종일', 'ko').format(item.todo.dueAt)}\n${DateFormat('M월 d일 HH:mm', 'ko').format(item.deletedAt)} 삭제',
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 12,
            height: 1.45,
          ),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            key: ValueKey('restore_todo_${item.todo.id}'),
            tooltip: '복구',
            onPressed: onRestore,
            color: AppColors.primary,
            icon: const Icon(Icons.restore_rounded),
          ),
          IconButton(
            key: ValueKey('permanent_delete_todo_${item.todo.id}'),
            tooltip: '영구 삭제',
            onPressed: onDelete,
            color: AppColors.red,
            icon: const Icon(Icons.delete_forever_outlined),
          ),
        ],
      ),
    ),
  );
}
