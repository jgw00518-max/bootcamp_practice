import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:project_todolist/controller/todo_controller.dart';
import 'package:project_todolist/model/routine.dart';
import 'package:project_todolist/model/todo.dart';
import 'package:project_todolist/theme/app_theme.dart';
import 'package:project_todolist/view/task_form_page.dart';
import 'package:project_todolist/view/todo_action_dialogs.dart';
import 'package:project_todolist/widget/todo_card.dart';
import 'package:table_calendar/table_calendar.dart';

/// 캘린더 전용 검색·필터를 날짜 마커와 일정 목록에 함께 적용합니다.
class CalendarPage extends GetView<TodoController> {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) => Obx(() {
    final selected = controller.selectedDay.value;
    final events = controller.calendarTodosFor(selected);
    final routinePreviews = controller.calendarRoutinePreviewsFor(selected);
    final originalEvents = controller.todosFor(selected);
    final now = controller.currentTime.value;
    final completedCount = events.where((todo) => todo.isCompleted).length;
    final incompleteCount = events.length - completedCount;
    final query = controller.calendarSearchQuery.value.trim();
    final searchResults = query.isEmpty
        ? const <Todo>[]
        : controller.calendarFilteredTodos;

    return ListView(
      key: const ValueKey('calendar_page_list'),
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.screenPadding,
        18,
        AppDimensions.screenPadding,
        100,
      ),
      children: [
        Row(
          children: [
            Text('캘린더', style: Theme.of(context).textTheme.headlineSmall),
            const Spacer(),
            IconButton(
              key: const ValueKey('calendar_search_button'),
              tooltip: '일정 검색',
              onPressed: () {
                controller.isCalendarSearchOpen.toggle();
                if (!controller.isCalendarSearchOpen.value) {
                  controller.clearCalendarSearch();
                }
              },
              icon: Icon(
                controller.isCalendarSearchOpen.value
                    ? Icons.close_rounded
                    : Icons.search_rounded,
              ),
            ),
            IconButton(
              key: const ValueKey('calendar_filter_button'),
              tooltip: '캘린더 필터',
              onPressed: () => _showFilters(context),
              icon: Badge(
                isLabelVisible: controller.hasCalendarFilter,
                label: Text('${controller.calendarFilterCount}'),
                child: const Icon(Icons.tune_rounded),
              ),
            ),
          ],
        ),
        if (controller.isCalendarSearchOpen.value) ...[
          const SizedBox(height: 10),
          TextField(
            key: const ValueKey('calendar_search_field'),
            controller: controller.calendarSearchTextController,
            autofocus: true,
            onChanged: (value) => controller.calendarSearchQuery.value = value,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search_rounded),
              hintText: '제목, 메모 또는 카테고리 검색...',
              suffixIcon: query.isEmpty
                  ? null
                  : IconButton(
                      key: const ValueKey('clear_calendar_search'),
                      onPressed: controller.clearCalendarSearch,
                      icon: const Icon(Icons.close_rounded),
                    ),
            ),
          ),
          if (query.isNotEmpty) ...[
            const SizedBox(height: 10),
            _SearchResults(
              query: query,
              results: searchResults,
              onSelected: (todo) {
                controller.selectedDay.value = todo.dueAt;
                FocusScope.of(context).unfocus();
              },
            ),
          ],
        ],
        const SizedBox(height: 10),
        const _CalendarLegend(),
        const SizedBox(height: 8),
        TableCalendar<Todo>(
          locale: 'ko_KR',
          firstDay: DateTime.utc(2020),
          lastDay: DateTime.utc(2035),
          focusedDay: selected,
          selectedDayPredicate: (day) => isSameDay(day, selected),
          eventLoader: controller.calendarTodosFor,
          onDaySelected: (day, focused) => controller.selectedDay.value = day,
          calendarBuilders: CalendarBuilders<Todo>(
            markerBuilder: (context, day, todos) => _CalendarMarker(
              day: day,
              todos: todos,
              now: now,
              hasRoutinePreview: controller
                  .calendarRoutinePreviewsFor(day)
                  .isNotEmpty,
            ),
          ),
          headerStyle: const HeaderStyle(
            titleCentered: false,
            formatButtonVisible: false,
            titleTextStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: .18),
              shape: BoxShape.circle,
            ),
            todayTextStyle: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
            selectedDecoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(AppDimensions.cardPadding),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${DateFormat('M월 d일 (E)', 'ko').format(selected)} 일정',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              if (events.isNotEmpty || routinePreviews.isNotEmpty) ...[
                const SizedBox(height: 5),
                Text(
                  '총 ${events.length + routinePreviews.length}개 · 완료 $completedCount개 · 남음 ${incompleteCount + routinePreviews.length}개',
                  key: const ValueKey('selected_day_todo_summary'),
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              if (events.isEmpty && routinePreviews.isEmpty)
                _CalendarEmpty(
                  filtered:
                      originalEvents.isNotEmpty ||
                      query.isNotEmpty ||
                      controller.hasCalendarFilter,
                  onReset: controller.clearCalendarConditions,
                )
              else
                ...events.map(
                  (todo) => TodoCard(
                    todo: todo,
                    isEndedRoutine:
                        todo.routineId != null &&
                        controller.routines.every(
                          (routine) => routine.id != todo.routineId,
                        ),
                    onToggle: () => controller.toggle(todo),
                    onTap: () => openTodoEditor(context, todo),
                    onDelete: () => deleteTodoWithScope(context, todo),
                  ),
                ),
              ...routinePreviews.map(
                (routine) => _RoutinePreviewCard(
                  routine: routine,
                  selectedDay: selected,
                  onTap: () => Get.to(
                    () => TaskFormPage(routine: routine, initialRepeat: true),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  });

  /// 필터는 임시 선택 후 적용 버튼을 눌렀을 때 캘린더 상태에 반영합니다.
  Future<void> _showFilters(BuildContext context) async {
    var status = controller.calendarStatusFilter.value;
    var priority = controller.calendarPriorityFilter.value;
    var category = controller.calendarCategoryFilter.value;
    var type = controller.calendarTodoTypeFilter.value;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setModalState) => SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '캘린더 필터',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 20),
                const _FilterLabel('상태'),
                Wrap(
                  spacing: 8,
                  children: [
                    _FilterChoice(
                      key: const ValueKey('calendar_status_all'),
                      label: '전체',
                      selected: status == CalendarStatusFilter.all,
                      onTap: () => setModalState(
                        () => status = CalendarStatusFilter.all,
                      ),
                    ),
                    _FilterChoice(
                      key: const ValueKey('calendar_status_incomplete'),
                      label: '미완료',
                      selected: status == CalendarStatusFilter.incomplete,
                      onTap: () => setModalState(
                        () => status = CalendarStatusFilter.incomplete,
                      ),
                    ),
                    _FilterChoice(
                      key: const ValueKey('calendar_status_completed'),
                      label: '완료',
                      selected: status == CalendarStatusFilter.completed,
                      onTap: () => setModalState(
                        () => status = CalendarStatusFilter.completed,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const _FilterLabel('일정 종류'),
                Wrap(
                  spacing: 8,
                  children: CalendarTodoTypeFilter.values.map((value) {
                    final label = switch (value) {
                      CalendarTodoTypeFilter.all => '전체',
                      CalendarTodoTypeFilter.normal => '일반 할 일',
                      CalendarTodoTypeFilter.routine => '루틴',
                    };
                    return _FilterChoice(
                      key: ValueKey('calendar_type_${value.name}'),
                      label: label,
                      selected: type == value,
                      onTap: () => setModalState(() => type = value),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const _FilterLabel('우선순위'),
                Wrap(
                  spacing: 8,
                  children: [
                    _FilterChoice(
                      key: const ValueKey('calendar_priority_all'),
                      label: '전체',
                      selected: priority == null,
                      onTap: () => setModalState(() => priority = null),
                    ),
                    ...[(2, '높음'), (1, '보통'), (0, '낮음')].map(
                      (option) => _FilterChoice(
                        key: ValueKey('calendar_priority_${option.$1}'),
                        label: option.$2,
                        selected: priority == option.$1,
                        onTap: () => setModalState(() => priority = option.$1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const _FilterLabel('카테고리'),
                Wrap(
                  spacing: 8,
                  children: ['전체', '없음', ...controller.categoryNames].map((
                    value,
                  ) {
                    final selectedValue = value == '전체' ? null : value;
                    return _FilterChoice(
                      key: ValueKey(
                        'calendar_category_${selectedValue ?? 'all'}',
                      ),
                      label: value,
                      selected: category == selectedValue,
                      onTap: () =>
                          setModalState(() => category = selectedValue),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        key: const ValueKey('reset_calendar_filters'),
                        onPressed: () => setModalState(() {
                          status = CalendarStatusFilter.all;
                          priority = null;
                          category = null;
                          type = CalendarTodoTypeFilter.all;
                        }),
                        child: const Text('초기화'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        key: const ValueKey('apply_calendar_filters'),
                        onPressed: () {
                          controller.calendarStatusFilter.value = status;
                          controller.calendarPriorityFilter.value = priority;
                          controller.calendarCategoryFilter.value = category;
                          controller.calendarTodoTypeFilter.value = type;
                          Navigator.pop(sheetContext);
                        },
                        child: const Text('적용하기'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 날짜마다 기한 초과, 미완료, 완료 중 가장 중요한 상태 하나만 표시합니다.
class _CalendarMarker extends StatelessWidget {
  const _CalendarMarker({
    required this.day,
    required this.todos,
    required this.now,
    required this.hasRoutinePreview,
  });

  final DateTime day;
  final List<Todo> todos;
  final DateTime now;
  final bool hasRoutinePreview;

  String get _dateKey => '${day.year}_${day.month}_${day.day}';

  @override
  Widget build(BuildContext context) {
    if (todos.isEmpty) {
      if (!hasRoutinePreview) return const SizedBox.shrink();
      return Semantics(
        label: '루틴 예정 있음',
        child: Icon(
          Icons.repeat_rounded,
          key: ValueKey('calendar_routine_preview_marker_$_dateKey'),
          size: 16,
          color: AppColors.primary,
        ),
      );
    }

    final hasIncomplete = todos.any((todo) => !todo.isCompleted);
    final isOverdue = todos.any(
      (todo) => !todo.isCompleted && now.isAfter(todo.deadlineAt),
    );

    if (isOverdue) {
      return Semantics(
        label: '기한이 지난 미완료 일정 있음',
        child: Icon(
          Icons.error_outline_rounded,
          key: ValueKey('calendar_overdue_marker_$_dateKey'),
          size: 16,
          color: AppColors.red,
        ),
      );
    }

    if (hasIncomplete) {
      return Semantics(
        label: '미완료 일정 있음',
        child: Icon(
          Icons.radio_button_unchecked_rounded,
          key: ValueKey('calendar_incomplete_marker_$_dateKey'),
          size: 15,
          color: AppColors.orange,
        ),
      );
    }

    return Semantics(
      label: '모든 일정 완료',
      child: Icon(
        Icons.check_circle_rounded,
        key: ValueKey('calendar_completed_marker_$_dateKey'),
        size: 16,
        color: AppColors.green,
      ),
    );
  }
}

/// 캘린더 상태 아이콘의 의미를 색상과 문구로 함께 안내합니다.
class _CalendarLegend extends StatelessWidget {
  const _CalendarLegend();

  @override
  Widget build(BuildContext context) => const Wrap(
    key: ValueKey('calendar_marker_legend'),
    alignment: WrapAlignment.end,
    spacing: 12,
    runSpacing: 4,
    children: [
      _LegendItem(
        icon: Icons.repeat_rounded,
        color: AppColors.primary,
        label: '루틴 예정',
      ),
      _LegendItem(
        icon: Icons.radio_button_unchecked_rounded,
        color: AppColors.orange,
        label: '미완료',
      ),
      _LegendItem(
        icon: Icons.check_circle_rounded,
        color: AppColors.green,
        label: '완료',
      ),
      _LegendItem(
        icon: Icons.error_outline_rounded,
        color: AppColors.red,
        label: '기한 지남',
      ),
    ],
  );
}

/// 저장되지 않은 미래 루틴 일정을 완료 액션이 없는 예정 카드로 표시합니다.
class _RoutinePreviewCard extends StatelessWidget {
  const _RoutinePreviewCard({
    required this.routine,
    required this.selectedDay,
    required this.onTap,
  });

  final Routine routine;
  final DateTime selectedDay;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Material(
      color: AppColors.primary.withValues(alpha: .05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        side: BorderSide(color: AppColors.primary.withValues(alpha: .22)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: ValueKey(
          'routine_preview_${routine.id}_${selectedDay.year}_${selectedDay.month}_${selectedDay.day}',
        ),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.cardPadding),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: .12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.repeat_rounded,
                  color: AppColors.primary,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      routine.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${routine.category} · ${routine.hasTime ? '${routine.scheduledHour.toString().padLeft(2, '0')}:${routine.scheduledMinute.toString().padLeft(2, '0')}' : '종일'}',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  '예정',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.muted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.icon,
    required this.color,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 14, color: color),
      const SizedBox(width: 4),
      Text(
        label,
        style: const TextStyle(
          color: AppColors.muted,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({
    required this.query,
    required this.results,
    required this.onSelected,
  });

  final String query;
  final List<Todo> results;
  final ValueChanged<Todo> onSelected;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: const BorderSide(color: AppColors.border),
    ),
    clipBehavior: Clip.antiAlias,
    child: results.isEmpty
        ? Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '“$query” 검색 결과가 없어요.',
              style: const TextStyle(color: AppColors.muted),
            ),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
                child: Text(
                  '검색 결과 ${results.length}개',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              ...results
                  .take(5)
                  .map(
                    (todo) => ListTile(
                      key: ValueKey('calendar_search_result_${todo.id}'),
                      dense: true,
                      title: Text(todo.title),
                      subtitle: Text(
                        todo.hasTime
                            ? DateFormat(
                                'yyyy.MM.dd (E) HH:mm',
                                'ko',
                              ).format(todo.dueAt)
                            : '${DateFormat('yyyy.MM.dd (E)', 'ko').format(todo.dueAt)} · 종일',
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => onSelected(todo),
                    ),
                  ),
            ],
          ),
  );
}

class _CalendarEmpty extends StatelessWidget {
  const _CalendarEmpty({required this.filtered, required this.onReset});

  final bool filtered;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 24),
    child: Center(
      child: Column(
        children: [
          Text(
            filtered ? '현재 조건에 맞는 일정이 없어요.' : '등록된 일정이 없어요',
            style: const TextStyle(color: AppColors.muted),
          ),
          if (filtered) ...[
            const SizedBox(height: 10),
            TextButton(
              key: const ValueKey('reset_calendar_conditions'),
              onPressed: onReset,
              child: const Text('검색 및 필터 초기화'),
            ),
          ],
        ],
      ),
    ),
  );
}

class _FilterLabel extends StatelessWidget {
  const _FilterLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w800),
    ),
  );
}

class _FilterChoice extends StatelessWidget {
  const _FilterChoice({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ChoiceChip(
    label: Text(
      label,
      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
    ),
    selected: selected,
    onSelected: (_) => onTap(),
  );
}
