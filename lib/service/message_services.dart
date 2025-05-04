import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:developer';
import 'package:fluttertoast/fluttertoast.dart';

class MessageServices {
  String backendUrl = 'http://192.168.161.167:8000/api';

  Future<List<Map<String, dynamic>>> getMessages() async {
    try {
      final response = await http.get(
        Uri.parse('$backendUrl/messages'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10)); // Thêm timeout cho GET request

      final data = jsonDecode(response.body); // Giải mã JSON trước
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(data['data']['messages']);
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      log('Error: $e');
      return [];
    }
  }

  Future<bool> sendMessage(String message, String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$backendUrl/messages'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'message': message,
          'userid': userId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        log('✅ Message sent: ${data['message']}');
        log('⚠️ Phishing: ${data['is_phishing']}');
        return true;
      } else {
        log('❌ Failed: ${response.body}');
        return false;
      }
    } catch (e) {
      log('Error: $e');
      Fluttertoast.showToast(
        msg: "❌ Gửi tin nhắn thất bại!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return false;
    }
  }
}
