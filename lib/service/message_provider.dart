// lib/provider/message_provider.dart
import 'package:flutter/material.dart';

class MessageProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _messages = [];

  List<Map<String, dynamic>> get messages => _messages;

  // Set messages khi load lần đầu
  Future<void> setMessages(List<Map<String, dynamic>> newMessages) async {
    _messages = newMessages; // Gán danh sách tin nhắn mới
    notifyListeners();
  }

  // Add message mới từ WebSocket
  void addMessage(Map<String, dynamic> newMessage) {
    _messages.insert(0, newMessage); // Thêm tin nhắn mới vào đầu danh sách
    notifyListeners();
  }
}
