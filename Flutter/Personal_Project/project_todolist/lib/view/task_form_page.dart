import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:project_todolist/controller/todo_controller.dart';
import 'package:project_todolist/model/routine.dart';
import 'package:project_todolist/model/todo.dart';
import 'package:project_todolist/theme/app_theme.dart';
import 'package:project_todolist/view/category_management_page.dart';

/// 새 할 일을 추가하거나 전달받은 할 일을 수정·삭제합니다.
class TaskFormPage extends StatefulWidget {
  const TaskFormPage({
    super.key,
    this.todo,
    this.routine,
    this.initialDate,
    this.initialRepeat = false,
  }) : assert(todo == null || routine == null);

  final Todo? todo;
  final Routine? routine;
  final DateTime? initialDate;
  final bool initialRepeat;

  @override
  State<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  static const _titleMaxLength = 60;
  static const _estimatedOptions = [0, 10, 15, 30, 45, 60, 90, 120];
  static const _weekLabels = ['월', '화', '수', '목', '금', '토', '일'];

  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _memo = TextEditingController();
  late DateTime _dueAt;
  late bool _hasTime;
  late int _priority;
  late String _category;
  late int _estimatedMinutes;
  late _RepeatOption _repeatOption;
  late Set<int> _repeatDays;
  DateTime? _repeatEndDate;
  late final String _initialTitle;
  late final String _initialMemo;
  late final DateTime _initialDueAt;
  late final bool _initialHasTime;
  late final int _initialPriority;
  late final String _initialCategory;
  late final int _initialEstimatedMinutes;
  late final _RepeatOption _initialRepeatOption;
  late final Set<int> _initialRepeatDays;
  late final DateTime? _initialRepeatEndDate;
  bool _isSaving = false;
  bool _allowPop = false;
  bool _detailsExpanded = false;
  int _categoryFieldRevision = 0;

  bool get _isEditingTodo => widget.todo != null;
  bool get _isEditingRoutine => widget.routine != null;
  bool get _isRoutineMode => _repeatOption != _RepeatOption.none;
  bool get _isEditing => _isEditingTodo || _isEditingRoutine;

  /// 수정 화면이면 저장된 값을, 추가 화면이면 기본값을 입력 상태로 설정합니다.
  @override
  void initState() {
    super.initState();
    final todo = widget.todo;
    final routine = widget.routine;
    _title.text = _initialTitle = todo?.title ?? routine?.title ?? '';
    _memo.text = _initialMemo = todo?.memo ?? routine?.memo ?? '';
    final now = DateTime.now();
    final today = DateUtils.dateOnly(now);
    final requestedDate = DateUtils.dateOnly(widget.initialDate ?? now);
    final defaultDate = requestedDate.isBefore(today) ? today : requestedDate;
    final suggestedTime = _nextAvailableMinute(now);
    var defaultDueAt = DateTime(
      defaultDate.year,
      defaultDate.month,
      defaultDate.day,
      suggestedTime.hour,
      suggestedTime.minute,
    );
    if (!defaultDueAt.isAfter(now)) defaultDueAt = suggestedTime;
    _dueAt = _initialDueAt =
        todo?.dueAt ??
        (routine == null
            ? defaultDueAt
            : DateTime(
                routine.startDate.year,
                routine.startDate.month,
                routine.startDate.day,
                routine.scheduledHour,
                routine.scheduledMinute,
              ));
    _hasTime = _initialHasTime = todo?.hasTime ?? routine?.hasTime ?? true;
    _priority = _initialPriority = todo?.priority ?? routine?.priority ?? 1;
    _category = _initialCategory = todo?.category ?? routine?.category ?? '없음';
    _estimatedMinutes = _initialEstimatedMinutes =
        todo?.estimatedMinutes ?? routine?.estimatedMinutes ?? 0;
    _repeatOption = routine == null
        ? (widget.initialRepeat ? _RepeatOption.daily : _RepeatOption.none)
        : _optionForDays(routine.repeatDays);
    _repeatDays = Set.of(
      routine?.repeatDays ??
          (widget.initialRepeat ? {1, 2, 3, 4, 5, 6, 7} : <int>{}),
    );
    _repeatEndDate = routine?.endDate;
    _initialRepeatOption = _repeatOption;
    _initialRepeatDays = Set.of(_repeatDays);
    _initialRepeatEndDate = _repeatEndDate;
    _detailsExpanded =
        _memo.text.isNotEmpty || _priority != 1 || _category != '없음';
  }

