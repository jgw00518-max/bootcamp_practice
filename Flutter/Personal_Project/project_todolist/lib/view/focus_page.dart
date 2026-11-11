import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_todolist/controller/todo_controller.dart';
import 'package:project_todolist/model/todo.dart';
import 'package:project_todolist/model/work_session.dart';
import 'package:project_todolist/theme/app_theme.dart';

/// SQLite 집중 세션을 제어하고 앱 재개 시 종료 시각으로 타이머를 보정합니다.
class FocusPage extends StatefulWidget {
  const FocusPage({super.key});

  @override
  State<FocusPage> createState() => _FocusPageState();
}

class _FocusPageState extends State<FocusPage> with WidgetsBindingObserver {
  late final TodoController _controller;
  Timer? _ticker;
  Worker? _sessionWorker;
  bool _isCompleting = false;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<TodoController>();
    WidgetsBinding.instance.addObserver(this);
    _sessionWorker = ever<WorkSession?>(_controller.activeWorkSession, (_) {
      _syncTicker();
      if (mounted) setState(() {});
    });
    _syncTicker();
  }

  void _syncTicker() {
    _ticker?.cancel();
    _ticker = null;
    if (_controller.activeWorkSession.value?.isRunning == true) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    }
  }

  /// 시스템 시계로 남은 시간을 다시 계산해 백그라운드 경과를 반영합니다.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _controller.syncFocusSession();
      if (mounted) setState(() {});
    }
  }

  void _tick() {
    if (!mounted) return;
    final session = _controller.activeWorkSession.value;
    if (session?.isRunning == true &&
        session!.remainingAt(DateTime.now()) == 0) {
      if (!_isCompleting) {
        _isCompleting = true;
        _finishAndPrompt(session).whenComplete(() => _isCompleting = false);
      }
    }
    setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sessionWorker?.dispose();
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _toggleTimer() async {
    final session = _controller.activeWorkSession.value;
    if (session?.isRunning == true) {
      await _controller.pauseFocus();
    } else if (session?.isPaused == true) {
      await _controller.resumeFocus();
    } else {
      final todoId = _controller.selectedFocusTodoId.value;
      if (todoId == null) {
        Get.snackbar('할 일을 선택해 주세요', '집중할 Todo를 먼저 선택해 주세요.');
        return;
      }
      final todo = _todoById(todoId);
      if (todo == null) return;
      final remaining = _controller.remainingEstimatedSecondsFor(todo);
      if (remaining == 0) {
        Get.snackbar('목표 집중 완료', '설정한 집중 시간을 모두 채웠어요. 할 일 완료 여부를 확인해 주세요.');
        return;
      }
      await _controller.startFocus(todoId: todoId, plannedSeconds: remaining);
    }
    if (mounted) setState(() {});
  }

  Future<void> _complete() async {
    final session = _controller.activeWorkSession.value;
    if (session != null) await _finishAndPrompt(session);
  }

  /// 세션 기록을 확정한 뒤 Todo 완료 또는 다음 집중 행동을 선택받습니다.
  Future<void> _finishAndPrompt(WorkSession session) async {
    final completed = await _controller.completeFocus();
    if (!completed) return;
    if (!mounted) return;
    final completedSession = _controller.workSessions.firstWhereOrNull(
      (value) => value.id == session.id,
    );
    final actualText = _formatDuration(
      completedSession?.elapsedSeconds ?? session.elapsedSeconds,
    );
    final sessionTodo = _todoById(session.todoId);
    final canContinue =
        sessionTodo != null &&
        !sessionTodo.isCompleted &&
        _controller.remainingEstimatedSecondsFor(sessionTodo) > 0;
    setState(() {});
    final action = await showDialog<_CompletionAction>(
      context: context,
      builder: (context) => AlertDialog(
        key: const ValueKey('focus_completion_dialog'),
        iconPadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        icon: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.green.withValues(alpha: .12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: AppColors.green,
              size: 26,
            ),
          ),
        ),
        titlePadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        title: const Text('집중을 완료했어요'),
        contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.timer_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      '이번 집중 기록',
                      style: TextStyle(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    actualText,
                    key: const ValueKey('focus_completion_actual_time'),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Text('집중 기록을 저장했습니다. 다음 행동을 선택해 주세요.'),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (canContinue) ...[
                  FilledButton.icon(
                    key: const ValueKey('focus_complete_again'),
                    onPressed: () =>
                        Navigator.pop(context, _CompletionAction.again),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('남은 시간 이어서 집중'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    key: const ValueKey('focus_complete_todo'),
                    onPressed: () =>
                        Navigator.pop(context, _CompletionAction.completeTodo),
                    icon: const Icon(Icons.task_alt_rounded),
                    label: const Text('할 일 완료'),
                  ),
                ] else
                  FilledButton.icon(
                    key: const ValueKey('focus_complete_todo'),
                    onPressed: () =>
                        Navigator.pop(context, _CompletionAction.completeTodo),
                    icon: const Icon(Icons.task_alt_rounded),
                    label: const Text('할 일 완료'),
                  ),
                const SizedBox(height: 4),
                TextButton(
                  key: const ValueKey('focus_complete_later'),
                  onPressed: () =>
                      Navigator.pop(context, _CompletionAction.later),
                  style: AppDialogStyles.cancelAction,
                  child: const Text('닫기'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    if (action == _CompletionAction.completeTodo) {
      final todo = _todoById(session.todoId);
      if (todo != null && !todo.isCompleted) await _controller.toggle(todo);
    } else if (action == _CompletionAction.again) {
      final todo = _todoById(session.todoId);
      if (todo != null && !todo.isCompleted) {
        final remaining = _controller.remainingEstimatedSecondsFor(todo);
        if (remaining > 0) {
          await _controller.startFocus(
            todoId: session.todoId,
            plannedSeconds: remaining,
          );
        }
      }
    }
  }

  Todo? _todoById(int id) {
    for (final todo in _controller.todos) {
      if (todo.id == id) return todo;
    }
    return null;
  }

  /// Todo 선택 시 저장된 완료 세션을 기준으로 남은 시간을 다시 표시합니다.
  void _selectTodo(int? todoId) {
    _controller.selectedFocusTodoId.value = todoId;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final session = _controller.activeWorkSession.value;
      final selectedId =
          _controller.focusEligibleTodos.any(
            (todo) => todo.id == _controller.selectedFocusTodoId.value,
          )
          ? _controller.selectedFocusTodoId.value
          : null;
      final selectedTodo = _controller.selectedFocusTodo;
      final focusedSeconds = selectedTodo?.id == null
          ? 0
          : _controller.focusSecondsForTodo(selectedTodo!.id!);
      final remainingEstimatedSeconds = selectedTodo?.id == null
          ? 0
          : _controller.remainingEstimatedSecondsFor(selectedTodo!);
      final total = session?.plannedSeconds ?? remainingEstimatedSeconds;
      final remaining = session?.remainingAt(DateTime.now()) ?? total;
      final expectedMinutes = _controller.todayTodos.fold<int>(
        0,
        (sum, todo) => sum + todo.estimatedMinutes,
      );

      return ListView(
        key: const ValueKey('focus_page_list'),
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.screenPadding,
          18,
          AppDimensions.screenPadding,
          30,
        ),
        children: [
          Row(
            children: [
              Text('집중', style: Theme.of(context).textTheme.headlineSmall),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final menuWidth = (constraints.maxWidth - 24)
                  .clamp(240.0, 340.0)
                  .toDouble();
              return PopupMenuButton<int>(
                key: const ValueKey('focus_todo_selector'),
                initialValue: selectedId,
                enabled:
                    session == null &&
                    _controller.focusEligibleTodos.isNotEmpty,
                position: PopupMenuPosition.under,
                offset: const Offset(0, 8),
                color: Colors.white,
                surfaceTintColor: Colors.transparent,
                elevation: 8,
                constraints: BoxConstraints.tightFor(width: menuWidth),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppColors.border),
                ),
                onSelected: _selectTodo,
                itemBuilder: (context) => _controller.focusEligibleTodos
                    .map(
                      (todo) => PopupMenuItem<int>(
                        key: ValueKey('focus_todo_option_${todo.id}'),
                        value: todo.id,
                        height: 64,
                        child: _FocusTodoOption(
                          todo: todo,
                          remainingText: _formatDuration(
                            _controller.remainingEstimatedSecondsFor(todo),
                          ),
                          selected: todo.id == selectedId,
                        ),
                      ),
                    )
                    .toList(),
                child: _FocusTodoSelector(
                  todo: selectedTodo,
                  enabled:
                      session == null &&
                      _controller.focusEligibleTodos.isNotEmpty,
                  remainingText: selectedTodo == null
                      ? null
                      : _formatDuration(remainingEstimatedSeconds),
                ),
              );
            },
          ),
          if (selectedTodo != null) ...[
            const SizedBox(height: 14),
            _TodoFocusProgress(
              expectedSeconds: selectedTodo.estimatedMinutes * 60,
              focusedSeconds: focusedSeconds,
              remainingSeconds: remainingEstimatedSeconds,
            ),
            const SizedBox(height: 10),
            Container(
              key: const ValueKey('remaining_focus_time'),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timelapse_rounded, color: AppColors.primary),
                  const SizedBox(width: 9),
                  const Expanded(
                    child: Text(
                      '이번에 이어서 집중할 시간',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text(
                    _formatDuration(remainingEstimatedSeconds),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          Center(
            child: SizedBox(
              width: 245,
              height: 245,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: total == 0 ? 0 : remaining / total,
                      strokeWidth: 10,
                      backgroundColor: const Color(0xFFE7E6FF),
                      color: AppColors.primary,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatClock(remaining),
                        key: const ValueKey('focus_remaining_time'),
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _statusText(session),
                        style: const TextStyle(color: AppColors.muted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton.tonalIcon(
                key: const ValueKey('focus_toggle_button'),
                onPressed: _controller.isStartingFocus.value
                    ? null
                    : _toggleTimer,
                icon: Icon(
                  session?.isRunning == true
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                ),
                label: Text(
                  session?.isRunning == true
                      ? '일시정지'
                      : session?.isPaused == true
                      ? '계속하기'
                      : '집중 시작',
                ),
              ),
              if (session != null) ...[
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  key: const ValueKey('focus_complete_button'),
                  onPressed: _complete,
                  icon: const Icon(Icons.stop_circle_outlined),
                  label: const Text('집중 완료'),
                ),
              ],
            ],
          ),
          const SizedBox(height: 34),
          Row(
            children: [
              const Text(
                '오늘의 계획',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
              ),
              const Spacer(),
              Text(
                '${_controller.todayTodos.where((todo) => todo.isCompleted).length}/${_controller.todayTodos.length} 완료',
                style: const TextStyle(color: AppColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._controller.todayTodos.map((todo) {
            final estimateReached =
                !todo.isCompleted &&
                todo.estimatedMinutes > 0 &&
                _controller.remainingEstimatedSecondsFor(todo) == 0;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(AppDimensions.cardPadding),
              decoration: BoxDecoration(
                border: Border.all(
                  color: todo.id == _controller.selectedFocusTodoId.value
                      ? AppColors.primary
                      : AppColors.border,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(
                    todo.isCompleted
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                    color: todo.isCompleted
                        ? AppColors.primary
                        : AppColors.muted,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      todo.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    todo.estimatedMinutes == 0
                        ? '집중 시간 없음'
                        : estimateReached
                        ? '목표 시간 달성'
                        : '목표 ${todo.estimatedMinutes}분',
                    key: estimateReached
                        ? ValueKey('focus_estimate_reached_${todo.id}')
                        : null,
                    style: TextStyle(
                      color: estimateReached
                          ? AppColors.primary
                          : AppColors.muted,
                      fontSize: 12,
                      fontWeight: estimateReached
                          ? FontWeight.w700
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(AppDimensions.cardPadding),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _FocusSummary(
                    value: _formatDuration(expectedMinutes * 60),
                    label: '오늘 목표 집중',
                  ),
                ),
                const SizedBox(height: 45, child: VerticalDivider()),
                Expanded(
                  child: _FocusSummary(
                    value: _formatDuration(_controller.todayFocusSeconds),
                    label: '오늘 실제 집중',
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  String _statusText(WorkSession? session) {
    if (session?.isRunning == true) return '집중 시간이 기록되고 있어요';
    if (session?.isPaused == true) return '일시정지된 집중 세션';
    return '집중할 준비가 되었나요?';
  }

  String _formatClock(int seconds) =>
      '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    if (minutes < 60) return '$minutes분';
    return '${minutes ~/ 60}시간 ${minutes % 60}분';
  }
}

/// 선택된 집중 Todo를 다른 카드들과 같은 테두리·여백으로 표시합니다.
class _FocusTodoSelector extends StatelessWidget {
  const _FocusTodoSelector({
    required this.todo,
    required this.enabled,
    required this.remainingText,
  });

  final Todo? todo;
  final bool enabled;
  final String? remainingText;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
    decoration: BoxDecoration(
      color: enabled ? Colors.white : AppColors.surface,
      border: Border.all(
        color: todo == null ? AppColors.border : AppColors.primary,
      ),
      borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
    ),
    child: Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: .1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.center_focus_strong_rounded,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '집중할 할 일',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                todo?.title ?? (enabled ? '할 일을 선택해 주세요' : '집중할 할 일이 없어요'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        if (remainingText != null) ...[
          const SizedBox(width: 10),
          Text(
            remainingText!,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
        const SizedBox(width: 4),
        Icon(
          Icons.keyboard_arrow_down_rounded,
          color: enabled ? AppColors.muted : AppColors.border,
        ),
      ],
    ),
  );
}

/// 팝업 메뉴에서 Todo 제목과 남은 예상 시간을 한 행으로 비교하게 합니다.
class _FocusTodoOption extends StatelessWidget {
  const _FocusTodoOption({
    required this.todo,
    required this.remainingText,
    required this.selected,
  });

  final Todo todo;
  final String remainingText;
  final bool selected;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(
        selected ? Icons.check_circle_rounded : Icons.circle_outlined,
        color: selected ? AppColors.primary : AppColors.muted,
        size: 20,
      ),
      const SizedBox(width: 11),
      Expanded(
        child: Text(
          todo.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColors.ink,
            fontSize: 14,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
          ),
        ),
      ),
      const SizedBox(width: 10),
      Text(
        '남음 $remainingText',
        style: const TextStyle(
          color: AppColors.muted,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

class _FocusSummary extends StatelessWidget {
  const _FocusSummary({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
      const SizedBox(height: 6),
      Text(
        value,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
      ),
    ],
  );
}

/// 선택한 Todo의 예상 시간과 완료 집중 세션 누계를 비교해 보여줍니다.
class _TodoFocusProgress extends StatelessWidget {
  const _TodoFocusProgress({
    required this.expectedSeconds,
    required this.focusedSeconds,
    required this.remainingSeconds,
  });

  final int expectedSeconds;
  final int focusedSeconds;
  final int remainingSeconds;

  @override
  Widget build(BuildContext context) {
    final progress = expectedSeconds == 0
        ? 0.0
        : focusedSeconds / expectedSeconds;
    return Container(
      key: const ValueKey('todo_focus_progress'),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _ProgressValue(label: '목표 집중', value: _format(expectedSeconds)),
              _ProgressValue(label: '누적 집중', value: _format(focusedSeconds)),
              _ProgressValue(
                label: remainingSeconds == 0 ? '목표 충족' : '남은 집중',
                value: _format(remainingSeconds),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress.clamp(0, 1),
            minHeight: 7,
            borderRadius: BorderRadius.circular(8),
            backgroundColor: const Color(0xFFE7E6FF),
          ),
          const SizedBox(height: 7),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              progress > 1
                  ? '목표보다 ${_format(focusedSeconds - expectedSeconds)} 더 집중했어요.'
                  : '목표 대비 ${(progress * 100).round()}%',
              style: const TextStyle(fontSize: 11, color: AppColors.muted),
            ),
          ),
        ],
      ),
    );
  }

  static String _format(int seconds) {
    final minutes = seconds ~/ 60;
    if (minutes < 60) return '$minutes분';
    final remainder = minutes % 60;
    return remainder == 0
        ? '${minutes ~/ 60}시간'
        : '${minutes ~/ 60}시간 $remainder분';
  }
}

class _ProgressValue extends StatelessWidget {
  const _ProgressValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.muted),
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    ),
  );
}

enum _CompletionAction { completeTodo, again, later }
