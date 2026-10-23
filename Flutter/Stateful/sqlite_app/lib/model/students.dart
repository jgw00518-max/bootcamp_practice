class Students{
  // Property : Database의 Table의 Column이름
  int? id; // Auto Increment
  String code;
  String name;
  String dept;
  String phone;

  // Constructor
  Students(
    {
      this.id,
      required this.code,
      required this.name,
      required this.dept,
      required this.phone
    }
  );
  
  // 방법 1
  // factory Students.fromMap(Map<String,dynamic> res){
  //   return Students(
  //     id: res['id'],
  //     code: res['code'], 
  //     name: res['name'], 
  //     dept: res['dept'], 
  //     phone: res['phone']
  //   );
  // }
  
  // 방법 2
  Students.fromMap(Map<String,dynamic> res)
    : id = res['id'],
    code = res['code'], 
    name = res['name'], 
    dept = res['dept'], 
    phone = res['phone'];

}