import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';

/// ViewModel이 플랫폼 위치 기능에 의존하지 않도록 전달하는 현재 좌표다.
class UserLocation {
  const UserLocation({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
}

/// 실제 위치와 테스트용 위치를 교체할 수 있게 하는 위치 조회 계약이다.
abstract interface class LocationDataSource {
  Future<UserLocation> getCurrentLocation();
}

/// 위치 서비스와 권한을 확인한 뒤 현재 기기 좌표를 조회한다.
class DeviceLocationService implements LocationDataSource {
  const DeviceLocationService();

  @override
  Future<UserLocation> getCurrentLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw StateError('기기의 위치 서비스를 켜 주세요.');
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        throw StateError('현재 위치를 사용하려면 위치 권한이 필요합니다.');
      }
      if (permission == LocationPermission.deniedForever) {
        throw StateError('앱 설정에서 위치 권한을 허용해 주세요.');
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      return UserLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } on MissingPluginException {
      throw StateError('위치 기능 적용을 위해 앱을 완전히 종료한 후 다시 실행해 주세요.');
    }
  }
}
