import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class InsertAddress extends StatefulWidget {
  const InsertAddress({super.key});

  @override
  State<InsertAddress> createState() => _InsertAddressState();
}

class _InsertAddressState extends State<InsertAddress> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController relationController = TextEditingController();

  XFile? imageFile;
  final ImagePicker picker = ImagePicker();

  // ImagePicker에서 선택된 filename
  String filename = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('주소록 입력')),
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
                      ? Text('이미지가 선택 되지 않았습니다.')
                      : Image.file(File(imageFile!.path)),
                ),
              ),
            ),
            ElevatedButton(onPressed: () => insertAction(), child: Text('입력')),
          ],
        ),
      ),
    );
  } // build

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
      gallerySnackBar();
    } else {
      imageFile = XFile(pickedFile.path);
    }
    setState(() {});
  }

  void gallerySnackBar() {
    Get.snackbar(
      "문제 발생",
      "이미지를 선택하세요",
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 2),
      colorText: Colors.white,
      backgroundColor: Colors.red,
    );
  }

  Future<void> insertAction() async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.20.52:8000/upload'),
    );
    request.fields['name'] = nameController.text.trim();
    request.fields['phone'] = phoneController.text.trim();
    request.fields['address'] = addressController.text.trim();
    request.fields['relation'] = relationController.text.trim();
    request.files.add(
      await http.MultipartFile.fromPath('file', imageFile!.path),
    );

    var res = await request.send();
    if (res.statusCode == 200) {
      _showDialog();
    } else {
      errorSnackBar();
    }
  }

  void _showDialog() {
    Get.defaultDialog(
      title: '입력 결과',
      middleText: '입력이 완료 되었습니다.',
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
      "입력 중 문제가 발생하였습니다.",
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 2),
      colorText: Colors.white,
      backgroundColor: Colors.red,
    );
  }
} // class
