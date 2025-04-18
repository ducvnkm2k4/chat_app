class User {
  String? uid;
  String userName;
  String email;
  String avatar;
  DateTime createAt;

  // Constructor
  User({
    required this.uid,
    required this.userName,
    required this.email,
    required this.avatar,
    required this.createAt,
  });

  // Convert User object to Map
  Map<String, dynamic> toMap({String? password}) {
    return {
      'userName': userName,
      'email': email,
      'avatar': avatar,
      'createAt': createAt.toIso8601String(),
      'password': password
    };
  }

  // Create User object from Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      uid: map['uid'] ?? '',
      userName: map['userName'] ?? '',
      email: map['email'] ?? '',
      avatar: map['avatar'] ?? '',
      createAt: DateTime.parse(map['createAt']),
    );
  }

  // Override toString for easy debug/logging
  @override
  String toString() {
    return 'User(uid: $uid, userName: $userName, email: $email, avatar: $avatar, createAt: $createAt)';
  }
}
