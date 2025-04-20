import 'dart:convert';

import 'package:crypto/crypto.dart';

class User {
  String? uid;
  String userName;
  String email;
  DateTime createAt;
  // Constructor
  User({
    required this.uid,
    required this.userName,
    required this.email,
    required this.createAt,
  });

  // Convert User object to Map
  Map<String, dynamic> toMap({required String password}) {
    return {
      'username': userName,
      'email': email,
      'password': hashPassword(password),
    };
  }

  // Create User object from Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      uid: map['id'] ?? '',
      userName: map['userName'] ?? '',
      email: map['email'] ?? '',
      createAt: DateTime.parse(map['createAt']),
    );
  }
  String hashPassword(String password) {
    final bytes = utf8.encode(password); // chuyển password thành bytes
    final digest = sha256.convert(bytes); // băm bằng SHA-256
    return digest.toString();
  }

  // Override toString for easy debug/logging
  @override
  String toString() {
    return 'User(uid: $uid, userName: $userName, email: $email, createAt: $createAt)';
  }
}
