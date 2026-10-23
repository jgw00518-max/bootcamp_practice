import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/saved_address.dart';

/// 저장 주소 목록을 기기 로컬 저장소에 JSON 형태로 보관한다.
class SavedAddressRepository {
  static const _storageKey = 'saved_addresses';

  Future<List<SavedAddress>> load() async {
    final preferences = await SharedPreferences.getInstance();
    final rawAddresses = preferences.getStringList(_storageKey) ?? [];
    return rawAddresses
        .map(
          (raw) =>
              SavedAddress.fromJson(jsonDecode(raw) as Map<String, dynamic>),
        )
        .toList();
  }

  Future<void> saveAll(List<SavedAddress> addresses) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      _storageKey,
      addresses.map((address) => jsonEncode(address.toJson())).toList(),
    );
  }
}
