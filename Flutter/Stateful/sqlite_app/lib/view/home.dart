import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:sqlite_app/view/insert_students.dart';
import 'package:sqlite_app/view/update_students.dart';
import 'package:sqlite_app/vm/database_handler.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  DatabaseHandler handler = DatabaseHandler();  // Database

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SQLite for Students'),
        actions: [
          IconButton(
            onPressed: () => Get.to(InsertStudents())!.then((value) => reloadData()),
            icon: Icon(Icons.add_outlined)
          )
        ],
      ),
      body: FutureBuilder(
        future: handler.queryStudents(), 
        builder: (context, snapshot) {
          return snapshot.hasData && snapshot.data!.isNotEmpty
          ? ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return Slidable(
                endActionPane: ActionPane(
                  motion: BehindMotion(), 
                  children: [
                    SlidableAction(
                      backgroundColor: Colors.red,
                      icon: Icons.delete,
                      label: '삭제',
                      onPressed: (context) async{
                        await handler.deleteStudents(snapshot.data![index].id!);
                        setState(() {});
                      }, 
                    )
                  ]
                ),
                child: GestureDetector(
                  onTap: () {
                    Get.to(
                      UpdateStudents(),
                      arguments: [
                        snapshot.data![index].code,
                        snapshot.data![index].name,
                        snapshot.data![index].dept,
                        snapshot.data![index].phone,
                      ]
                    )!.then((value) => reloadData());
                  },
                  child: SizedBox(
                    width: MediaQuery.widthOf(context),
                    child: Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Code : ${snapshot.data![index].code}'),
                          Text('Name : ${snapshot.data![index].name}'),
                          Text('Dept : ${snapshot.data![index].dept}'),
                          Text('Phone : ${snapshot.data![index].phone}')
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          )
          : Center(
            child: Text('Data가 없습니다!'),
          );
        },
      ),
    );
  } // build

  // --- Functions ---
  void reloadData(){
    handler.queryStudents();
    setState(() {});
  }



} // class