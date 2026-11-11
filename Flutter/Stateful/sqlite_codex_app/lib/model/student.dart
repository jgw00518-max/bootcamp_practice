class Student {
  const Student({
    required this.code,
    required this.name,
    required this.department,
    required this.phone,
  });

  final String code;
  final String name;
  final String department;
  final String phone;

  Map<String, Object?> toMap() {
    return {
      'code': code,
      'name': name,
      'department': department,
      'phone': phone,
    };
  }

  factory Student.fromMap(Map<String, Object?> map) {
    return Student(
      code: map['code']! as String,
      name: map['name']! as String,
      department: map['department']! as String,
      phone: map['phone']! as String,
    );
  }
}
