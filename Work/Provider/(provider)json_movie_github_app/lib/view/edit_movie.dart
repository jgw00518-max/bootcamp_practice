import 'package:flutter/material.dart';

/// 영화 포스터와 기존 제목을 표시하고 저장한 제목을 이전 화면에 반환한다.
class EditMovie extends StatefulWidget {
  const EditMovie({super.key, required this.title, required this.imageUrl});

  final String title;
  final String imageUrl;

  @override
  State<EditMovie> createState() => _EditMovieState();
}

class _EditMovieState extends State<EditMovie> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  /// 공백 제목을 막고 입력값의 앞뒤 공백을 제거하여 전달한다.
  void _save() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, _titleController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JSON & Slider Test'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.network(
                    widget.imageUrl,
                    width: 200,
                    height: 290,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const SizedBox(
                      width: 200,
                      height: 290,
                      child: Icon(Icons.broken_image_outlined, size: 64),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: '제목'),
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _save(),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? '제목을 입력해 주세요.'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _save,
                        child: const Text('Edit'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ],
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
