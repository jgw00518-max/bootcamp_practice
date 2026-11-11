import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


class CameraView extends StatefulWidget {
  const CameraView({super.key});

  @override
  State<CameraView> createState() => _CameraViewState();
}


class _CameraViewState extends State<CameraView> {

  // Property
  XFile? imageFile;

  final ImagePicker picker = ImagePicker();

  // 카메라가 현재 실행 중인지 확인
  bool isPicking = false;


  @override
  void initState() {
    super.initState();

    // ★ 삭제
    // getImageFromDevice(ImageSource.camera);
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,

      body: Center(

        // ★ 화면을 누르면 카메라 실행
        child: GestureDetector(

          onTap: () {
            getImageFromDevice(ImageSource.camera);
          },

          child: imageFile == null

              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [

                    const Icon(
                      Icons.camera_alt_outlined,
                      size: 80,
                      color: Colors.white,
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    const Text(
                      '화면을 눌러 카메라를 실행하세요.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                )

              : Image.file(
                  File(imageFile!.path),
                ),
        ),
      ),
    );
  }


  // ---------------- Function ----------------

  Future<void> getImageFromDevice(
    ImageSource imageSource,
  ) async {

    // 이미 카메라가 실행 중이면 다시 실행하지 않음
    if (isPicking == true) {
      return;
    }

    isPicking = true;

    try {

      final XFile? pickedFile =
          await picker.pickImage(
        source: imageSource,
      );


      if (!mounted) {
        return;
      }


      // 촬영을 취소한 경우
      if (pickedFile == null) {

        imageFile = null;

      } else {

        // 사진을 촬영한 경우
        imageFile = XFile(
          pickedFile.path,
        );
      }


      setState(() {});

    } finally {

      // 촬영이 끝나면 다시 카메라 실행 가능
      isPicking = false;
    }
  }
}