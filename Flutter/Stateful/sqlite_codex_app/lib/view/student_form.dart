import 'package:flutter/material.dart';

class StudentForm extends StatelessWidget {
  const StudentForm({
    super.key,
    required this.formKey,
    required this.codeController,
    required this.nameController,
    required this.departmentController,
    required this.phoneController,
    required this.codeLabel,
    required this.nameLabel,
    required this.departmentLabel,
    required this.phoneLabel,
    required this.buttonText,
    required this.title,
    required this.description,
    required this.onSubmit,
    this.codeReadOnly = false,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController codeController;
  final TextEditingController nameController;
  final TextEditingController departmentController;
  final TextEditingController phoneController;
  final String codeLabel;
  final String nameLabel;
  final String departmentLabel;
  final String phoneLabel;
  final String buttonText;
  final String title;
  final String description;
  final VoidCallback onSubmit;
  final bool codeReadOnly;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.school_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Color(0xFFE0E7FF),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            _field(
              codeController,
              codeLabel,
              icon: Icons.badge_outlined,
              readOnly: codeReadOnly,
            ),
            const SizedBox(height: 16),
            _field(nameController, nameLabel, icon: Icons.person_outline),
            const SizedBox(height: 16),
            _field(
              departmentController,
              departmentLabel,
              icon: Icons.apartment_outlined,
            ),
            const SizedBox(height: 16),
            _field(
              phoneController,
              phoneLabel,
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: onSubmit,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    required IconData icon,
    bool readOnly = false,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      textInputAction: keyboardType == TextInputType.phone
          ? TextInputAction.done
          : TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: readOnly
            ? const Icon(Icons.lock_outline_rounded, size: 20)
            : null,
        helperText: readOnly ? '학번은 변경할 수 없습니다.' : null,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '필수 입력 항목입니다.';
        }
        return null;
      },
    );
  }
}
