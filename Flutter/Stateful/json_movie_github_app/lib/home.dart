import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;

import 'edit_movie.dart';

/// API 영화 목록과 현재 실행 중의 수정·삭제 상태를 관리한다.
class Home extends StatefulWidget {
  const Home({super.key, this.client});

  /// 테스트에서는 외부 요청 대신 가짜 HTTP 응답을 주입한다.
  final http.Client? client;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<Map<String, dynamic>> _movies = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    getJSONData();
  }

  /// GitHub JSON을 읽고 로딩, 실패, 빈 목록을 구분한다.
  Future<void> getJSONData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final url = Uri.parse('https://zeushahn.github.io/Test/movies.json');
      final response = await (widget.client?.get(url) ?? http.get(url));
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }
      final decoded = json.decode(utf8.decode(response.bodyBytes));
      final movies = (decoded['results'] as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
      if (!mounted) return;
      setState(() {
        _movies
          ..clear()
          ..addAll(movies);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = '영화 목록을 불러오지 못했습니다.';
        _loading = false;
      });
    }
  }

  /// 사용자가 경고창에서 확인한 경우에만 해당 영화를 제거한다.
  Future<void> _deleteMovie(Map<String, dynamic> movie) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('경고'),
        content: Text('"${movie['title']}" 항목을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    setState(() => _movies.remove(movie));
  }

  /// 수정 화면에서 반환한 제목만 목록에 반영한다.
  Future<void> _editMovie(Map<String, dynamic> movie) async {
    final title = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => EditMovie(
          title: movie['title'] as String,
          imageUrl: movie['image'] as String,
        ),
      ),
    );
    if (!mounted || title == null) return;
    setState(() => movie['title'] = title);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JSON & Slider Test'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_error!),
                  TextButton(
                    onPressed: getJSONData,
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            )
          : _movies.isEmpty
          ? const Center(child: Text('영화 목록이 없습니다.'))
          : SlidableAutoCloseBehavior(
              child: ListView.builder(
                itemCount: _movies.length,
                itemBuilder: (context, index) {
                  final movie = _movies[index];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(6, 0, 6, 6),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Slidable(
                        key: ObjectKey(movie),
                        // 오른쪽 드래그는 수정, 왼쪽 드래그는 삭제 버튼을 연다.
                        startActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (_) => _editMovie(movie),
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              icon: Icons.edit,
                              label: 'Edit',
                            ),
                          ],
                        ),
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (_) => _deleteMovie(movie),
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Delete',
                            ),
                          ],
                        ),
                        child: Container(
                          color: index.isEven
                              ? const Color(0xFF655A73)
                              : const Color(0xFF805568),
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            children: [
                              Image.network(
                                movie['image'] as String,
                                width: 100,
                                height: 145,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => const SizedBox(
                                  width: 100,
                                  height: 145,
                                  child: Icon(Icons.broken_image_outlined),
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: Text(
                                  movie['title'] as String,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
