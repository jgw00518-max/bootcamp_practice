import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../model/todo_list.dart';

class TodayView extends StatefulWidget {
  const TodayView({super.key});

  @override
  State<TodayView> createState() => _TodayViewState();
}

class _TodayViewState extends State<TodayView> {
  DateTime selectedDate = DateTime.now();
  final box = GetStorage();

  // 전체 할 일 리스트
  List<TodoList> todoItems = [];

  @override
  void initState() {
    super.initState();
    _loadSavedTodoFromStorage();

    // ★ 저장소(todo_list)에 변화가 생기면 자동 데이터 갱신[cite: 27]
    box.listenKey('todo_list', (value) {
      if (mounted) {
        _loadSavedTodoFromStorage();
      }
    });
  }

  // 날짜 필터링[cite: 27]
  List<TodoList> get filteredTodoItems {
    String formattedSelectedDate =
        '${selectedDate.year}-'
        '${selectedDate.month.toString().padLeft(2, '0')}-'
        '${selectedDate.day.toString().padLeft(2, '0')}';

    return todoItems
        .where((item) => item.date == formattedSelectedDate)
        .toList();
  }

  // 날짜 선택[cite: 27]
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // GetStorage에서 저장된 전체 Todo 목록 불러오기[cite: 27]
  void _loadSavedTodoFromStorage() {
    List<dynamic> rawList = box.read<List<dynamic>>('todo_list') ?? [];
    
    setState(() {
      todoItems = rawList
          .map((e) => TodoList.fromRawString(e.toString()))
          .toList();
    });

    saveTodayCount();
  }

  // 변경된 전체 Todo 리스트를 GetStorage에 갱신 저장[cite: 27]
  void _saveAllToStorage() {
    List<String> rawList = todoItems.map((e) => e.toRawString()).toList();
    box.write('todo_list', rawList);
    saveTodayCount();
  }

  // 오늘 할 일 개수 / 완료 개수 계산하여 HomeView용 저장[cite: 27]
  void saveTodayCount() {
    DateTime now = DateTime.now();
    String today =
        '${now.year}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
    
    int todayCount = 0;
    int doneCount = 0;

    for (var item in todoItems) {
      if (item.date == today) {
        todayCount++;
        if (item.isCompleted) {
          doneCount++;
        }
      }
    }

    box.write('todayCount', todayCount);
    box.write('doneCount', doneCount);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    String dateTitle =
        '${selectedDate.year}-'
        '${selectedDate.month.toString().padLeft(2, '0')}-'
        '${selectedDate.day.toString().padLeft(2, '0')} 할 일';

    return Scaffold(
      backgroundColor: colorScheme.tertiary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateTitle,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.calendar_month_rounded,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      onPressed: () {
                        _selectDate(context);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.west,
                    size: 14,
                    color: colorScheme.outline,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '왼쪽으로 밀어서 할 일을 삭제할 수 있습니다.',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: filteredTodoItems.isEmpty
                    ? Center(
                        child: Text(
                          '해당 날짜에 등록된 할 일이 없습니다.',
                          style: TextStyle(
                            color: colorScheme.outline,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredTodoItems.length,
                        itemBuilder: (context, index) {
                          final todo = filteredTodoItems[index];
                          return _buildTodoCard(todo, colorScheme);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Get.toNamed('/add');
          _loadSavedTodoFromStorage();
        },
        backgroundColor: colorScheme.primary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(
          Icons.add,
          color: colorScheme.onPrimary,
          size: 28,
        ),
      ),
    );
  }

  // 할 일 카드[cite: 27]
  Widget _buildTodoCard(
    TodoList todo,
    ColorScheme colorScheme,
  ) {
    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: colorScheme.error,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          Icons.delete,
          color: colorScheme.onError,
        ),
      ),
      onDismissed: (direction) {
        setState(() {
          todoItems.remove(todo);
        });
        _saveAllToStorage();

        Get.snackbar(
          '삭제 완료',
          '${todo.todoText} 항목이 삭제되었습니다.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
          backgroundColor: colorScheme.inverseSurface,
          colorText: colorScheme.onInverseSurface,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  todo.isCompleted = !todo.isCompleted;
                });
                _saveAllToStorage();
              },
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: todo.isCompleted
                      ? colorScheme.secondary
                      : colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: todo.isCompleted
                        ? colorScheme.secondary
                        : colorScheme.outlineVariant,
                    width: 2,
                  ),
                ),
                child: todo.isCompleted
                    ? Icon(
                        Icons.check,
                        size: 16,
                        color: colorScheme.onSecondary,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (todo.isImportant)
                        Icon(
                          Icons.star,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                      if (todo.isImportant) const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          todo.todoText,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: todo.isCompleted
                                ? colorScheme.outline
                                : colorScheme.onSurface,
                            decoration: todo.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        todo.time,
                        style: TextStyle(
                          fontSize: 12,
                          color: todo.isCompleted
                              ? colorScheme.outline
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '•',
                        style: TextStyle(
                          fontSize: 12,
                          color: todo.isCompleted
                              ? colorScheme.outline
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        todo.category,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: todo.isCompleted
                              ? colorScheme.outline
                              : colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}