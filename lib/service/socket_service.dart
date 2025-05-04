import 'dart:developer';

import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();

  factory SocketService() => _instance;

  late IO.Socket socket;

  SocketService._internal() {
    initSocket();
  }

  void initSocket() {
    socket = IO.io('http://192.168.161.167:8000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.onConnect((_) {
      log('🔌 Socket connected!');
    });

    socket.onDisconnect((_) {
      log('❌ Socket disconnected!');
    });

    socket.on('new_message', (data) {
      log('📨 Tin nhắn mới: $data');
    });
  }
}
