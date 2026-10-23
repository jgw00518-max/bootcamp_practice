import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class Update extends StatefulWidget {
  const Update({super.key});

  @override
  State<Update> createState() => _UpdateState();
}

class _UpdateState extends State<Update> {
  TextEditingController codeController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController deptController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  var value = Get.arguments ?? "__";

  XFile? imageFile;
  final ImagePicker picker = ImagePicker();
  File? imgFile;
  int firstDisp = 0;  // Gallery를 실행 했는지 안했는지 파악

  @override
  void initState() {
    super.initState();
    codeController.text = value[1];
    nameController.text = value[2];
    deptController.text = value[3];
    phoneController.text = value[4];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Update for Firebase"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: codeController,
              decoration: InputDecoration(labelText: '학번'),
              readOnly: true,
            ),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: '이름'),
            ),
            TextField(
              controller: deptController,
              decoration: InputDecoration(labelText: '전공'),
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: '전화번호'),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                onPressed: () => getImageFromGallery(ImageSource.gallery), 
                child: Text('Gallery')
              ),
            ),
            firstDisp == 0
            ? Container(
                width: MediaQuery.of(context).size.width,
                height: 200,
                color:  Colors.grey,
                child: Center(
                  child: Image.network(value[5]),
                ),
              )
            : Container(
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
              onPressed: () {
                if(firstDisp == 0){
                  updateAction();
                }else{
                  updateActionAll();
                }
              },
              child: Text('수정')
            ),
          ],
        ),
      ),
    );
  } // build


  // --- Functions ---
  Future<void> getImageFromGallery(ImageSource imageSource) async{
    firstDisp += 1;
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    imageFile = XFile(pickedFile!.path);
    imgFile = File(imageFile!.path);
    setState(() {});
  }

  // Firestore에 데이터 수정하기
  Future<void> updateAction() async{
    FirebaseFirestore.instance.collection('students').doc(value[0]).update(
      {
        'code':codeController.text,
        'name':nameController.text,
        'dept':deptController.text,
        'phone':phoneController.text,
      }
    );
    _showDialog();
  }

  Future<void> updateActionAll() async{
    await deleteImage();
    String image = await preparingImage();

    FirebaseFirestore.instance.collection('students').doc(value[0]).update(
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

  // Storage에 이미지 삭제
    Future<void> deleteImage() async{
    final firebaseStorage = FirebaseStorage.instance
                            .ref()
                            .child('images')
                            .child("${codeController.text}.png");
    await firebaseStorage.delete();
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
      title: '수정 결과',
      middleText: '수정이 완료 되었습니다.',
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
}