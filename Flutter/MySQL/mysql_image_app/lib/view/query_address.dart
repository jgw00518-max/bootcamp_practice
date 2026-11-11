import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:mysql_image_app/view/insert_address.dart';
import 'package:mysql_image_app/view/update_address.dart';
import 'package:http/http.dart' as http;

class QueryAddress extends StatefulWidget {
  const QueryAddress({super.key});

  @override
  State<QueryAddress> createState() => _QueryAddressState();
}

class _QueryAddressState extends State<QueryAddress> {
  List data = [];

  @override
  void initState() {
    super.initState();
    getJSONData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('주소록 검색'),
        actions: [
          IconButton(
            onPressed: () =>
                Get.to(InsertAddress())!.then((value) => getJSONData()),
            icon: Icon(Icons.add_outlined),
          ),
        ],
      ),
      body: Center(
        child: data.isEmpty
            ? Center(child: Text('데이터가 없습니다.'))
            : ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return Slidable(
                    key: ValueKey(data[index]['seq']),
                    endActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (context) =>
                              confirmDelete(context, data[index]['seq']),
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: '삭제',
                        ),
                      ],
                    ),
                    child: Card(
                      child: InkWell(
                        onTap: () async {
                          await Get.to(
                            () => UpdateAddress(
                              address: Map<String, dynamic>.from(data[index]),
                            ),
                          );
                          await getJSONData();
                        },
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.network(
                                'http://192.168.20.52:8000/view/${data[index]['seq']}?t=${DateTime.now().microsecondsSinceEpoch}',
                                width: 100,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('이름 : ${data[index]['name']}'),
                                Text('전화번호 : ${data[index]['phone']}'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  } // build

  /// 삭제 전에 사용자의 의사를 확인한다.
  Future<void> confirmDelete(BuildContext context, int seq) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('주소록 삭제'),
          content: const Text('선택한 주소록을 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await deleteAddress(seq);
    }
  }

  /// seq에 해당하는 주소록을 삭제하고 목록을 새로고침한다.
  Future<void> deleteAddress(int seq) async {
    try {
      final url = Uri.parse('http://192.168.20.52:8000/delete');
      final response = await http.post(url, body: {'seq': seq.toString()});
      final responseData = json.decode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && responseData['result'] == 'OK') {
        await getJSONData();
        Get.snackbar('삭제 결과', '삭제가 완료되었습니다.');
      } else {
        deleteErrorSnackBar();
      }
    } catch (e) {
      deleteErrorSnackBar();
    }
  }

  /// 삭제 요청 실패를 사용자에게 알린다.
  void deleteErrorSnackBar() {
    Get.snackbar(
      '문제 발생',
      '삭제 중 문제가 발생했습니다.',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
      colorText: Colors.white,
      backgroundColor: Colors.red,
    );
  }

  Future<void> getJSONData() async {
    var url = Uri.parse("http://192.168.20.52:8000/select");
    var response = await http.get(url);
    data.clear();
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List result = dataConvertedJSON['results'];
    data.addAll(result);
    setState(() {});
  }
} // class
