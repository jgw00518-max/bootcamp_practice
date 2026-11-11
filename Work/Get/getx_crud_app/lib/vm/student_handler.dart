import 'dart:convert';

import 'package:get/get.dart';
import 'package:getx_crud_app/model/student.dart';
import 'package:http/http.dart' as http;

class StudentHandler extends GetxController {
  final String baseUrl = "http://192.168.20.71:8000";
  RxList<Student> students = <Student>[].obs;
  RxBool isLoading = false.obs;
  RxString error = "".obs;

  Future<void> fetchStudents() async {
    isLoading.value = true;
    error.value = '';

    try {
      final res = await http.get(Uri.parse("$baseUrl/select"));
      final data = json.decode(utf8.decode(res.bodyBytes));
      students.value = (data['results'] as List)
          .map((e) => Student.fromJson(e))
          .toList();
    } catch (e) {
      error.value = "불러오기 실패 : $e";
    } finally {
      isLoading.value = false;
    }
  }

  Future<String> insertStudent(Student s)async{
    final url = Uri.parse("$baseUrl/insert");
    final response = await http.post(
      url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(s.toJson()),
      );
    final data = json.decode(utf8.decode(response.bodyBytes));
    await fetchStudents();
    return data['result'];
  }

  Future<String> updateStudent(Student s) async {
    final url = Uri.parse('$baseUrl/update');
    final response = await http.post(
      url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(s.toJson()),
      );
    final data = json.decode(utf8.decode(response.bodyBytes));
    await fetchStudents();
    return data['result'];
  }

  Future<String> deleteStudent(String code) async {
    final url = Uri.parse('$baseUrl/delete');
    final response = await http.post(
      url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'code':code}),
      );
    final data = json.decode(utf8.decode(response.bodyBytes));
    await fetchStudents();
    return data['result'];
  }
}
