import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class Insert extends StatefulWidget {
  const Insert({super.key});

  @override
  State<Insert> createState() => _InsertState();
}

class _InsertState extends State<Insert> {
  TextEditingController codeController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController deptController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  XFile? imageFile;
  final ImagePicker picker = ImagePicker();
  File? imgFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Insert for Firebase"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: codeController,
              decoration: InputDecoration(labelText: '학번을 입력하세요'),
            ),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: '이름을 입력하세요'),
            ),
            TextField(
              controller: deptController,
              decoration: InputDecoration(labelText: '전공을 입력하세요'),
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: '전화번호를 입력하세요'),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                onPressed: () => getImageFromGallery(ImageSource.gallery), 
                child: Text('Gallery')
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 200,
              color: Colors.grey,
              child: Center(
                child: imageFile == null
                ? Text('Image is not selected!')
                : Image.file(File(imageFile!.path)),
              ),
            ),
            ElevatedButton(
              onPressed: () => insertAction(), 
              child: Text('입력')
            ),
          ],
        ),
      ),
    );
  } // build


  // --- Functions ---
  Future<void> getImageFromGallery(ImageSource imageSource) async{
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    imageFile = XFile(pickedFile!.path);
    imgFile = File(imageFile!.path);
    setState(() {});
  }

  // Firestore에 데이터 입력하기
  Future<void> insertAction() async{
    String image = await preparingImage();

    FirebaseFirestore.instance.collection('students').add(
      {
        'code':codeController.text,
        'name':nameController.text,
        'dept':deptController.text,
        'phone':phoneController.text,
        'image': image
      }
    );
    _showDialog();
  }

  // Storage에 이미지 저장하기
  Future<String> preparingImage() async{
    final firebaseStorage = FirebaseStorage.instance
                            .ref()
                            .child('images')
                            .child("${codeController.text}.png");
    await firebaseStorage.putFile(imgFile!);
    String downloadURL = await firebaseStorage.getDownloadURL();
    return downloadURL;
  }

  void _showDialog(){
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
          child: Text('OK')
        )
      ]
    );
  }

} // class