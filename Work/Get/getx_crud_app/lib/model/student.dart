class Student {
  final String code;
  final String name;
  final String dept;
  final String phone;
  final String address;

  Student({
    required this.code,
    required this.name,
    required this.dept,
    required this.phone,
    required this.address,
  });

  // 서버에서 받은 JSON -> Student객체
  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      code: json['code'],
      name: json['name'],
      dept: json['dept'],
      phone: json['phone'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'dept': dept,
      'phone': phone,
      'address': address,
    };
  }
}
