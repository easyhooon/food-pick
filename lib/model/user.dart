class UserModel {
  int? id;
  String? profileUrl;
  String name;
  String email;
  String introduce;
  String uid;
  DateTime? createdAt;

  UserModel({
    this.id,
    this.profileUrl,
    required this.name,
    required this.email,
    required this.introduce,
    required this.uid,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'profile_url': profileUrl,
      'name': name,
      'email': email,
      'introduce': introduce,
      'uid': uid,
    };
  }

  // 메소드를 싱글톤으로 쓰는 방법
  factory UserModel.fromJson(Map<dynamic, dynamic> json) {
    return UserModel(
      id: json['id'],
      profileUrl: json['profile_url'],
      name: json['name'],
      email: json['email'],
      introduce: json['introduce'],
      uid: json['uid'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
