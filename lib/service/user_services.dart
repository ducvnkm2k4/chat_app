import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import '../models/user.dart';

class UserServices {
  static final _db = FirebaseFirestore.instance.collection('users');

  static String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  // Đăng ký người dùng
  static Future<String?> signUpUser(User user, String password) async {
    try {
      String uid = DateTime.now().millisecondsSinceEpoch.toString();
      String hashedPassword = _hashPassword(password);

      await _db.doc(uid).set(user.toMap(password: hashedPassword));

      final prefs = await SharedPreferences.getInstance();
      prefs.setString('uId', uid);

      return uid;
    } catch (e) {
      throw Exception("Sign up failed: $e");
    }
  }

  // Đăng nhập
  static Future<String?> logInUser(String email, String password) async {
    try {
      String hashedPassword = _hashPassword(password);

      QuerySnapshot snapshot = await _db.where('email', isEqualTo: email).get();
      if (snapshot.docs.isEmpty) throw Exception("Email không tồn tại");

      var userData = snapshot.docs.first.data() as Map<String, dynamic>;
      String uid = snapshot.docs.first.id;
      if (userData['password'] != hashedPassword) {
        throw Exception("Mật khẩu sai");
      }

      final prefs = await SharedPreferences.getInstance();
      prefs.setString('uId', uid);

      return uid;
    } catch (e) {
      throw Exception("Login failed: $e");
    }
  }

  // Đăng xuất
  static Future<void> logOutUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('uId');
  }

  // Kiểm tra đăng nhập
  static Future<User?> findUserByID(String userId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await _db.doc(userId).get();

      if (!snapshot.exists) {
        log('User with ID $userId not found.');
        return null;
      }

      final userData = snapshot.data();
      if (userData == null) return null;

      return User.fromMap(userData);
    } catch (e) {
      log('Error getting user by ID: $e');
      return null;
    }
  }
}
