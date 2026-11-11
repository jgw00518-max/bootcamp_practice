import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_todolist/controller/todo_controller.dart';
import 'package:project_todolist/model/todo_category.dart';
import 'package:project_todolist/theme/app_theme.dart';

/// 사용자 카테고리를 추가하고 이름을 바꾸거나 삭제하는 관리 화면입니다.
class CategoryManagementPage extends GetView<TodoController> {
  const CategoryManagementPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('카테고리 관리'),
      actions: [
        IconButton(
          key: const ValueKey('add_category_button'),
          tooltip: '카테고리 추가',
          onPressed: () => _showNameDialog(context),
          icon: const Icon(Icons.add_rounded),
        ),
      ],
    ),
    body: Obx(
      () => ListView(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.screenPadding,
          16,
          AppDimensions.screenPadding,
          32,
        ),
        children: [
          const _CategoryTile(
            name: '없음',
            subtitle: '카테고리를 지정하지 않은 할 일',
            locked: true,
          ),
          const SizedBox(height: 10),
          ...controller.categories.map(
            (category) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _CategoryTile(
                key: ValueKey('category_${category.id}'),
                name: category.name,
                onEdit: () => _showNameDialog(context, category: category),
                onDelete: () => _confirmDelete(context, category),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Future<void> _showNameDialog(
    BuildContext context, {
    TodoCategory? category,
  }) async {
    final textController = TextEditingController(text: category?.name ?? '');
    String? error;
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: Text(category == null ? '카테고리 추가' : '카테고리 수정'),
          content: TextField(
            key: const ValueKey('category_name_field'),
            controller: textController,
            autofocus: true,
            maxLength: 20,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: '이름',
              hintText: '예: 운동, 프로젝트',
              errorText: error,
            ),
            onSubmitted: (_) => _submitName(
              dialogContext,
              textController.text,
              category,
              (value) => setModalState(() => error = value),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('취소'),
            ),
            FilledButton(
              key: const ValueKey('save_category_button'),
              onPressed: () => _submitName(
                dialogContext,
                textController.text,
                category,
                (value) => setModalState(() => error = value),
              ),
              child: Text(category == null ? '추가' : '저장'),
            ),
          ],
        ),
      ),
    );
    if (name == null) return;
    if (category == null) {
      await controller.addCategory(name);
    } else {
      await controller.updateCategory(category, name);
    }
  }

  void _submitName(
    BuildContext context,
    String value,
    TodoCategory? category,
    ValueChanged<String?> setError,
  ) {
    final error = controller.validateCategoryName(
      value,
      excludingId: category?.id,
    );
    if (error != null) {
      setError(error);
      return;
    }
    Navigator.pop(context, value.trim());
  }

  Future<void> _confirmDelete(
    BuildContext context,
    TodoCategory category,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('${category.name} 카테고리를 삭제할까요?'),
        content: const Text('연결된 할 일을 카테고리 없음으로 변경하고 삭제합니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('취소'),
          ),
          FilledButton(
            key: const ValueKey('confirm_delete_category_button'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.red),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (confirmed == true) await controller.deleteCategory(category);
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    super.key,
    required this.name,
    this.subtitle,
    this.locked = false,
    this.onEdit,
    this.onDelete,
  });

  final String name;
  final String? subtitle;
  final bool locked;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      border: Border.all(color: AppColors.border),
    ),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: locked
            ? AppColors.surface
            : AppColors.primary.withValues(alpha: 0.1),
        child: Icon(
          locked ? Icons.remove_rounded : Icons.folder_outlined,
          color: locked ? AppColors.muted : AppColors.primary,
        ),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: locked
          ? const Icon(Icons.lock_outline_rounded, color: AppColors.muted)
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  key: ValueKey('edit_category_$name'),
                  tooltip: '수정',
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  key: ValueKey('delete_category_$name'),
                  tooltip: '삭제',
                  color: AppColors.red,
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
    ),
  );
}
