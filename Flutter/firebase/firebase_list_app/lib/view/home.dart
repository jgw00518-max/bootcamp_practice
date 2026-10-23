import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_list_app/model/student.dart';
import 'package:firebase_list_app/view/insert.dart';
import 'package:firebase_list_app/view/update.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firestore List'),
        actions: [
          IconButton(
            onPressed: () => Get.to(Insert()),
            icon: Icon(Icons.add_outlined)
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
                .collection("students")
                .orderBy('code', descending: false)
                .snapshots(), 
        builder: (context, snapshot) {
          if(!snapshot.hasData){
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final documents = snapshot.data!.docs;
          return ListView(
            children: documents.map((e) => buildItemWidget(e)).toList(),
          );
        },
      ),
    );
  } // build

  // --- Functions ---
  Widget buildItemWidget(DocumentSnapshot doc){
    final student = Student(
      code: doc['code'], 
      name: doc['name'], 
      dept: doc['dept'], 
      phone: doc['phone'], 
      image: doc['image']
    );

    return GestureDetector(
      onTap: () {
        Get.to(Update(),
        arguments: [
          doc.id,
          student.code,
          student.name,
          student.dept,
          student.phone,
          student.image
        ]
        );
      },
      child: Slidable(
        endActionPane: ActionPane(
          motion: BehindMotion(), 
          children: [
            SlidableAction(
              backgroundColor: Colors.red,
              icon: Icons.delete_forever,
              label: '삭제',
              onPressed: (context) async{
                await deleteImage(student.code);
                FirebaseFirestore.instance
                                .collection('students')
                                .doc(doc.id)
                                .delete();
              },
            )
          ]
        ),
        child: Card(
          child: ListTile(
            title: Row(
              children: [
                Image.network(
                  student.image,
                  width: 70,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "학번 : ${student.code}\n이름: ${student.name}\n학과: ${student.dept}\n전화번호: ${student.phone}"
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> deleteImage(String code) async{
    final firebaseStorage = FirebaseStorage.instance
                            .ref()
                            .child('images')
                            .child("$code.png");
    await firebaseStorage.delete();
  }

} // class