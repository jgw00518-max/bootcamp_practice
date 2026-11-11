import 'package:flutter/material.dart';

import '../vm/must_eat_place_view_model.dart';

/// 사용자가 맛집 카테고리를 직접 추가하고 삭제하는 화면이다.
class CategorySettingsPage extends StatefulWidget {
  const CategorySettingsPage({super.key, required this.viewModel});

  final MustEatPlaceViewModel viewModel;

  @override
  State<CategorySettingsPage> createState() => _CategorySettingsPageState();
}

class _CategorySettingsPageState extends State<CategorySettingsPage> {
  final _categoryController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  /// 입력한 이름을 ViewModel에 전달하고 성공하면 입력란을 비운다.
  Future<void> _addCategory() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await widget.viewModel.addCategory(_categoryController.text);
      _categoryController.clear();
    } catch (error) {
      _showMessage(_readableError(error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// 사용자 확인 후 현재 맛집이 사용하지 않는 카테고리의 삭제를 요청한다.
  Future<void> _deleteCategory(String category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('카테고리 삭제'),
        content: Text('$category 카테고리를 삭제할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await widget.viewModel.deleteCategory(category);
    } catch (error) {
      _showMessage(_readableError(error));
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _readableError(Object error) {
    return error
        .toString()
        .replaceFirst('Bad state: ', '')
        .replaceFirst('Invalid argument(s): ', '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('카테고리 관리')),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, child) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 34,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 14),
                  const Expanded(child: Text('나만의 맛집 분류를 자유롭게 관리해 보세요.')),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('category_name_field'),
                    controller: _categoryController,
                    decoration: const InputDecoration(
                      labelText: '새 카테고리',
                      hintText: '예: 카페',
                    ),
                    maxLength: 20,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _addCategory(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  key: const Key('add_category_button'),
                  onPressed: _saving ? null : _addCategory,
                  child: const Icon(Icons.add_rounded),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...widget.viewModel.categories.map(
              (category) => Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    child: const Icon(Icons.restaurant_menu_rounded),
                  ),
                  title: Text(
                    category,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  trailing: IconButton(
                    key: Key('delete_category_$category'),
                    onPressed: () => _deleteCategory(category),
                    tooltip: '$category 삭제',
                    icon: const Icon(Icons.delete_outline),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