  @override
  void dispose() {
    _title.dispose();
    _memo.dispose();
    super.dispose();
  }

  /// 최초 상태와 현재 입력값을 비교해 폐기 확인이 필요한지 판단합니다.
  bool get _hasChanges =>
      _title.text != _initialTitle ||
      _memo.text != _initialMemo ||
      _dueAt != _initialDueAt ||
      _hasTime != _initialHasTime ||
      _priority != _initialPriority ||
      _category != _initialCategory ||
      _estimatedMinutes != _initialEstimatedMinutes ||
      _repeatOption != _initialRepeatOption ||
      !_repeatDays.containsAll(_initialRepeatDays) ||
      !_initialRepeatDays.containsAll(_repeatDays) ||
      _repeatEndDate != _initialRepeatEndDate;

  /// 제목의 공백과 길이를 검증합니다.
  String? _validateTitle(String? value) {
    final title = value?.trim() ?? '';
    if (title.isEmpty) return '공백이 아닌 제목을 입력해 주세요.';
    if (title.length > _titleMaxLength) {
      return '제목은 $_titleMaxLength자 이하로 입력해 주세요.';
    }
    return null;
  }

  /// 신규 일정 또는 수정된 일정이 현재 분 이후인지 확인합니다.
  bool _isInvalidPastSchedule(DateTime schedule) {
    if (_isEditing && schedule == _initialDueAt) return false;
    final now = DateTime.now();
    if (!_hasTime) {
      return DateUtils.dateOnly(schedule).isBefore(DateUtils.dateOnly(now));
    }
    final currentMinute = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
    );
    return !schedule.isAfter(currentMinute);
  }

  static DateTime _nextAvailableMinute(DateTime now) {
    final currentMinute = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
    );
    return currentMinute.add(const Duration(hours: 1));
  }

  /// 반복 설정 유무에 따라 일반 Todo 또는 루틴 템플릿으로 저장합니다.
  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false) || _isSaving) return;
    if (_isInvalidPastSchedule(_dueAt)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('현재 이후의 날짜와 시간을 선택해 주세요.')));
      return;
    }
    setState(() => _isSaving = true);

    final normalizedTitle = _title.text.trim().replaceAll(RegExp(r'\s+'), ' ');
    final savedDueAt = _hasTime ? _dueAt : DateUtils.dateOnly(_dueAt);
    final controller = Get.find<TodoController>();
    var saved = false;
    if (_isRoutineMode) {
      if (_repeatDays.isEmpty) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('반복할 요일을 하나 이상 선택해 주세요.')));
        return;
      }
      final source = widget.routine;
      final routine = Routine(
        id: source?.id,
        title: normalizedTitle,
        memo: _memo.text.trim(),
        category: _category,
        categoryId: source?.categoryId,
        priority: _priority,
        estimatedMinutes: _estimatedMinutes,
        scheduledHour: _dueAt.hour,
        scheduledMinute: _dueAt.minute,
        hasTime: _hasTime,
        repeatDays: _repeatDays,
        startDate: DateUtils.dateOnly(_dueAt),
        endDate: _repeatEndDate,
        isActive: source?.isActive ?? true,
        createdAt: source?.createdAt ?? DateTime.now(),
      );
      if (_isEditingRoutine) {
        saved = await controller.updateRoutine(routine);
      } else {
        saved = await controller.addRoutine(routine);
      }
    } else {
      final original = widget.todo;
      final todo = Todo(
        id: original?.id,
        title: normalizedTitle,
        memo: _memo.text.trim(),
        dueAt: savedDueAt,
        hasTime: _hasTime,
        category: _category,
        categoryId: original?.categoryId,
        priority: _priority,
        estimatedMinutes: _estimatedMinutes,
        isCompleted: original?.isCompleted ?? false,
        routineId: original?.routineId,
        routineDate: original?.routineDate,
        createdAt: original?.createdAt,
        updatedAt: original?.updatedAt,
        completedAt: original?.completedAt,
      );
      if (_isEditingTodo) {
        saved = await controller.updateTodo(todo);
      } else {
        saved = await controller.addTodo(todo);
      }
    }
    if (!mounted) return;
    if (!saved) {
      setState(() => _isSaving = false);
      return;
    }
    _allowPop = true;
    Navigator.of(context).pop();
    Get.snackbar(
      _isEditingTodo || _isEditingRoutine ? '수정 완료' : '저장 완료',
      _isRoutineMode
          ? (_isEditingRoutine ? '이후 반복 일정에 반영됩니다.' : '새 루틴이 등록되었어요.')
          : (_isEditingTodo ? '할 일이 수정되었어요.' : '새 할 일이 목록에 추가되었어요.'),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// 변경된 입력이 있으면 페이지를 닫기 전에 사용자에게 확인받습니다.
  Future<void> _handlePop(bool didPop, Object? result) async {
    if (didPop || _allowPop || !_hasChanges) return;
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('작성 내용을 버릴까요?'),
        content: const Text('저장하지 않은 변경사항이 사라집니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: AppDialogStyles.cancelAction,
            child: const Text('계속 작성'),
          ),
          FilledButton(
            key: const ValueKey('discard_changes_button'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('나가기'),
          ),
        ],
      ),
    );
    if (discard == true && mounted) {
      setState(() => _allowPop = true);
      Navigator.of(context).pop(result);
    }
  }

  /// 카테고리 관리 후 삭제된 선택값은 안전하게 `없음`으로 되돌립니다.
  Future<void> _openCategoryManagement() async {
    setState(() => _categoryFieldRevision++);
    await Get.to(() => const CategoryManagementPage());
    if (!mounted) return;
    final controller = Get.find<TodoController>();
    setState(() {
      _categoryFieldRevision++;
      if (_category != '없음' && !controller.categoryNames.contains(_category)) {
        _category = '없음';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoryNames = Get.find<TodoController>().categoryNames;
    return PopScope<Object?>(
      canPop: _allowPop || !_hasChanges,
      onPopInvokedWithResult: _handlePop,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          leading: IconButton(
            key: const ValueKey('close_task_form_button'),
            tooltip: '닫기',
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.close_rounded),
          ),
          title: Text(
            _isEditingRoutine ? '루틴 수정' : (_isEditingTodo ? '할 일 수정' : '새 할 일'),
          ),
          centerTitle: true,
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.screenPadding,
              AppDimensions.screenPadding,
              AppDimensions.screenPadding,
              32,
            ),
            children: [
              const _Label('제목 *'),
              TextFormField(
                key: const ValueKey('todo_title_field'),
                controller: _title,
                maxLength: _titleMaxLength,
                maxLengthEnforcement: MaxLengthEnforcement.none,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: _validateTitle,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(hintText: '할 일을 입력하세요'),
              ),
              const SizedBox(height: 12),
              const _Label('일정'),
              Row(
                children: [
                  Expanded(
                    child: _SelectionTile(
                      key: const ValueKey('todo_date_button'),
                      icon: Icons.calendar_month_outlined,
                      label: DateFormat('yyyy년 M월 d일 (E)', 'ko').format(_dueAt),
                      onTap: _pickDate,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SelectionTile(
                      key: const ValueKey('todo_time_button'),
                      icon: Icons.schedule_rounded,
                      label: _hasTime
                          ? DateFormat('HH:mm').format(_dueAt)
                          : '시간 없음',
                      onTap: _pickTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const _Label('집중 시간'),
              DropdownButtonFormField<int>(
                key: const ValueKey('estimated_minutes_field'),
                initialValue: _estimatedMinutes,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.timer_outlined),
                ),
                items: _estimatedOptions
                    .map(
                      (minutes) => DropdownMenuItem(
                        value: minutes,
                        child: Text(_formatMinutes(minutes)),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _estimatedMinutes = value!),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 7),
                child: Text(
                  '집중 기능에서 사용할 목표 시간을 설정합니다. 필요하지 않으면 없음으로 두세요.',
                  style: TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ),
              if (!_isEditingTodo) ...[
                const SizedBox(height: 20),
                const _Label('반복 설정'),
                _SelectionTile(
                  key: const ValueKey('repeat_setting_button'),
                  icon: Icons.repeat_rounded,
                  label: _repeatOption.label,
                  onTap: _showRepeatOptions,
                ),
                if (_repeatOption == _RepeatOption.custom) ...[
                  const SizedBox(height: 16),
                  const Text(
                    '반복 요일',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 7,
                    children: List.generate(7, (index) {
                      final weekday = index + 1;
                      return FilterChip(
                        key: ValueKey('todo_repeat_weekday_$weekday'),
                        label: Text(
                          _weekLabels[index],
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        selected: _repeatDays.contains(weekday),
                        onSelected: (selected) => setState(() {
                          selected
                              ? _repeatDays.add(weekday)
                              : _repeatDays.remove(weekday);
                        }),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _SelectionTile(
                          icon: Icons.play_arrow_rounded,
                          label:
                              '시작 ${DateFormat('yyyy.MM.dd').format(_dueAt)}',
                          onTap: _pickDate,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _SelectionTile(
                          key: const ValueKey('repeat_end_date_button'),
                          icon: Icons.flag_outlined,
                          label: _repeatEndDate == null
                              ? '종료일 없음'
                              : DateFormat(
                                  'yyyy.MM.dd',
                                ).format(_repeatEndDate!),
                          onTap: _pickRepeatEndDate,
                        ),
                      ),
                    ],
                  ),
                ],
              ] else if (widget.todo?.routineId != null) ...[
                const SizedBox(height: 20),
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.repeat_rounded, color: AppColors.primary),
                  title: Text('루틴에서 생성된 일정'),
                  subtitle: Text('이 화면의 수정은 현재 일정에만 적용됩니다.'),
                ),
              ],
              const SizedBox(height: 20),
              _DetailsToggle(
                expanded: _detailsExpanded,
                onTap: () =>
                    setState(() => _detailsExpanded = !_detailsExpanded),
              ),
              if (_detailsExpanded) ...[
                const SizedBox(height: 18),
                const _Label('메모'),
                TextField(
                  key: const ValueKey('todo_memo_field'),
                  controller: _memo,
                  maxLines: 4,
                  maxLength: 500,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: '할 일에 필요한 내용을 적어보세요',
                  ),
                ),
                const SizedBox(height: 10),
                const _Label('우선순위'),
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(
                      value: 2,
                      label: _PriorityOptionLabel(
                        color: AppColors.red,
                        label: '높음',
                      ),
                    ),
                    ButtonSegment(
                      value: 1,
                      label: _PriorityOptionLabel(
                        color: AppColors.orange,
                        label: '보통',
                      ),
                    ),
                    ButtonSegment(
                      value: 0,
                      label: _PriorityOptionLabel(
                        color: AppColors.green,
                        label: '낮음',
                      ),
                    ),
                  ],
                  selected: {_priority},
                  showSelectedIcon: false,
                  expandedInsets: EdgeInsets.zero,
                  onSelectionChanged: (value) =>
                      setState(() => _priority = value.first),
                ),
                const SizedBox(height: 20),
                const _Label('카테고리'),
                KeyedSubtree(
                  key: const ValueKey('todo_category_field'),
                  child: DropdownButtonFormField<String>(
                    key: ValueKey(
                      'todo_category_dropdown_${_category}_$_categoryFieldRevision',
                    ),
                    initialValue: _category,
                    items: [
                      ...['없음', ...categoryNames].map(
                        (value) =>
                            DropdownMenuItem(value: value, child: Text(value)),
                      ),
                      const DropdownMenuItem(
                        value: '__manage_categories__',
                        child: Row(
                          children: [
                            Icon(Icons.settings_outlined, size: 19),
                            SizedBox(width: 9),
                            Text('카테고리 관리'),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (value) async {
                      if (value == '__manage_categories__') {
                        await _openCategoryManagement();
                      } else if (value != null) {
                        setState(() => _category = value);
                      }
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.screenPadding,
              12,
              AppDimensions.screenPadding,
              12,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: FilledButton(
              key: const ValueKey('save_todo_button'),
              onPressed: _isSaving ? null : _save,
              child: Text(
                _isSaving
                    ? '저장 중...'
                    : (_isEditingTodo || _isEditingRoutine ? '수정하기' : '저장하기'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final initialDate = DateUtils.dateOnly(_initialDueAt);
    final canKeepPastDate = _isEditing && initialDate.isBefore(today);
    final firstDate = canKeepPastDate ? initialDate : today;
    final lastDate = today.add(const Duration(days: 3650));
    final date = await showDialog<DateTime>(
      context: context,
      builder: (context) => _TodoDatePickerDialog(
        initialDate: DateUtils.dateOnly(_dueAt),
        firstDate: firstDate,
        lastDate: lastDate,
        selectableDayPredicate: (day) =>
            !DateUtils.dateOnly(day).isBefore(today) ||
            (canKeepPastDate && DateUtils.isSameDay(day, initialDate)),
      ),
    );
    if (date != null) {
      setState(() {
        final selectedSchedule = DateTime(
          date.year,
          date.month,
          date.day,
          _dueAt.hour,
          _dueAt.minute,
        );
        _dueAt = _isInvalidPastSchedule(selectedSchedule)
            ? _nextAvailableMinute(DateTime.now())
            : selectedSchedule;
        if (_repeatOption == _RepeatOption.weekly) {
          _repeatDays = {_dueAt.weekday};
        }
        if (_repeatEndDate?.isBefore(DateUtils.dateOnly(_dueAt)) == true) {
          _repeatEndDate = null;
        }
      });
    }
  }

  Future<void> _pickTime() async {
    final selection = await showDialog<_TimeSettingResult>(
      context: context,
      builder: (context) =>
          _TodoTimePickerDialog(initialTime: TimeOfDay.fromDateTime(_dueAt)),
    );
    if (selection == null) return;
    if (!selection.hasTime) {
      setState(() => _hasTime = false);
      return;
    }

    final time = selection.time!;
    if (mounted) {
      final selectedSchedule = DateTime(
        _dueAt.year,
        _dueAt.month,
        _dueAt.day,
        time.hour,
        time.minute,
      );
      if (_isInvalidPastSchedule(selectedSchedule)) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('현재 이후의 시간을 선택해 주세요.')));
        return;
      }
      setState(() {
        _dueAt = selectedSchedule;
        _hasTime = true;
      });
    }
  }

  /// 반복 방식을 하단 시트에서 선택하고 실제 반복 요일로 변환합니다.
  Future<void> _showRepeatOptions() async {
    FocusScope.of(context).unfocus();
    final previousOption = _repeatOption;
    final selected = await showModalBottomSheet<_RepeatOption>(
      context: context,
      builder: (context) => SafeArea(
        child: RadioGroup<_RepeatOption>(
          groupValue: _repeatOption,
          onChanged: (value) => Navigator.pop(context, value),
          child: ListView(
            shrinkWrap: true,
            children: [
              const ListTile(
                title: Text(
                  '반복 설정',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              ..._RepeatOption.values.map(
                (option) => RadioListTile<_RepeatOption>(
                  key: ValueKey('repeat_option_${option.name}'),
                  value: option,
                  title: Text(
                    option.label,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (selected == null) return;
    setState(() {
      _repeatOption = selected;
      _repeatDays = switch (selected) {
        _RepeatOption.none => <int>{},
        _RepeatOption.daily => {1, 2, 3, 4, 5, 6, 7},
        _RepeatOption.weekdays => {1, 2, 3, 4, 5},
        _RepeatOption.weekly => {_dueAt.weekday},
        _RepeatOption.custom =>
          previousOption == _RepeatOption.custom ? _repeatDays : <int>{},
      };
    });
  }

  Future<void> _pickRepeatEndDate() async {
    final start = DateUtils.dateOnly(_dueAt);
    final date = await showDatePicker(
      context: context,
      initialDate: _repeatEndDate ?? start.add(const Duration(days: 30)),
      firstDate: start,
      lastDate: start.add(const Duration(days: 3650)),
    );
    if (date != null) setState(() => _repeatEndDate = date);
  }

  static _RepeatOption _optionForDays(Set<int> days) {
    if (days.length == 7) return _RepeatOption.daily;
    if (days.length == 5 && {1, 2, 3, 4, 5}.every(days.contains)) {
      return _RepeatOption.weekdays;
    }
    if (days.length == 1) return _RepeatOption.weekly;
    return _RepeatOption.custom;
  }

  static String _formatMinutes(int minutes) {
    if (minutes == 0) return '없음';
    if (minutes < 60) return '$minutes분';
    final hours = minutes ~/ 60;
    final remainder = minutes % 60;
    return remainder == 0 ? '$hours시간' : '$hours시간 $remainder분';
  }
}

/// 달력과 자주 쓰는 날짜 바로가기를 한 화면에서 제공하는 전용 다이얼로그입니다.
class _TodoDatePickerDialog extends StatefulWidget {
  const _TodoDatePickerDialog({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.selectableDayPredicate,
  });

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final SelectableDayPredicate selectableDayPredicate;

  @override
  State<_TodoDatePickerDialog> createState() => _TodoDatePickerDialogState();
}

class _TodoDatePickerDialogState extends State<_TodoDatePickerDialog> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  bool _canSelect(DateTime date) {
    final day = DateUtils.dateOnly(date);
    return !day.isBefore(widget.firstDate) &&
        !day.isAfter(widget.lastDate) &&
        widget.selectableDayPredicate(day);
  }

  void _select(DateTime date) {
    if (_canSelect(date)) {
      setState(() => _selectedDate = DateUtils.dateOnly(date));
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateUtils.dateOnly(DateTime.now());
    final daysUntilSunday = DateTime.sunday - today.weekday;
    final shortcuts = <({String label, DateTime date, String key})>[
      (label: '오늘', date: today, key: 'today'),
      (label: '내일', date: today.add(const Duration(days: 1)), key: 'tomorrow'),
      (
        label: '3일 후',
        date: today.add(const Duration(days: 3)),
        key: 'after_3_days',
      ),
      (
        label: '이번 주 일요일',
        date: today.add(Duration(days: daysUntilSunday)),
        key: 'this_sunday',
      ),
    ];

    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      contentPadding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('날짜 설정'),
          const SizedBox(height: 5),
          Text(
            DateFormat('yyyy년 M월 d일 (E)', 'ko').format(_selectedDate),
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 360,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 320,
                child: CalendarDatePicker(
                  key: ValueKey(_selectedDate),
                  initialDate: _selectedDate,
                  firstDate: widget.firstDate,
                  lastDate: widget.lastDate,
                  selectableDayPredicate: widget.selectableDayPredicate,
                  onDateChanged: _select,
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: shortcuts.map((shortcut) {
                    final selected = DateUtils.isSameDay(
                      _selectedDate,
                      shortcut.date,
                    );
                    return ChoiceChip(
                      key: ValueKey('todo_date_shortcut_${shortcut.key}'),
                      label: Text(
                        shortcut.label,
                        style: const TextStyle(color: Colors.black),
                      ),
                      selected: selected,
                      onSelected: _canSelect(shortcut.date)
                          ? (_) => _select(shortcut.date)
                          : null,
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          key: const ValueKey('cancel_todo_date_button'),
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        FilledButton(
          key: const ValueKey('confirm_todo_date_button'),
          onPressed: () => Navigator.pop(context, _selectedDate),
          child: const Text('확인'),
        ),
      ],
    );
  }
}

/// 시간 선택과 시간 제거를 취소 동작과 구분해 전달합니다.
class _TimeSettingResult {
  const _TimeSettingResult.withTime(this.time) : hasTime = true;
  const _TimeSettingResult.withoutTime() : hasTime = false, time = null;

  final bool hasTime;
  final TimeOfDay? time;
}

/// 시각 선택과 `시간 없음`을 한곳에서 제공하는 Todo 전용 다이얼로그입니다.
class _TodoTimePickerDialog extends StatefulWidget {
  const _TodoTimePickerDialog({required this.initialTime});

  final TimeOfDay initialTime;

  @override
  State<_TodoTimePickerDialog> createState() => _TodoTimePickerDialogState();
}

class _TodoTimePickerDialogState extends State<_TodoTimePickerDialog> {
  late int _hour;
  late int _minute;
  bool _selectingHour = true;
  bool _showKeyboardInput = false;

  @override
  void initState() {
    super.initState();
    _hour = widget.initialTime.hour;
    _minute = widget.initialTime.minute;
  }

  bool get _isPm => _hour >= 12;
  int get _displayHour => _hour % 12 == 0 ? 12 : _hour % 12;

  void _setPeriod(bool isPm) {
    setState(() {
      final hour12 = _hour % 12;
      _hour = hour12 + (isPm ? 12 : 0);
    });
  }

  void _setDialValue(int value) {
    setState(() {
      if (_selectingHour) {
        final hour12 = value == 12 ? 0 : value;
        _hour = hour12 + (_isPm ? 12 : 0);
        _selectingHour = false;
      } else {
        _minute = value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const quickTimes = [
      (label: '오전 7:00', hour: 7),
      (label: '오전 9:00', hour: 9),
      (label: '오전 10:00', hour: 10),
      (label: '오후 12:00', hour: 12),
      (label: '오후 2:00', hour: 14),
      (label: '오후 4:00', hour: 16),
      (label: '오후 6:00', hour: 18),
    ];

    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      contentPadding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      title: const Text('시간 설정'),
      content: SizedBox(
        width: 340,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        _TimeHeaderValue(
                          key: const ValueKey('todo_time_hour_header'),
                          value: _displayHour.toString().padLeft(2, '0'),
                          selected: _selectingHour,
                          onTap: () => setState(() => _selectingHour = true),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: Text(
                            ':',
                            style: TextStyle(
                              color: AppColors.ink,
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        _TimeHeaderValue(
                          key: const ValueKey('todo_time_minute_header'),
                          value: _minute.toString().padLeft(2, '0'),
                          selected: !_selectingHour,
                          onTap: () => setState(() => _selectingHour = false),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        _PeriodButton(
                          label: '오전',
                          selected: !_isPm,
                          onTap: () => _setPeriod(false),
                        ),
                        _PeriodButton(
                          label: '오후',
                          selected: _isPm,
                          onTap: () => _setPeriod(true),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: _showKeyboardInput
                    ? _TimeNumberInput(
                        key: const ValueKey('todo_time_number_input'),
                        hour: _hour,
                        minute: _minute,
                        onHourChanged: (value) => setState(() => _hour = value),
                        onMinuteChanged: (value) =>
                            setState(() => _minute = value),
                      )
                    : _AnalogTimeDial(
                        key: ValueKey('todo_time_dial_$_selectingHour'),
                        selectingHour: _selectingHour,
                        value: _selectingHour ? _displayHour : _minute,
                        onChanged: _setDialValue,
                      ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  key: const ValueKey('toggle_todo_time_input_mode'),
                  tooltip: _showKeyboardInput ? '시계로 선택' : '숫자로 선택',
                  onPressed: () =>
                      setState(() => _showKeyboardInput = !_showKeyboardInput),
                  icon: Icon(
                    _showKeyboardInput
                        ? Icons.schedule_rounded
                        : Icons.keyboard_alt_outlined,
                    color: AppColors.muted,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                '빠른 선택',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ActionChip(
                    key: const ValueKey('todo_time_none_button'),
                    avatar: const Icon(
                      Icons.schedule_outlined,
                      size: 17,
                      color: Colors.black,
                    ),
                    label: const Text(
                      '시간 없음',
                      style: TextStyle(color: Colors.black),
                    ),
                    onPressed: () => Navigator.pop(
                      context,
                      const _TimeSettingResult.withoutTime(),
                    ),
                  ),
                  ...quickTimes.map(
                    (quickTime) => ChoiceChip(
                      key: ValueKey('todo_quick_time_${quickTime.hour}'),
                      label: Text(
                        quickTime.label,
                        style: const TextStyle(color: Colors.black),
                      ),
                      selected: _hour == quickTime.hour && _minute == 0,
                      onSelected: (_) => setState(() {
                        _hour = quickTime.hour;
                        _minute = 0;
                      }),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          key: const ValueKey('cancel_todo_time_button'),
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        FilledButton(
          key: const ValueKey('confirm_todo_time_button'),
          onPressed: () => Navigator.pop(
            context,
            _TimeSettingResult.withTime(
              TimeOfDay(hour: _hour, minute: _minute),
            ),
          ),
          child: const Text('확인'),
        ),
      ],
    );
  }
}

class _TimeHeaderValue extends StatelessWidget {
  const _TimeHeaderValue({
    super.key,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final String value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(10),
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: selected
            ? AppColors.primary.withValues(alpha: .12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        value,
        style: TextStyle(
          color: selected ? AppColors.primary : AppColors.muted,
          fontSize: 36,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  );
}

class _PeriodButton extends StatelessWidget {
  const _PeriodButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 54,
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: selected ? AppColors.primary : Colors.white,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: selected ? Colors.white : AppColors.muted,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  );
}

/// 드래그하거나 숫자를 눌러 시와 분을 선택하는 아날로그 다이얼입니다.
class _AnalogTimeDial extends StatelessWidget {
  const _AnalogTimeDial({
    super.key,
    required this.selectingHour,
    required this.value,
    required this.onChanged,
  });

  final bool selectingHour;
  final int value;
  final ValueChanged<int> onChanged;

  void _updateValue(Offset position, Size size) {
    final center = size.center(Offset.zero);
    final offset = position - center;
    var angle = math.atan2(offset.dx, -offset.dy);
    if (angle < 0) angle += math.pi * 2;
    if (selectingHour) {
      final selected = (angle / (math.pi * 2) * 12).round() % 12;
      onChanged(selected == 0 ? 12 : selected);
    } else {
      onChanged((angle / (math.pi * 2) * 60).round() % 60);
    }
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final side = math.min(constraints.maxWidth, 270.0);
      final size = Size.square(side);
      return Center(
        child: Semantics(
          label: selectingHour ? '시간 선택 시계판' : '분 선택 시계판',
          child: GestureDetector(
            key: const ValueKey('todo_analog_time_dial'),
            behavior: HitTestBehavior.opaque,
            onTapUp: (details) => _updateValue(details.localPosition, size),
            onPanUpdate: (details) => _updateValue(details.localPosition, size),
            child: CustomPaint(
              size: size,
              painter: _AnalogTimeDialPainter(
                selectingHour: selectingHour,
                value: value,
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _AnalogTimeDialPainter extends CustomPainter {
  const _AnalogTimeDialPainter({
    required this.selectingHour,
    required this.value,
  });

  final bool selectingHour;
  final int value;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    canvas.drawCircle(center, radius, Paint()..color = AppColors.surface);

    final units = selectingHour ? 12 : 60;
    final normalized = selectingHour ? value % 12 : value;
    final angle = normalized / units * math.pi * 2 - math.pi / 2;
    final handEnd =
        center + Offset(math.cos(angle), math.sin(angle)) * (radius - 34);
    canvas.drawLine(
      center,
      handEnd,
      Paint()
        ..color = AppColors.primary
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(handEnd, 22, Paint()..color = AppColors.primary);
    canvas.drawCircle(center, 5, Paint()..color = AppColors.primary);

    final labels = selectingHour
        ? List.generate(12, (index) => index == 0 ? 12 : index)
        : List.generate(12, (index) => index * 5);
    for (var index = 0; index < labels.length; index++) {
      final labelAngle = index / 12 * math.pi * 2 - math.pi / 2;
      final labelCenter =
          center +
          Offset(math.cos(labelAngle), math.sin(labelAngle)) * (radius - 26);
      final isSelected =
          labels[index] ==
          (selectingHour ? (value == 12 ? 12 : value) : value ~/ 5 * 5);
      final painter = TextPainter(
        text: TextSpan(
          text: selectingHour
              ? '${labels[index]}'
              : labels[index].toString().padLeft(2, '0'),
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.ink,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      painter.paint(
        canvas,
        labelCenter - Offset(painter.width / 2, painter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AnalogTimeDialPainter oldDelegate) =>
      oldDelegate.selectingHour != selectingHour || oldDelegate.value != value;
}

class _TimeNumberInput extends StatelessWidget {
  const _TimeNumberInput({
    super.key,
    required this.hour,
    required this.minute,
    required this.onHourChanged,
    required this.onMinuteChanged,
  });

  final int hour;
  final int minute;
  final ValueChanged<int> onHourChanged;
  final ValueChanged<int> onMinuteChanged;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 270,
    child: Center(
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<int>(
              key: const ValueKey('todo_time_hour_field'),
              initialValue: hour,
              menuMaxHeight: 280,
              decoration: const InputDecoration(labelText: '시'),
              items: List.generate(
                24,
                (value) => DropdownMenuItem(
                  value: value,
                  child: Text(value.toString().padLeft(2, '0')),
                ),
              ),
              onChanged: (value) => onHourChanged(value!),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(':', style: TextStyle(fontSize: 22)),
          ),
          Expanded(
            child: DropdownButtonFormField<int>(
              key: const ValueKey('todo_time_minute_field'),
              initialValue: minute,
              menuMaxHeight: 280,
              decoration: const InputDecoration(labelText: '분'),
              items: List.generate(
                60,
                (value) => DropdownMenuItem(
                  value: value,
                  child: Text(value.toString().padLeft(2, '0')),
                ),
              ),
              onChanged: (value) => onMinuteChanged(value!),
            ),
          ),
        ],
      ),
    ),
  );
}

enum _RepeatOption { none, daily, weekdays, weekly, custom }

extension on _RepeatOption {
  String get label => switch (this) {
    _RepeatOption.none => '사용 안 함',
    _RepeatOption.daily => '매일',
    _RepeatOption.weekdays => '평일',
    _RepeatOption.weekly => '매주',
    _RepeatOption.custom => '사용자 지정',
  };
}

/// 자주 사용하지 않는 입력을 접어 기본 등록 화면의 정보량을 줄입니다.
class _DetailsToggle extends StatelessWidget {
  const _DetailsToggle({required this.expanded, required this.onTap});

  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
      side: const BorderSide(color: AppColors.border),
    ),
    child: InkWell(
      key: const ValueKey('todo_details_toggle'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            const Icon(Icons.tune_rounded, color: AppColors.primary, size: 20),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                '세부 설정',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            Text(
              expanded ? '접기' : '펼치기',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              expanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    ),
  );
}

class _SelectionTile extends StatelessWidget {
  const _SelectionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(14),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    ),
  );
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.w800)),
  );
}

/// 좁은 화면에서도 색상과 텍스트를 함께 보여 주는 우선순위 라벨입니다.
class _PriorityOptionLabel extends StatelessWidget {
  const _PriorityOptionLabel({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 6),
      Text(label, maxLines: 1, overflow: TextOverflow.fade, softWrap: false),
    ],
  );
}
