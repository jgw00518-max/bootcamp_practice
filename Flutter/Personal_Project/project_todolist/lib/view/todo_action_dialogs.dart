import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_todolist/controller/todo_controller.dart';
import 'package:project_todolist/model/routine.dart';
import 'package:project_todolist/model/todo.dart';
import 'package:project_todolist/theme/app_theme.dart';
import 'package:project_todolist/view/task_form_page.dart';

Routine? _routineFor(TodoController controller, Todo todo) {
  for (final routine in controller.routines) {
    if (routine.id == todo.routineId) return routine;
  }
  return null;
}

/// 루틴 Todo는 현재 일정과 이후 반복 일정 중 수정 범위를 먼저 선택합니다.
Future<void> openTodoEditor(BuildContext context, Todo todo) async {
  final controller = Get.find<TodoController>();
  final routine = _routineFor(controller, todo);
  if (routine == null) {
    await Get.to(() => TaskFormPage(todo: todo));
    return;
  }
  final scope = await showDialog<_TodoEditScope>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('무엇을 수정할까요?'),
      content: const Text('현재 일정만 바꾸거나 앞으로 생성될 반복 일정을 변경할 수 있어요.'),
      actions: [
        TextButton(
          key: const ValueKey('edit_this_todo_only'),
          onPressed: () => Navigator.pop(context, _TodoEditScope.occurrence),
          child: const Text('이 일정만 수정'),
        ),
        FilledButton(
          key: const ValueKey('edit_future_routine'),
          onPressed: () => Navigator.pop(context, _TodoEditScope.future),
          child: const Text('이후 반복 일정 수정'),
        ),
      ],
    ),
  );
  if (scope == _TodoEditScope.occurrence) {
    await Get.to(() => TaskFormPage(todo: todo));
  } else if (scope == _TodoEditScope.future) {
    await Get.to(() => TaskFormPage(routine: routine, initialRepeat: true));
  }
}

/// 루틴 Todo는 한 건 삭제와 원본 루틴 중지 중 원하는 범위를 선택합니다.
Future<void> deleteTodoWithScope(BuildContext context, Todo todo) async {
  final controller = Get.find<TodoController>();
  final routine = _routineFor(controller, todo);
  if (routine != null) {
    final scope = await showDialog<_TodoDeleteScope>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이 반복 일정을 어떻게 처리할까요?'),
        content: const Text('현재 일정만 삭제하거나 앞으로의 루틴을 중지할 수 있어요.'),
        actions: [
          TextButton(
            key: const ValueKey('delete_this_todo_only'),
            onPressed: () =>
                Navigator.pop(context, _TodoDeleteScope.occurrence),
            style: AppDialogStyles.destructiveTextAction,
            child: const Text('이 일정만 삭제'),
          ),
          FilledButton(
            key: const ValueKey('stop_todo_routine'),
            onPressed: () =>
                Navigator.pop(context, _TodoDeleteScope.stopRoutine),
            child: const Text('루틴 중지'),
          ),
        ],
      ),
    );
    if (!context.mounted) return;
    if (scope == _TodoDeleteScope.stopRoutine) {
      final stopped =
          !routine.isActive || await controller.toggleRoutine(routine);
      if (!stopped) return;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('루틴을 중지했어요. 기존 일정은 유지됩니다.')),
        );
      }
      return;
    }
    if (scope != _TodoDeleteScope.occurrence) return;
  }
  if (!context.mounted) return;
  await _confirmSingleDelete(context, controller, todo);
}

Future<void> _confirmSingleDelete(
  BuildContext context,
  TodoController controller,
  Todo todo,
) async {
  if (todo.id == null) return;
  final activeSession = controller.activeWorkSession.value;
  final isFocusingThisTodo =
      activeSession?.todoId == todo.id && activeSession?.isCompleted == false;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(isFocusingThisTodo ? '집중을 종료하고 삭제할까요?' : '할 일을 삭제할까요?'),
      content: Text(
        isFocusingThisTodo
            ? '현재까지의 집중 시간을 저장한 후 휴지통으로 이동합니다.'
            : '삭제 후 휴지통에서 다시 복구할 수 있습니다.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          style: AppDialogStyles.cancelAction,
          child: const Text('취소'),
        ),
        FilledButton(
          key: const ValueKey('confirm_delete_button'),
          onPressed: () => Navigator.pop(context, true),
          style: AppDialogStyles.destructiveAction,
          child: Text(isFocusingThisTodo ? '집중 종료 및 삭제' : '삭제'),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  final deleted = await controller.moveToTrash(todo.id!);
  if (!deleted) return;
  if (!context.mounted) return;
  final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: const Text('휴지통으로 이동했어요. 3초 안에 실행 취소할 수 있어요.'),
      duration: const Duration(milliseconds: 2500),
      persist: false,
      action: SnackBarAction(
        label: '실행 취소',
        onPressed: () => controller.restoreTodo(todo.id!),
      ),
    ),
  );
}

enum _TodoEditScope { occurrence, future }

enum _TodoDeleteScope { occurrence, stopRoutine }
