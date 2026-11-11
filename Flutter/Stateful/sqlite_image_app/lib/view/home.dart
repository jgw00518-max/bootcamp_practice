import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:sqlite_image_app/model/address.dart';
import 'package:sqlite_image_app/view/insert_address.dart';
import 'package:sqlite_image_app/view/update_address.dart';
import 'package:sqlite_image_app/vm/database_handler.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Property
  DatabaseHandler handler = DatabaseHandler();

  /// 이름 검색어를 입력받는 컨트롤러입니다.
  final TextEditingController searchController = TextEditingController();

  /// 현재 검색 조건으로 화면에 표시할 주소록을 조회합니다.
  Future<List<Address>> searchAddress() {
    final String keyword = searchController.text.trim();
    return keyword.isEmpty
        ? handler.queryAddress()
        : handler.searchAddressByName(keyword);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('주소록 검색'),
        actions: [
          IconButton(
            onPressed: () {
              Get.to(InsertAddress())!.then((value) => reloadData());
            },
            icon: Icon(Icons.add_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: FutureBuilder<int>(
              future: handler.countAddress(),
              builder: (context, snapshot) {
                final int count = snapshot.data ?? 0;
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '전체 수: $count명',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: '이름 검색',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: searchAddress(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('검색 결과가 없습니다.'));
                }

                return ListView.builder(
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
                            onPressed: (context) async {
                              await handler.deleteAddress(
                                snapshot.data![index].id!,
                              );
                              reloadData();
                            },
                          ),
                        ],
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Get.to(
                            UpdateAddress(),
                            arguments: [
                              snapshot.data![index].name,
                              snapshot.data![index].phone,
                              snapshot.data![index].address,
                              snapshot.data![index].relation,
                              snapshot.data![index].image,
                            ],
                          )!.then((value) => reloadData());
                        },
                        child: Card(
                          child: Row(
                            children: [
                              Image.memory(
                                snapshot.data![index].image,
                                width: 100,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '이름 : ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(snapshot.data![index].name),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        '전화번호 : ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(snapshot.data![index].phone),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  } // build

  // --- Functions ---
  /// 추가·수정·삭제 후 목록과 전체 카드 수를 다시 조회합니다.
  void reloadData() {
    setState(() {});
  }
} // class
