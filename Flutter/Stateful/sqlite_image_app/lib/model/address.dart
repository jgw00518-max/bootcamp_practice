import 'dart:typed_data';

class Address {
  int? id;
  String name;
  String phone;
  String address;
  String relation;
  Uint8List image;

  Address(
    {
      this.id,
      required this.name,
      required this.phone,
      required this.address,
      required this.relation,
      required this.image,
    }
  );

  Address.fromMap(Map<String, dynamic> res)
  : id = res['id'],
  name = res['name'],
  phone = res['phone'],
  address = res['address'],
  relation = res['relation'],
  image = res['image'];

}