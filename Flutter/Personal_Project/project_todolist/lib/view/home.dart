import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_todolist/controller/todo_controller.dart';
import 'package:project_todolist/theme/app_theme.dart';
import 'package:project_todolist/view/calendar_page.dart';
import 'package:project_todolist/view/focus_page.dart';
import 'package:project_todolist/view/routine_page.dart';
import 'package:project_todolist/view/statistics_page.dart';
import 'package:project_todolist/view/task_form_page.dart';
import 'package:project_todolist/view/todo_list_page.dart';

/// 하단 탭을 유지하며 앱의 주요 화면을 전환합니다.
class Home extends GetView<TodoController> {
  const Home({super.key});

  static const _pages = [
    TodoListPage(),
    CalendarPage(),
    RoutinePage(),
    FocusPage(),
    StatisticsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: SafeArea(
          child: controller.loadError.value != null
              ? _DatabaseErrorView(controller: controller)
              : controller.isLoading.value &&
                    controller.todos.isEmpty &&
                    controller.deletedTodos.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : IndexedStack(
                  index: controller.selectedTab.value,
                  children: _pages,
                ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: controller.selectedTab.value,
          onDestinationSelected: (index) =>
              controller.selectedTab.value = index,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.checklist_outlined),
              selectedIcon: Icon(Icons.checklist_rounded),
              label: '목록',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month_rounded),
              label: '캘린더',
            ),
            NavigationDestination(
              icon: Icon(Icons.repeat_outlined),
              selectedIcon: Icon(Icons.repeat_rounded),
              label: '루틴',
            ),
            NavigationDestination(
              icon: Icon(Icons.timer_outlined),
              selectedIcon: Icon(Icons.timer_rounded),
              label: '집중',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart_rounded),
              label: '통계',
            ),
          ],
        ),
        floatingActionButton:
            controller.loadError.value == null &&
                controller.selectedTab.value <= 2
            ? FloatingActionButton(
                key: ValueKey(
                  controller.selectedTab.value == 2
                      ? 'add_routine_button'
                      : 'add_todo_button',
                ),
                tooltip: controller.selectedTab.value == 2 ? '루틴 추가' : '할 일 추가',
                onPressed: () => Get.to(
                  () => TaskFormPage(
                    initialDate: controller.selectedTab.value == 1
                        ? controller.selectedDay.value
                        : null,
                    initialRepeat: controller.selectedTab.value == 2,
                  ),
                ),
                child: const Icon(Icons.add_rounded, size: 30),
              )
            : null,
      ),
    );
  }
}

/// DB 읽기 실패를 빈 목록과 구분하고 같은 화면에서 재시도할 수 있게 합니다.
class _DatabaseErrorView extends StatelessWidget {
  const _DatabaseErrorView({required this.controller});

  final TodoController controller;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_rounded, size: 58, color: AppColors.muted),
          const SizedBox(height: 16),
          Text(
            controller.loadError.value ?? '데이터를 불러오지 못했습니다.',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            '기존 데이터는 유지됩니다. 잠시 후 다시 시도해 주세요.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            key: const ValueKey('retry_load_todos_button'),
            onPressed: controller.isLoading.value ? null : controller.loadTodos,
            icon: controller.isLoading.value
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded),
            label: const Text('다시 시도'),
          ),
        ],
      ),
    ),
  );
}
