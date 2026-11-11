import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider_crud_app/model/student.dart';

class StudentModel extends ChangeNotifier{
  final String baseUrl = "http://192.168.20.71:8000";
  List<Student> students = [];
  bool isLoading = false;
  String? error;

  Future<void> fetchStudents() async {
    isLoading = true;
    error = null;

    try {
      final res = await http.get(Uri.parse("$baseUrl/select"));
      final data = json.decode(utf8.decode(res.bodyBytes));
      students = (data['results'] as List)
          .map((e) => Student.fromJson(e))
          .toList();
    } catch (e) {
      error = "불러오기 실패 : $e";
    } finally {
      isLoading = false;
      notifyListeners();
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
