import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mysql_todo_list_app/model/todo_item.dart';

/// FastAPI와 통신해 현재 목록과 삭제 목록을 관리한다.
class TodoApi {
  TodoApi({http.Client? client, this.baseUrl = defaultBaseUrl})
    : _client = client ?? http.Client(),
      _ownsClient = client == null;

  static const String defaultBaseUrl = 'http://192.168.20.52:8000';

  final http.Client _client;
  final bool _ownsClient;
  final String baseUrl;

  /// 현재 Todo 목록을 서버 정렬 순서대로 가져온다.
  Future<List<TodoItem>> fetchTodos() async {
    final response = await _client.get(Uri.parse('$baseUrl/todos'));
    final body = _decodeBody(response);
    final results = body['results'];

    if (results is! List) {
      throw const TodoApiException('Todo 목록 형식이 올바르지 않습니다.');
    }

    return results
        .map(
          (item) => TodoItem.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  /// 제목을 Form 데이터로 전송해 오늘 날짜의 Todo를 추가한다.
  Future<void> addTodo(String title) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/todos'),
      body: {'title': title},
    );
    final body = _decodeBody(response);

    if (body['result'] != 'OK') {
      throw const TodoApiException('Todo 추가에 실패했습니다.');
    }
  }

  /// 선택한 Todo 번호를 Form 데이터로 전송해 삭제 목록으로 이동한다.
  Future<void> deleteTodo(int seq) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/todos/delete'),
      body: {'seq': seq.toString()},
    );
    final body = _decodeBody(response);

    if (body['result'] != 'OK') {
      throw const TodoApiException('Todo 삭제에 실패했습니다.');
    }
  }

  /// 최근 삭제된 순서로 정렬된 삭제 목록을 가져온다.
  Future<List<DeletedTodoItem>> fetchDeletedTodos() async {
    final response = await _client.get(Uri.parse('$baseUrl/deleted-todos'));
    final body = _decodeBody(response);
    final results = body['results'];

    if (results is! List) {
      throw const TodoApiException('삭제 목록 형식이 올바르지 않습니다.');
    }

    return results
        .map(
          (item) =>
              DeletedTodoItem.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  /// 삭제 목록 번호를 Form 데이터로 전송해 현재 목록으로 복구한다.
  Future<void> restoreTodo(int seq) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/deleted-todos/restore'),
      body: {'seq': seq.toString()},
    );
    final body = _decodeBody(response);

    if (body['result'] != 'OK') {
      throw const TodoApiException('Todo 복구에 실패했습니다.');
    }
  }

  Map<String, dynamic> _decodeBody(http.Response response) {
    Map<String, dynamic> body;

    try {
      body =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    } on FormatException {
      throw const TodoApiException('서버 응답을 읽을 수 없습니다.');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw TodoApiException(body['detail'] as String? ?? '서버 요청에 실패했습니다.');
    }

    return body;
  }

  /// 이 객체가 직접 만든 HTTP 연결만 정리한다.
  void close() {
    if (_ownsClient) {
      _client.close();
    }
  }
}

/// 사용자에게 표시할 수 있는 API 오류 메시지를 보관한다.
class TodoApiException implements Exception {
  const TodoApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
