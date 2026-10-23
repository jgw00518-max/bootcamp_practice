import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:project_todolist/controller/todo_controller.dart';
import 'package:project_todolist/model/todo.dart';
import 'package:project_todolist/theme/app_theme.dart';
import 'package:project_todolist/view/todo_action_dialogs.dart';
import 'package:project_todolist/view/trash_page.dart';
import 'package:project_todolist/widget/todo_card.dart';

/// 검색과 복합 필터가 적용된 Todo 목록과 오늘의 진행률을 보여줍니다.
class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final TodoController controller = Get.find<TodoController>();
  final _recentlyCompletedIds = <int>{};
  final _completionTimers = <int, Timer>{};
  Timer? _completionSnackBarTimer;
  bool _completedExpanded = false;

  @override
  void dispose() {
    for (final timer in _completionTimers.values) {
      timer.cancel();
    }
    _completionSnackBarTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final today = controller.todayTodos;
      final visible = controller.filteredTodos;
      final searching = controller.searchQuery.value.trim().isNotEmpty;
      final completedFilter =
          controller.statusFilter.value == TodoStatusFilter.completed;
      final incomplete = visible
          .where(
            (todo) =>
                !todo.isCompleted ||
                (!completedFilter && _recentlyCompletedIds.contains(todo.id)),
          )
          .toList();
      final completed = visible
          .where(
            (todo) =>
                todo.isCompleted &&
                (completedFilter || !_recentlyCompletedIds.contains(todo.id)),
          )
          .toList();
      if (completedFilter && !searching) {
        completed.sort(
          (a, b) =>
              (b.completedAt ?? b.dueAt).compareTo(a.completedAt ?? a.dueAt),
        );
      }
      final overdue = incomplete.where(controller.isTodoOverdue).toList();
      final regular = incomplete
          .where((todo) => !controller.isTodoOverdue(todo))
          .toList();
      final regularTodos = regular
          .where((todo) => todo.routineId == null)
          .toList();
      final routineTodos = regular
          .where((todo) => todo.routineId != null)
          .toList();
      final showCompletedItems =
          completedFilter || searching || _completedExpanded;
      final completedToday = today.where((todo) => todo.isCompleted).length;
      final rate = today.isEmpty ? 0.0 : completedToday / today.length;

      return CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.screenPadding,
              18,
              AppDimensions.screenPadding,
              8,
            ),
            sliver: SliverList.list(
              children: [
                Row(
                  children: [
                    Text(
                      '목록',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const Spacer(),
                    IconButton(
                      key: const ValueKey('trash_button'),
                      tooltip: '휴지통',
                      onPressed: () => Get.to(() => const TrashPage()),
                      icon: const Icon(Icons.delete_outline_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat(
                              'yyyy년 M월 d일 EEEE',
                              'ko',
                            ).format(DateTime.now()),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.muted,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '안녕하세요, 오늘도 파이팅! 👋',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 62,
                      height: 62,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: rate,
                            strokeWidth: 5,
                            backgroundColor: const Color(0xFFE9E9FF),
                            color: AppColors.primary,
                          ),
                          Text(
                            '${(rate * 100).round()}%',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (controller.todos.isEmpty)
                  const _EmptyTodoList()
                else ...[
                  const SizedBox(height: 20),
                  TextField(
                    key: const ValueKey('todo_search_field'),
                    controller: controller.searchTextController,
                    onChanged: (value) => controller.searchQuery.value = value,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search_rounded),
                      hintText: '제목 또는 메모 검색...',
                      suffixIcon: IconButton(
                        key: const ValueKey('advanced_filter_button'),
                        tooltip: '상세 필터',
                        onPressed: () => _showDetailedFilters(context),
                        icon: Badge(
                          isLabelVisible: controller.hasDetailedFilter,
                          smallSize: 7,
                          child: const Icon(Icons.tune_rounded),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _StatusFilter(
                          key: const ValueKey('status_filter_all'),
                          label: '전체 ${controller.todos.length}',
                          value: TodoStatusFilter.all,
                        ),
                        const SizedBox(width: 8),
                        _StatusFilter(
                          key: const ValueKey('status_filter_today'),
                          label: '오늘 ${today.length}',
                          value: TodoStatusFilter.today,
                        ),
                        const SizedBox(width: 8),
                        _StatusFilter(
                          key: const ValueKey('status_filter_completed'),
                          label: '완료 ${controller.completedCount}',
                          value: TodoStatusFilter.completed,
                        ),
                        const SizedBox(width: 8),
                        _StatusFilter(
                          key: const ValueKey('status_filter_incomplete'),
                          label:
                              '미완료 ${controller.todos.length - controller.completedCount}',
                          value: TodoStatusFilter.incomplete,
                        ),
                      ],
                    ),
                  ),
                  if (visible.isEmpty)
                    _EmptySearchResult(onReset: controller.clearFilters)
                  else if (searching) ...[
                    const SizedBox(height: 24),
                    _SectionTitle(
                      key: const ValueKey('search_result_section_header'),
                      icon: Icons.search_rounded,
                      color: AppColors.primary,
                      title: '검색 결과',
                      count: visible.length,
                    ),
                    const SizedBox(height: 10),
                    ...visible.map((todo) => _buildCard(context, todo)),
                  ] else if (completedFilter) ...[
                    const SizedBox(height: 24),
                    _SectionTitle(
                      key: const ValueKey('completed_section_header'),
                      icon: Icons.task_alt_rounded,
                      color: AppColors.green,
                      title: '완료한 할 일',
                      count: completed.length,
                    ),
                    const SizedBox(height: 10),
                    ...completed.map((todo) => _buildCard(context, todo)),
                  ] else ...[
                    if (overdue.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _SectionTitle(
                        key: const ValueKey('overdue_section_header'),
                        icon: Icons.warning_amber_rounded,
                        color: AppColors.orange,
                        title: '기한이 지난 할 일',
                        count: overdue.length,
                      ),
                      const SizedBox(height: 10),
                      ...overdue.map((todo) => _buildCard(context, todo)),
                    ],
                    if (regularTodos.isNotEmpty) ...[
                      const SizedBox(height: 22),
                      _SectionTitle(
                        key: const ValueKey('regular_section_header'),
                        icon: Icons.calendar_today_rounded,
                        color: AppColors.primary,
                        title: _regularSectionTitle(
                          controller.statusFilter.value,
                        ),
                        count: regularTodos.length,
                      ),
                      const SizedBox(height: 10),
                      ...regularTodos.map((todo) => _buildCard(context, todo)),
                    ],
                    if (routineTodos.isNotEmpty) ...[
                      const SizedBox(height: 22),
                      _SectionTitle(
                        key: const ValueKey('routine_section_header'),
                        icon: Icons.repeat_rounded,
                        color: AppColors.primary,
                        title:
                            controller.statusFilter.value ==
                                TodoStatusFilter.today
                            ? '오늘의 루틴'
                            : '루틴 일정',
                        count: routineTodos.length,
                      ),
                      const SizedBox(height: 10),
                      ...routineTodos.map((todo) => _buildCard(context, todo)),
                    ],
                    if (completed.isNotEmpty) ...[
                      const SizedBox(height: 22),
                      _CompletedSectionHeader(
                        count: completed.length,
                        expanded: showCompletedItems,
                        onTap: () => setState(
                          () => _completedExpanded = !_completedExpanded,
                        ),
                      ),
                      if (showCompletedItems) ...[
                        const SizedBox(height: 10),
                        ...completed.map((todo) => _buildCard(context, todo)),
                      ],
                    ],
                  ],
                ],
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildCard(BuildContext context, Todo todo) => TodoCard(
    todo: todo,
    isEndedRoutine:
        todo.routineId != null &&
        controller.routines.every((routine) => routine.id != todo.routineId),
    onToggle: () => _toggleTodo(todo),
    onTap: () => openTodoEditor(context, todo),
    onDelete: () => deleteTodoWithScope(context, todo),
  );

  /// 완료 직후 잠시 카드를 유지하고 실행 취소 기회를 제공한 뒤 접힌 영역으로 이동합니다.
  Future<void> _toggleTodo(Todo todo) async {
    final id = todo.id;
    if (id == null) return;
    final wasCompleted = todo.isCompleted;
    if (!wasCompleted) setState(() => _recentlyCompletedIds.add(id));
    final changed = await controller.toggle(todo);
    if (!mounted) return;
    if (!changed) {
      setState(() => _recentlyCompletedIds.remove(id));
      return;
    }
    if (wasCompleted) return;

    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    final snackBarController = messenger.showSnackBar(
      SnackBar(
        content: const Text('할 일을 완료했어요.'),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: '실행 취소',
          onPressed: () async {
            _completionSnackBarTimer?.cancel();
            _completionTimers.remove(id)?.cancel();
            if (mounted) setState(() => _recentlyCompletedIds.remove(id));
            final completedTodo = controller.todos.firstWhereOrNull(
              (value) => value.id == id,
            );
            if (completedTodo?.isCompleted == true) {
              await controller.toggle(completedTodo!);
            }
          },
        ),
      ),
    );
    _completionSnackBarTimer?.cancel();
    _completionSnackBarTimer = Timer(
      const Duration(seconds: 3),
      snackBarController.close,
    );
    _completionTimers.remove(id)?.cancel();
    _completionTimers[id] = Timer(const Duration(milliseconds: 500), () {
      _completionTimers.remove(id);
      if (mounted) setState(() => _recentlyCompletedIds.remove(id));
    });
  }

  String _regularSectionTitle(TodoStatusFilter filter) => switch (filter) {
    TodoStatusFilter.today => '오늘 할 일',
    TodoStatusFilter.completed => '일반 할 일',
    TodoStatusFilter.incomplete => '일반 할 일',
    TodoStatusFilter.all => '일반 할 일',
  };

  /// 정렬, 우선순위, 카테고리를 한 번에 선택하는 하단 시트를 표시합니다.
  void _showDetailedFilters(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Obx(
        () => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '필터 및 정렬',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  '정렬',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Choice(
                      key: const ValueKey('todo_sort_due'),
                      label: '일정 빠른순',
                      selected:
                          controller.todoSortOption.value ==
                          TodoSortOption.dueSoonest,
                      onSelected: () => controller.todoSortOption.value =
                          TodoSortOption.dueSoonest,
                    ),
                    _Choice(
                      key: const ValueKey('todo_sort_newest'),
                      label: '최신 등록순',
                      selected:
                          controller.todoSortOption.value ==
                          TodoSortOption.newest,
                      onSelected: () => controller.todoSortOption.value =
                          TodoSortOption.newest,
                    ),
                    _Choice(
                      key: const ValueKey('todo_sort_title'),
                      label: '이름순',
                      selected:
                          controller.todoSortOption.value ==
                          TodoSortOption.title,
                      onSelected: () => controller.todoSortOption.value =
                          TodoSortOption.title,
                    ),
                    _Choice(
                      key: const ValueKey('todo_sort_priority'),
                      label: '우선순위순',
                      selected:
                          controller.todoSortOption.value ==
                          TodoSortOption.priority,
                      onSelected: () => controller.todoSortOption.value =
                          TodoSortOption.priority,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Text(
                  '유형',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Choice(
                      key: const ValueKey('todo_type_all'),
                      label: '전체',
                      selected:
                          controller.todoTypeFilter.value == TodoTypeFilter.all,
                      onSelected: () =>
                          controller.todoTypeFilter.value = TodoTypeFilter.all,
                    ),
                    _Choice(
                      key: const ValueKey('todo_type_normal'),
                      label: '일반 할 일',
                      selected:
                          controller.todoTypeFilter.value ==
                          TodoTypeFilter.normal,
                      onSelected: () => controller.todoTypeFilter.value =
                          TodoTypeFilter.normal,
                    ),
                    _Choice(
                      key: const ValueKey('todo_type_routine'),
                      label: '루틴 일정',
                      selected:
                          controller.todoTypeFilter.value ==
                          TodoTypeFilter.routine,
                      onSelected: () => controller.todoTypeFilter.value =
                          TodoTypeFilter.routine,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Text(
                  '우선순위',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [
                    _Choice(
                      key: const ValueKey('priority_filter_all'),
                      label: '전체',
                      selected: controller.priorityFilter.value == null,
                      onSelected: () => controller.priorityFilter.value = null,
                    ),
                    _Choice(
                      key: const ValueKey('priority_filter_high'),
                      label: '높음',
                      selected: controller.priorityFilter.value == 2,
                      onSelected: () => controller.priorityFilter.value = 2,
                    ),
                    _Choice(
                      key: const ValueKey('priority_filter_medium'),
                      label: '보통',
                      selected: controller.priorityFilter.value == 1,
                      onSelected: () => controller.priorityFilter.value = 1,
                    ),
                    _Choice(
                      key: const ValueKey('priority_filter_low'),
                      label: '낮음',
                      selected: controller.priorityFilter.value == 0,
                      onSelected: () => controller.priorityFilter.value = 0,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Text(
                  '카테고리',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: ['전체', '없음', ...controller.categoryNames].map((
                    category,
                  ) {
                    final value = category == '전체' ? null : category;
                    return _Choice(
                      key: ValueKey('category_filter_${value ?? 'all'}'),
                      label: category,
                      selected: controller.categoryFilter.value == value,
                      onSelected: () => controller.categoryFilter.value = value,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          controller.todoSortOption.value =
                              TodoSortOption.dueSoonest;
                          controller.todoTypeFilter.value = TodoTypeFilter.all;
                          controller.priorityFilter.value = null;
                          controller.categoryFilter.value = null;
                        },
                        child: const Text('필터 및 정렬 초기화'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        key: const ValueKey('apply_filter_button'),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('결과 보기'),
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

class _StatusFilter extends GetView<TodoController> {
  const _StatusFilter({super.key, required this.label, required this.value});
  final String label;
  final TodoStatusFilter value;

  @override
  Widget build(BuildContext context) {
    final selected = controller.statusFilter.value == value;
    return InkWell(
      onTap: () => controller.statusFilter.value = value,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.muted,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
  });
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) => ChoiceChip(
    label: Text(
      label,
      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
    ),
    selected: selected,
    onSelected: (_) => onSelected(),
  );
}

class _EmptySearchResult extends StatelessWidget {
  const _EmptySearchResult({required this.onReset});
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 52),
    child: Column(
      children: [
        const Icon(Icons.search_off_rounded, size: 54, color: AppColors.muted),
        const SizedBox(height: 14),
        const Text(
          '조건에 맞는 할 일이 없어요',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        const Text(
          '검색어나 필터를 변경해 보세요.',
          style: TextStyle(color: AppColors.muted),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          key: const ValueKey('reset_filters_button'),
          onPressed: onReset,
          child: const Text('필터 초기화'),
        ),
      ],
    ),
  );
}

/// 저장된 Todo가 전혀 없을 때 첫 등록 행동을 안내합니다.
class _EmptyTodoList extends StatelessWidget {
  const _EmptyTodoList();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 58),
    child: Column(
      children: [
        Icon(Icons.task_alt_rounded, size: 58, color: AppColors.primary),
        SizedBox(height: 16),
        Text(
          '아직 등록된 할 일이 없어요',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        SizedBox(height: 7),
        Text(
          '+ 버튼을 눌러 첫 할 일을 추가해 보세요',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.muted),
        ),
      ],
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.count,
  });
  final IconData icon;
  final Color color;
  final String title;
  final int count;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 18, color: color),
      const SizedBox(width: 7),
      Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      const SizedBox(width: 8),
      Text('$count', style: const TextStyle(color: AppColors.muted)),
    ],
  );
}

/// 완료 항목의 개수와 펼침 상태를 한 행에서 제어합니다.
class _CompletedSectionHeader extends StatelessWidget {
  const _CompletedSectionHeader({
    required this.count,
    required this.expanded,
    required this.onTap,
  });

  final int count;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.green.withValues(alpha: .07),
    borderRadius: BorderRadius.circular(14),
    child: InkWell(
      key: const ValueKey('completed_section_toggle'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            const Icon(
              Icons.task_alt_rounded,
              size: 19,
              color: AppColors.green,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Row(
                children: [
                  const Flexible(
                    child: Text(
                      '완료한 할 일',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$count',
                    style: const TextStyle(color: AppColors.muted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              expanded ? '접기' : '펼치기',
              style: const TextStyle(
                color: AppColors.green,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 3),
            Icon(
              expanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_right_rounded,
              color: AppColors.green,
              size: 20,
            ),
          ],
        ),
      ),
    ),
  );
}
