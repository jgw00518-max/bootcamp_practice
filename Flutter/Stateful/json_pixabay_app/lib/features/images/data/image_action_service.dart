import 'package:gal/gal.dart';
import 'package:http/http.dart' as http;
import 'package:json_pixabay_app/features/images/domain/pixabay_image.dart';
import 'package:share_plus/share_plus.dart';

/// 원본 이미지 저장과 링크 공유 같은 기기 연동 동작을 담당한다.
class ImageActionService {
  ImageActionService({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  /// 원본 이미지를 내려받아 사용자의 기본 사진 갤러리에 저장한다.
  Future<void> saveToGallery(PixabayImage image) async {
    final response = await _client.get(Uri.parse(image.largeImageUrl));
    if (response.statusCode != 200) throw Exception('다운로드에 실패했습니다.');
    await Gal.putImageBytes(
      response.bodyBytes,
      name: 'pixabay_${image.id}.jpg',
    );
  }

  /// 원본 이미지 주소를 운영체제의 공유 시트로 전달한다.
  Future<void> shareUrl(PixabayImage image) => SharePlus.instance.share(
    ShareParams(text: '${image.tags}\n${image.largeImageUrl}'),
  );
}
