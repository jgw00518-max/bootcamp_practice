import 'package:geocoding/geocoding.dart';

import 'location_service.dart';

/// 주소 검색 결과의 좌표와 화면에 표시할 도로 주소를 함께 전달한다.
class AddressLocation {
  const AddressLocation({required this.location, required this.address});

  final UserLocation location;
  final String address;
}

/// 실제 지오코딩과 테스트용 주소 변환을 교체할 수 있게 하는 계약이다.
abstract interface class AddressDataSource {
  Future<AddressLocation> findByAddress(String address);

  Future<String> findAddress(double latitude, double longitude);
}

/// 기기의 지오코딩 서비스를 이용해 주소와 위경도를 서로 변환한다.
class DeviceGeocodingService implements AddressDataSource {
  const DeviceGeocodingService();

  @override
  Future<AddressLocation> findByAddress(String address) async {
    final query = address.trim();
    if (query.isEmpty) throw ArgumentError('검색할 주소를 입력해 주세요.');
    final locations = await Geocoding().locationFromAddress(query);
    if (locations.isEmpty) throw StateError('주소를 찾을 수 없습니다.');
    final location = locations.first;
    String resolvedAddress;
    try {
      resolvedAddress = await findAddress(
        location.latitude,
        location.longitude,
      );
    } catch (_) {
      resolvedAddress = query;
    }
    return AddressLocation(
      location: UserLocation(
        latitude: location.latitude,
        longitude: location.longitude,
      ),
      address: resolvedAddress,
    );
  }

  @override
  Future<String> findAddress(double latitude, double longitude) async {
    final placemarks = await Geocoding().placemarkFromCoordinates(
      latitude,
      longitude,
    );
    if (placemarks.isEmpty) throw StateError('선택한 위치의 주소를 찾을 수 없습니다.');
    return _formatAddress(placemarks.first);
  }

  /// 운영체제가 반환한 주소 요소에서 중복과 빈 값을 제거해 한국식 주소로 조합한다.
  String _formatAddress(Placemark placemark) {
    final parts = <String>[];
    for (final value in [
      placemark.administrativeArea,
      placemark.locality,
      placemark.subLocality,
      placemark.thoroughfare,
      placemark.subThoroughfare,
    ]) {
      final part = value?.trim() ?? '';
      if (part.isNotEmpty && !parts.contains(part)) parts.add(part);
    }
    if (parts.isEmpty) throw StateError('선택한 위치의 주소를 찾을 수 없습니다.');
    return parts.join(' ');
  }
}
