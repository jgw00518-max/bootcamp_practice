import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:project_todolist/controller/todo_controller.dart';
import 'package:project_todolist/model/routine.dart';
import 'package:project_todolist/theme/app_theme.dart';
import 'package:project_todolist/view/task_form_page.dart';

/// 등록된 루틴의 반복 조건, 활성 상태와 달성 현황을 관리합니다.
class RoutinePage extends GetView<TodoController> {
  const RoutinePage({super.key});

  static const _weekLabels = ['월', '화', '수', '목', '금', '토', '일'];

  @override
  Widget build(BuildContext context) => Obx(() {
    final active = controller.routines
        .where((routine) => routine.isActive)
        .length;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.screenPadding,
        18,
        AppDimensions.screenPadding,
        100,
      ),
      children: [
        Text('루틴', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 6),
        const Text(
          '반복하는 업무를 자동으로 관리해 보세요.',
          style: TextStyle(color: AppColors.muted),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            _SummaryChip(label: '전체', count: controller.routines.length),
            const SizedBox(width: 8),
            _SummaryChip(label: '활성', count: active),
            const SizedBox(width: 8),
            _SummaryChip(
              label: '일시 중지',
              count: controller.routines.length - active,
            ),
          ],
        ),
        const SizedBox(height: 22),
        if (controller.routines.isEmpty)
          const _EmptyRoutines()
        else ...[
          const Text(
            '등록된 루틴',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          ...controller.routines.map(
            (routine) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _RoutineCard(
                routine: routine,
                repeatText: _repeatText(routine.repeatDays),
                completionText: _completionText(routine),
                onTap: () => Get.to(
                  () => TaskFormPage(routine: routine, initialRepeat: true),
                ),
                onToggle: (_) => controller.toggleRoutine(routine),
                onDelete: () => _confirmDelete(context, routine),
              ),
            ),
          ),
        ],
      ],
    );
  });

  String _repeatText(Set<int> days) {
    if (days.length == 7) return '매일';
    if (days.length == 5 && {1, 2, 3, 4, 5}.every(days.contains)) return '평일';
    final sorted = days.toList()..sort();
    return sorted.map((day) => _weekLabels[day - 1]).join(' · ');
  }

  String _completionText(Routine routine) {
    final generated = controller.todos.where(
      (todo) => todo.routineId == routine.id,
    );
    final completed = generated.where((todo) => todo.isCompleted).length;
    return generated.isEmpty
        ? '생성된 일정 없음'
        : '생성된 일정 ${generated.length}개 · 완료 $completed개';
  }

  Future<void> _confirmDelete(BuildContext context, Routine routine) async {
    final action = await showDialog<_RoutineDeleteAction>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('루틴을 삭제할까요?'),
        content: const Text(
          '삭제한 루틴은 다시 켤 수 없습니다.\n\n완료 기록과 집중 기록은 유지됩니다. 남아 있는 미완료 일정의 처리 방법을 선택해 주세요.',
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OutlinedButton(
                  key: const ValueKey('confirm_delete_routine'),
                  onPressed: () => Navigator.pop(
                    context,
                    _RoutineDeleteAction.keepIncomplete,
                  ),
                  child: const Text('루틴만 삭제'),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  key: const ValueKey('delete_routine_with_incomplete'),
                  onPressed: () => Navigator.pop(
                    context,
                    _RoutineDeleteAction.trashIncomplete,
                  ),
                  style: AppDialogStyles.destructiveAction,
                  child: const Text('미완료 일정은 휴지통으로'),
                ),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: AppDialogStyles.cancelAction,
                  child: const Text('취소'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    if (action != null && routine.id != null) {
      await controller.deleteRoutine(
        routine.id!,
        moveIncompleteTodosToTrash:
            action == _RoutineDeleteAction.trashIncomplete,
      );
    }
  }
}

enum _RoutineDeleteAction { keepIncomplete, trashIncomplete }

class _RoutineCard extends StatelessWidget {
  const _RoutineCard({
    required this.routine,
    required this.repeatText,
    required this.completionText,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  final Routine routine;
  final String repeatText;
  final String completionText;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Slidable(
    key: ValueKey('slidable_routine_${routine.id}'),
    endActionPane: ActionPane(
      motion: const DrawerMotion(),
      extentRatio: .24,
      children: [
        SlidableAction(
          key: ValueKey('slide_delete_routine_${routine.id}'),
          onPressed: (_) => onDelete(),
          backgroundColor: AppColors.red,
          foregroundColor: Colors.white,
          icon: Icons.delete_outline_rounded,
          label: '삭제',
          borderRadius: BorderRadius.circular(16),
        ),
      ],
    ),
    child: Card(
      key: ValueKey('routine_card_${routine.id}'),
      margin: EdgeInsets.zero,
      elevation: 0,
      color: routine.isActive ? AppColors.surface : Colors.grey.shade100,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.cardPadding,
            14,
            12,
            14,
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.repeat_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      routine.title,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '$repeatText · ${routine.hasTime ? '${routine.scheduledHour.toString().padLeft(2, '0')}:${routine.scheduledMinute.toString().padLeft(2, '0')}' : '종일'}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      completionText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              _RoutineToggle(
                routineId: routine.id,
                isActive: routine.isActive,
                onChanged: onToggle,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// 루틴의 활성 상태를 아이콘과 문구로 함께 전달하는 간결한 스위치입니다.
class _RoutineToggle extends StatelessWidget {
  const _RoutineToggle({
    required this.routineId,
    required this.isActive,
    required this.onChanged,
  });

  final int? routineId;
  final bool isActive;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Semantics(
    label: isActive ? '루틴 자동 생성 중' : '루틴 일시 중지됨',
    toggled: isActive,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          isActive ? '자동 생성' : '일시 중지',
          key: ValueKey('routine_status_$routineId'),
          style: TextStyle(
            color: isActive ? AppColors.primary : AppColors.muted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(
          width: 52,
          height: 38,
          child: FittedBox(
            fit: BoxFit.contain,
            child: Switch(
              key: ValueKey('routine_toggle_$routineId'),
              value: isActive,
              onChanged: onChanged,
              activeThumbColor: Colors.white,
              activeTrackColor: AppColors.primary,
              inactiveThumbColor: AppColors.muted,
              inactiveTrackColor: AppColors.surface,
              trackOutlineColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? AppColors.primary
                    : AppColors.border,
              ),
              thumbIcon: WidgetStateProperty.resolveWith(
                (states) => Icon(
                  states.contains(WidgetState.selected)
                      ? Icons.check_rounded
                      : Icons.pause_rounded,
                  size: 15,
                  color: states.contains(WidgetState.selected)
                      ? AppColors.primary
                      : Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.muted),
          ),
          const SizedBox(height: 3),
          Text(
            '$count',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    ),
  );
}

class _EmptyRoutines extends StatelessWidget {
  const _EmptyRoutines();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.only(top: 70),
    child: Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.repeat_rounded, size: 58, color: AppColors.muted),
            SizedBox(height: 14),
            Text(
              '등록된 루틴이 없어요',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 7),
            Text(
              '반복하는 업무를 루틴으로 만들어 보세요.',
              style: TextStyle(color: AppColors.muted),
            ),
          ],
        ),
      ),
    ),
  );
}
