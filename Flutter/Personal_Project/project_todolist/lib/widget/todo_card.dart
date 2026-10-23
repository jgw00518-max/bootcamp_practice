import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:project_todolist/model/todo.dart';
import 'package:project_todolist/theme/app_theme.dart';

/// 완료 상태, 일정, 우선순위를 보여주고 수정 화면 진입을 전달하는 카드입니다.
class TodoCard extends StatelessWidget {
  const TodoCard({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onTap,
    this.onDelete,
    this.isEndedRoutine = false,
  });

  final Todo todo;
  final VoidCallback onToggle;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final bool isEndedRoutine;

  @override
  Widget build(BuildContext context) {
    final color = switch (todo.priority) {
      2 => AppColors.red,
      1 => AppColors.orange,
      _ => AppColors.green,
    };
    final label = switch (todo.priority) {
      2 => '높음',
      1 => '보통',
      _ => '낮음',
    };
    final supportingColor = todo.isCompleted
        ? AppColors.muted.withValues(alpha: .58)
        : AppColors.muted;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Slidable(
        key: ValueKey('slidable_todo_${todo.id}'),
        endActionPane: onDelete == null
            ? null
            : ActionPane(
                motion: const DrawerMotion(),
                extentRatio: .24,
                children: [
                  SlidableAction(
                    key: ValueKey('slide_delete_${todo.id}'),
                    onPressed: (_) => onDelete!(),
                    backgroundColor: AppColors.red,
                    foregroundColor: Colors.white,
                    icon: Icons.delete_outline_rounded,
                    label: '삭제',
                    borderRadius: BorderRadius.circular(
                      AppDimensions.cardRadius,
                    ),
                  ),
                ],
              ),
        child: Material(
          color: todo.isCompleted ? const Color(0xFFF8F9FC) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
            side: const BorderSide(color: AppColors.border),
          ),
          child: InkWell(
            key: ValueKey('todo_card_${todo.id}'),
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.cardPadding),
              child: Row(
                children: [
                  SizedBox.square(
                    dimension: 48,
                    child: InkWell(
                      key: ValueKey('todo_${todo.id}'),
                      onTap: onToggle,
                      customBorder: const CircleBorder(),
                      child: Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: todo.isCompleted
                                ? AppColors.primary
                                : Colors.white,
                            border: Border.all(
                              color: todo.isCompleted
                                  ? AppColors.primary
                                  : const Color(0xFF9AA5BA),
                              width: 1.5,
                            ),
                          ),
                          child: todo.isCompleted
                              ? const Icon(
                                  Icons.check_rounded,
                                  size: 16,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          todo.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: todo.isCompleted
                                ? AppColors.muted
                                : AppColors.ink,
                            decoration: todo.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            if (todo.routineId != null) ...[
                              Container(
                                key: ValueKey('todo_routine_badge_${todo.id}'),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      (todo.isCompleted || isEndedRoutine
                                              ? AppColors.muted
                                              : AppColors.primary)
                                          .withValues(alpha: .1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.repeat_rounded,
                                      size: 13,
                                      color: todo.isCompleted || isEndedRoutine
                                          ? supportingColor
                                          : AppColors.primary,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      isEndedRoutine ? '종료된 루틴' : '루틴',
                                      style: TextStyle(
                                        color:
                                            todo.isCompleted || isEndedRoutine
                                            ? supportingColor
                                            : AppColors.primary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                            if (todo.memo.trim().isNotEmpty) ...[
                              Icon(
                                Icons.notes_rounded,
                                key: ValueKey('todo_memo_indicator_${todo.id}'),
                                size: 14,
                                color: supportingColor,
                              ),
                              const SizedBox(width: 4),
                            ],
                            Flexible(
                              child: Text(
                                '${todo.category}   ·   ${todo.hasTime ? DateFormat('M월 d일 HH:mm', 'ko').format(todo.dueAt) : DateFormat('M월 d일 · 종일', 'ko').format(todo.dueAt)}',
                                key: ValueKey('todo_metadata_${todo.id}'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: supportingColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: .11),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: AppColors.muted,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
