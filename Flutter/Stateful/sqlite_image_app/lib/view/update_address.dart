import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sqlite_image_app/model/address.dart';
import 'package:sqlite_image_app/vm/database_handler.dart';

class UpdateAddress extends StatefulWidget {
  const UpdateAddress({super.key});

  @override
  State<UpdateAddress> createState() => _UpdateAddressState();
}

class _UpdateAddressState extends State<UpdateAddress> {
  // property

  DatabaseHandler handler = DatabaseHandler();
  
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController relationController = TextEditingController();
  late Uint8List originalImage;

  var value = Get.arguments ?? "__";

    @override
  void initState() {
    super.initState();
    nameController.text = value[0];
    phoneController.text = value[1];
    addressController.text = value[2];
    relationController.text = value[3];
    originalImage = value[4] as Uint8List;
  }

  XFile? imageFile;
  ImagePicker picker = ImagePicker();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('주소록 수정'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: '이름을 수정하세요'
                ),
              ),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: '전화번호를 수정하세요'
                ),
              ),
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: '주소를 수정하세요'
                ),
              ),
              TextField(
                controller: relationController,
                decoration: InputDecoration(
                  labelText: '관계를 수정하세요'
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
                  ? Image.memory(
                      originalImage,
                      fit: BoxFit.contain,
                    )
                  :Image.file(File(imageFile!.path)),
                ),
              ),
              SizedBox(
                height: 50,
              ),
              ElevatedButton(
                onPressed: () {
                  updateAction();
                }, 
                child: Text('수정')
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

  Future<void> updateAction() async{
      // 이미지 : File Tybe을 Byte Type으로 변환하기
      Uint8List updateImage;
        if (imageFile == null) {
    // 새 이미지를 선택하지 않았으면 기존 이미지 사용
          updateImage = originalImage;
        } else {
          // 새 이미지를 선택했으면 바이트 데이터로 변환
          final File selectedImage = File(imageFile!.path);
          updateImage = await selectedImage.readAsBytes();
        }

      Address addressInsert = Address(
        name: nameController.text.trim(), 
        phone: phoneController.text.trim(), 
        address: addressController.text.trim(), 
        relation: relationController.text.trim(), 
        image: updateImage
      );
      int result = await handler.updateAddress(addressInsert);
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
      title: '수정 결과',
      middleText: '수정이 완료되었습니다.',
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