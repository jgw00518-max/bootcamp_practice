import 'package:flutter_test/flutter_test.dart';
import 'package:kakao_address_app/models/saved_address.dart';
import 'package:kakao_address_app/repositories/saved_address_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('저장소는 별칭과 상세주소를 포함한 주소 목록을 보관한다', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = SavedAddressRepository();
    const address = SavedAddress(
      id: 'home',
      label: '집',
      address: '서울특별시 강남구 테헤란로 1',
      zoneCode: '06236',
      detailAddress: '101동 1001호',
    );

    await repository.saveAll([address]);

    final loaded = await repository.load();
    expect(loaded, hasLength(1));
    expect(loaded.single.label, '집');
    expect(loaded.single.detailAddress, '101동 1001호');
  });
}
