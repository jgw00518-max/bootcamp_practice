import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqlite_codex_app/database/student_database.dart';
import 'package:sqlite_codex_app/model/student.dart';
import 'package:sqlite_codex_app/view/student_form.dart';

class UpdatePage extends StatefulWidget {
  const UpdatePage({super.key, required this.student});
  final Student student;

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeController;
  late final TextEditingController _nameController;
  late final TextEditingController _departmentController;
  late final TextEditingController _phoneController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.student.code);
    _nameController = TextEditingController(text: widget.student.name);
    _departmentController = TextEditingController(
      text: widget.student.department,
    );
    _phoneController = TextEditingController(text: widget.student.phone);
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _departmentController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _update() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;
    setState(() => _isSaving = true);
    try {
      await StudentDatabase.instance.updateStudent(
        Student(
          code: widget.student.code,
          name: _nameController.text.trim(),
          department: _departmentController.text.trim(),
          phone: _phoneController.text.trim(),
        ),
      );
      Get.back(result: true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      Get.snackbar('수정 실패', '학생 정보를 다시 확인해주세요.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('학생 정보 수정')),
      body: StudentForm(
        formKey: _formKey,
        codeController: _codeController,
        nameController: _nameController,
        departmentController: _departmentController,
        phoneController: _phoneController,
        codeLabel: '학번',
        nameLabel: '성명을 수정하세요',
        departmentLabel: '전공을 수정하세요',
        phoneLabel: '전화번호를 수정하세요',
        buttonText: _isSaving ? '수정 중...' : '수정',
        title: '학생 정보를 수정하세요',
        description: '변경할 내용을 입력한 뒤 저장해주세요.',
        onSubmit: _update,
        codeReadOnly: true,
      ),
    );
  }
}
