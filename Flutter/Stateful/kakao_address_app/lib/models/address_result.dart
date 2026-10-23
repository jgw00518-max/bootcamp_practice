/// 우편번호 서비스에서 선택된 기본주소와 우편번호 값이다.
class AddressResult {
  const AddressResult({required this.address, required this.zoneCode});

  final String address;
  final String zoneCode;
}
