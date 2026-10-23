import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:project_todolist/controller/todo_controller.dart';
import 'package:project_todolist/data/todo_database.dart';
import 'package:project_todolist/theme/app_theme.dart';
import 'package:project_todolist/view/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR');
  Get.put(TodoController(TodoDatabase.instance));
  runApp(const TodoApp());
}

/// 앱의 테마와 첫 화면을 구성합니다.
class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '오늘도',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const Home(),
    );
  }
}
