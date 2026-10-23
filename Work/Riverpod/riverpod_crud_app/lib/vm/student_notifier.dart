import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_crud_app/model/student.dart';

class StudentNotifier extends AsyncNotifier<List<Student>>{
  final String baseUrl = "http://192.168.20.71:8000";

  @override
  Future<List<Student>> build() async{
    return fetchStudents();
  }

  Future<List<Student>> fetchStudents() async {
    final res = await http.get(Uri.parse("$baseUrl/select"));

    if(res.statusCode != 200){
      throw Exception("불러오기 실패 : ${res.statusCode}");
    }

    final data = json.decode(utf8.decode(res.bodyBytes));
    final results = data['results'] as List? ?? [];

    return results.map((e) => Student.fromJson(e),).toList();
  }

  Future<void> refreshStudents() async{
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async => fetchStudents(),);
  }

  Future<String> insertStudent(Student s)async{
    final url = Uri.parse("$baseUrl/insert");
    final response = await http.post(
      url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(s.toJson()),
      );
    final data = json.decode(utf8.decode(response.bodyBytes));
    await refreshStudents();
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
    await refreshStudents();
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
    await refreshStudents();
    return data['result'];
  }
}

final studentNotifierProvider = AsyncNotifierProvider<StudentNotifier, List<Student>>(StudentNotifier.new);