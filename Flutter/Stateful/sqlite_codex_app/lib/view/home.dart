import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:sqlite_codex_app/database/student_database.dart';
import 'package:sqlite_codex_app/model/student.dart';
import 'package:sqlite_codex_app/view/insert_page.dart';
import 'package:sqlite_codex_app/view/update_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Student> _students = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    try {
      final students = await StudentDatabase.instance.readStudents();
      if (!mounted) return;
      setState(() {
        _students = students;
        _isLoading = false;
        _hasError = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  Future<void> _openInsertPage() async {
    final inserted = await Get.to<bool>(() => const InsertPage());
    if (inserted == true) {
      await _loadStudents();
      _showMessage('등록 완료', '새로운 학생이 등록되었습니다.');
    }
  }

  Future<void> _openUpdatePage(Student student) async {
    final updated = await Get.to<bool>(() => UpdatePage(student: student));
    if (updated == true) {
      await _loadStudents();
      _showMessage('수정 완료', '학생 정보가 수정되었습니다.');
    }
  }

  Future<void> _confirmDelete(Student student) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
        title: const Text('학생을 삭제할까요?'),
        content: Text('${student.name} 학생의 정보가 영구적으로 삭제됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await StudentDatabase.instance.deleteStudent(student.code);
    await _loadStudents();
    _showMessage('삭제 완료', '학생 정보가 삭제되었습니다.');
  }

  void _showMessage(String title, String message) {
    if (!mounted) return;
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 14,
      backgroundColor: const Color(0xFF111827),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SQLite for Students'),
            Text(
              '학생 정보 관리',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton.filled(
              key: const Key('add_student_button'),
              onPressed: _openInsertPage,
              icon: const Icon(Icons.add_rounded),
              tooltip: '학생 추가',
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_hasError) {
      return _StatusView(
        icon: Icons.cloud_off_rounded,
        title: '데이터를 불러오지 못했어요',
        description: '잠시 후 다시 시도해주세요.',
        buttonText: '다시 시도',
        onPressed: _loadStudents,
      );
    }
    if (_students.isEmpty) {
      return _StatusView(
        icon: Icons.school_outlined,
        title: '등록된 학생이 없습니다',
        description: '첫 번째 학생 정보를 등록해보세요.',
        buttonText: '학생 등록하기',
        onPressed: _openInsertPage,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadStudents,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
        itemCount: _students.length + 1,
        separatorBuilder: (_, index) => SizedBox(height: index == 0 ? 18 : 12),
        itemBuilder: (context, index) {
          if (index == 0) return _SummaryCard(count: _students.length);
          return _StudentCard(
            student: _students[index - 1],
            onTap: () => _openUpdatePage(_students[index - 1]),
            onDelete: () => _confirmDelete(_students[index - 1]),
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x294F46E5),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.groups_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '등록된 학생',
                  style: TextStyle(color: Color(0xFFE0E7FF), fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  '$count명',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.auto_awesome_rounded, color: Color(0xFFC4B5FD)),
        ],
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  const _StudentCard({
    required this.student,
    required this.onTap,
    required this.onDelete,
  });

  final Student student;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Slidable(
        key: ValueKey(student.code),
        endActionPane: ActionPane(
          motion: const BehindMotion(),
          extentRatio: 0.28,
          children: [
            SlidableAction(
              onPressed: (_) => onDelete(),
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              icon: Icons.delete_outline_rounded,
              label: '삭제',
            ),
          ],
        ),
        child: Material(
          color: Colors.white,
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFEEF0F4)),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: const Color(0xFFEEF2FF),
                    child: Text(
                      student.name.isEmpty ? '?' : student.name[0],
                      style: const TextStyle(
                        color: Color(0xFF4F46E5),
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                student.name,
                                style: const TextStyle(
                                  color: Color(0xFF111827),
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                student.code,
                                style: const TextStyle(
                                  color: Color(0xFF4B5563),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 9),
                        _InfoLine(
                          icon: Icons.apartment_outlined,
                          text: student.department,
                        ),
                        const SizedBox(height: 5),
                        _InfoLine(
                          icon: Icons.phone_outlined,
                          text: student.phone,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF9CA3AF),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF9CA3AF)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
          ),
        ),
      ],
    );
  }
}

class _StatusView extends StatelessWidget {
  const _StatusView({
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String description;
  final String buttonText;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: Color(0xFFEEF2FF),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 42, color: const Color(0xFF4F46E5)),
            ),
            const SizedBox(height: 22),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.add_rounded),
              label: Text(buttonText),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
