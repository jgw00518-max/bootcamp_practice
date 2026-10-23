import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sqlite_image_app/model/address.dart';
import 'package:sqlite_image_app/vm/database_handler.dart';

class InsertAddress extends StatefulWidget {
  const InsertAddress({super.key});

  @override
  State<InsertAddress> createState() => _InsertAddressState();
}

class _InsertAddressState extends State<InsertAddress> {
  // property

  DatabaseHandler handler = DatabaseHandler();
  
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController relationController = TextEditingController();

  XFile? imageFile;
  ImagePicker picker = ImagePicker();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('주소록 입력'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: '이름을 입력하세요'
                ),
              ),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: '전화번호를 입력하세요'
                ),
              ),
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: '주소를 입력하세요'
                ),
              ),
              TextField(
                controller: relationController,
                decoration: InputDecoration(
                  labelText: '관계를 입력하세요'
                ),
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  getImageFromGallery(ImageSource.gallery);
                }, 
                child: Text('Gallery')
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 200,
                color: Colors.grey,
                child: Center(
                  child: imageFile == null
                  ? Text('Image is not selected!')
                  :Image.file(File(imageFile!.path)),
                ),
              ),
              SizedBox(
                height: 50,
              ),
              ElevatedButton(
                onPressed: () {
                  insertAction();
                }, 
                child: Text('입력')
              )
            ],
          ),
        ),
      ),
    );
  } // build

  // --- Functions ---
  Future<void> getImageFromGallery(ImageSource imageSource)async{
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    if(pickedFile == null){
      return;
    }else{
      imageFile = XFile(pickedFile.path);
      setState(() {});
    }
  }

  Future<void> insertAction() async{
      // 이미지 : File Tybe을 Byte Type으로 변환하기
      File imageFile1 = File(imageFile!.path);
      Uint8List getImage = await imageFile1.readAsBytes();

      Address addressInsert = Address(
        name: nameController.text.trim(), 
        phone: phoneController.text.trim(), 
        address: addressController.text.trim(), 
        relation: relationController.text.trim(), 
        image: getImage
      );
      int result = await handler.insertAddress(addressInsert);
      if(result == 0){
        errorSnackbar();
      }else{
        _showDialog();
      }
  }

  void errorSnackbar(){
    Get.snackbar("경고", "문제가 발생했습니다.");
  }

  void _showDialog(){
    Get.defaultDialog(
      title: '입력 결과',
      middleText: '입력이 완료되었습니다.',
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