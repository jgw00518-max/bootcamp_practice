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
      code: json['code'] ?? "__", // ?? "__" -> null일 경우에 "__"로 대체한다는 뜻.(조금 더 안전함)
      name: json['name'] ?? "__",
      dept: json['dept'] ?? "__",
      phone: json['phone'] ?? "__",
      address: json['address'] ?? "__",
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
