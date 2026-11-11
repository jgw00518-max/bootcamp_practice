import 'package:flutter/material.dart';

import '../model/todo.dart';
import '../theme/app_colors.dart';
import 'app_icon_box.dart';

/// 할 일 정보, 드래그 핸들, 휴지통 스와이프를 제공하는 카드다.
class TodoCard extends StatelessWidget {
  const TodoCard({
    super.key,
    required this.todo,
    required this.reorderIndex,
    required this.onDismissed,
  });

  final TodoItem todo;
  final int reorderIndex;
  final VoidCallback onDismissed;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(todo.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 22),
        decoration: BoxDecoration(
          color: AppColors.danger,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.white),
            Text('휴지통', style: TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
      onDismissed: (_) => onDismissed(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFEEEFF5)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D20233A),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const AppIconBox(icon: Icons.calendar_today_rounded, size: 44),
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
                  const SizedBox(height: 6),
                  Text(
                    todo.createdDate,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            ReorderableDragStartListener(
              key: ValueKey('drag-${todo.id}'),
              index: reorderIndex,
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(
                  Icons.drag_handle_rounded,
                  color: Color(0xFFC5C7D0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
