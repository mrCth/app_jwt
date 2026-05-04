class User {
  final int id;
  final String fname;
  final String lname;
  final String username;
  final String email;
  final String avatar;

  User({
    required this.id,
    required this.fname,
    required this.lname,
    required this.username,
    required this.email,
    required this.avatar,
  });

  // แปลง JSON จาก API เป็น User object
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      fname: json['fname'],
      lname: json['lname'],
      username: json['username'],
      email: json['email'],
      avatar: json['avatar'],
    );
  }

  // Helper สำหรับแสดงชื่อเต็มได้ง่ายๆ
  String get fullName => '$fname $lname';
}
