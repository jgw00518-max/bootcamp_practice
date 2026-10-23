/// 사용자가 별칭과 함께 보관하는 주소 데이터다.
class SavedAddress {
  const SavedAddress({
    required this.id,
    required this.label,
    required this.address,
    required this.zoneCode,
    required this.detailAddress,
  });

  final String id;
  final String label;
  final String address;
  final String zoneCode;
  final String detailAddress;

  /// 수정 화면의 값으로 새 객체를 만든다.
  SavedAddress copyWith({
    String? label,
    String? address,
    String? zoneCode,
    String? detailAddress,
  }) => SavedAddress(
    id: id,
    label: label ?? this.label,
    address: address ?? this.address,
    zoneCode: zoneCode ?? this.zoneCode,
    detailAddress: detailAddress ?? this.detailAddress,
  );

  Map<String, String> toJson() => {
    'id': id,
    'label': label,
    'address': address,
    'zoneCode': zoneCode,
    'detailAddress': detailAddress,
  };

  factory SavedAddress.fromJson(Map<String, dynamic> json) => SavedAddress(
    id: json['id'] as String,
    label: json['label'] as String,
    address: json['address'] as String,
    zoneCode: json['zoneCode'] as String,
    detailAddress: json['detailAddress'] as String,
  );
}
