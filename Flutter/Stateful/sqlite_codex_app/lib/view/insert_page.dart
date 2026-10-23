import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqlite_codex_app/database/student_database.dart';
import 'package:sqlite_codex_app/model/student.dart';
import 'package:sqlite_codex_app/view/student_form.dart';

class InsertPage extends StatefulWidget {
  const InsertPage({super.key});

  @override
  State<InsertPage> createState() => _InsertPageState();
}

class _InsertPageState extends State<InsertPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _departmentController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _departmentController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _insert() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;
    setState(() => _isSaving = true);
    try {
      await StudentDatabase.instance.insertStudent(
        Student(
          code: _codeController.text.trim(),
          name: _nameController.text.trim(),
          department: _departmentController.text.trim(),
          phone: _phoneController.text.trim(),
        ),
      );
      Get.back(result: true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      Get.snackbar('입력 실패', '이미 등록된 학번인지 확인해주세요.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('학생 등록')),
      body: StudentForm(
        formKey: _formKey,
        codeController: _codeController,
        nameController: _nameController,
        departmentController: _departmentController,
        phoneController: _phoneController,
        codeLabel: '학번을 입력하세요',
        nameLabel: '성명을 입력하세요',
        departmentLabel: '전공을 입력하세요',
        phoneLabel: '전화번호를 입력하세요',
        buttonText: _isSaving ? '입력 중...' : '입력',
        title: '새로운 학생을 등록하세요',
        description: '학생 정보를 정확하게 입력해주세요.',
        onSubmit: _insert,
      ),
    );
  }
}
