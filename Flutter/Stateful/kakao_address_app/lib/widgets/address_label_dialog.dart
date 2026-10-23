import 'package:flutter/material.dart';

/// 주소 저장 시 별칭을 입력받고 컨트롤러 생명주기를 다이얼로그 안에서 관리한다.
class AddressLabelDialog extends StatefulWidget {
  const AddressLabelDialog({
    super.key,
    required this.initialLabel,
    required this.isEditing,
  });

  final String initialLabel;
  final bool isEditing;

  @override
  State<AddressLabelDialog> createState() => _AddressLabelDialogState();
}

class _AddressLabelDialogState extends State<AddressLabelDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialLabel);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() => Navigator.pop(context, _controller.text.trim());

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.isEditing ? '주소 별칭 수정' : '주소 별칭 정하기'),
    content: TextField(
      key: const Key('address_label_dialog_field'),
      controller: _controller,
      autofocus: true,
      decoration: const InputDecoration(
        labelText: '주소 별칭',
        hintText: '예: 집, 회사, 학교',
      ),
      onSubmitted: (_) => _submit(),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('취소'),
      ),
      FilledButton(onPressed: _submit, child: const Text('저장')),
    ],
  );
}
