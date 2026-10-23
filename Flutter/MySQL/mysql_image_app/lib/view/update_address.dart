import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class UpdateAddress extends StatefulWidget {
  final Map<String, dynamic> address;
  const UpdateAddress({super.key, required this.address});

  @override
  State<UpdateAddress> createState() => _UpdateAddressState();
}

class _UpdateAddressState extends State<UpdateAddress> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController relationController = TextEditingController();

  XFile? imageFile;
  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    nameController.text = widget.address['name'] ?? '';
    phoneController.text = widget.address['phone'] ?? '';
    addressController.text = widget.address['address'] ?? '';
    relationController.text = widget.address['relation'] ?? '';
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    relationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('주소록 수정')),
      body: Center(
        child: Column(
          children: [
            _buildTextField(nameController, "이름을 입력하세요."),
            _buildTextField(phoneController, "전화번호를 입력하세요."),
            _buildTextField(addressController, "주소를 입력하세요."),
            _buildTextField(relationController, "관계를 입력하세요."),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: () => getImageFromGallery(ImageSource.gallery),
                child: Text('이미지 가져오기'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 200,
                color: Colors.grey,
                child: Center(
                  child: imageFile == null
                      ? Image.network(
                          'http://192.168.20.52:8000/view/'
                          '${widget.address['seq']}'
                          '?t=${DateTime.now().microsecondsSinceEpoch}',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Text('이미지를 불러올 수 없습니다.');
                          },
                        )
                      : Image.file(File(imageFile!.path), fit: BoxFit.contain),
                ),
              ),
            ),
            ElevatedButton(onPressed: () => updateAction(), child: Text('수정')),
          ],
        ),
      ),
    );
  }

  // ---- Functions ----
  Widget _buildTextField(TextEditingController controller, String hint) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: hint),
      ),
    );
  }

  Future<void> getImageFromGallery(ImageSource imageSource) async {
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    if (pickedFile == null) {
    } else {
      imageFile = XFile(pickedFile.path);
    }
    setState(() {});
  }

  Future<void> updateAction() async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.20.52:8000/update'),
    );
    request.fields['seq'] = widget.address['seq'].toString();
    request.fields['name'] = nameController.text.trim();
    request.fields['phone'] = phoneController.text.trim();
    request.fields['address'] = addressController.text.trim();
    request.fields['relation'] = relationController.text.trim();

    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile!.path),
      );
    }

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        _showDialog();
      } else {
        errorSnackBar();
      }
    } catch (e) {
      errorSnackBar();
    }
  }

  void _showDialog() {
    Get.defaultDialog(
      title: '수정 결과',
      middleText: '수정이 완료 되었습니다.',
      barrierDismissible: false,
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
            Get.back();
          },
          child: Text('OK'),
        ),
      ],
    );
  }

  void errorSnackBar() {
    Get.snackbar(
      "문제 발생",
      "수정 중 문제가 발생하였습니다.",
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 2),
      colorText: Colors.white,
      backgroundColor: Colors.red,
    );
  }
}
