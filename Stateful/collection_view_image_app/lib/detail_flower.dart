import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DetailFlower extends StatefulWidget {
  const DetailFlower({super.key});

  @override
  State<DetailFlower> createState() => _DetailFlowerState();
}

class _DetailFlowerState extends State<DetailFlower> {
  late String flowerName;

  @override
  void initState() {
    super.initState();
    flowerName = Get.arguments ?? "__";
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(flowerName),
      ),
      body: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
          "images/$flowerName",
          width: 300,
          ),
        ),
      ),
    );
  }
}