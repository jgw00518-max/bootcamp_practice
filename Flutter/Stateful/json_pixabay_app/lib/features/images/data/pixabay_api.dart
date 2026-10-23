import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:json_pixabay_app/features/images/domain/pixabay_image.dart';

/// Pixabay REST API 호출과 응답 변환을 담당한다.
class PixabayApi {
  PixabayApi({http.Client? client}) : _client = client ?? http.Client();

  static const _apiKey = '57512584-cdd61e062dea0f8100138b880';
  final http.Client _client;

  /// 현재 검색 조건과 페이지에 맞는 최대 20개 결과를 반환한다.
  Future<PixabaySearchResult> search({
    required String query,
    required int page,
    required PixabaySearchFilter filter,
  }) async {
    final queryParameters = <String, String>{
      'key': _apiKey,
      'q': query,
      'page': '$page',
      'per_page': '20',
      'image_type': filter.imageType.apiValue,
    };
    if (filter.orientation.apiValue case final orientation?) {
      queryParameters['orientation'] = orientation;
    }
    if (filter.category case final category?) {
      queryParameters['category'] = category;
    }

    final response = await _client.get(
      Uri.https('pixabay.com', '/api/', queryParameters),
    );
    if (response.statusCode != 200) {
      throw Exception('이미지를 불러오지 못했습니다. (${response.statusCode})');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return PixabaySearchResult(
      images: (body['hits'] as List<dynamic>)
          .map((hit) => PixabayImage.fromJson(hit as Map<String, dynamic>))
          .toList(),
      totalHits: body['totalHits'] as int? ?? 0,
    );
  }
}
