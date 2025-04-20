import 'dart:convert';
import 'dart:developer';

import 'package:chat_app/models/user.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthServices {
  String backendUrl =
      'https://chat-app-backend1234-78677c67120d.herokuapp.com/api';

  Future<String?> signIn(String email, String password) async {
    try {
      final bytes = utf8.encode(password); // chuyển password thành bytes

      final response = await http.post(
        Uri.parse('$backendUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
            {'email': email, 'password': sha256.convert(bytes).toString()}),
      );

      log('Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userId = data['data']['user']['id'].toString();

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('uId', userId);

        return userId;
      } else {
        return null;
      }
    } catch (e) {
      log('Error: $e');
      return null;
    }
  }

  Future<String?> register(User user, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$backendUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toMap(password: password)),
      );
      log('Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userId = data['data']['user']['id'].toString();
        log('User ID: $userId');
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('uId', userId);

        return userId;
      } else {
        throw Exception('Failed to register user');
      }
    } catch (e) {
      log('Error: $e');
      return null;
    }
  }
}
