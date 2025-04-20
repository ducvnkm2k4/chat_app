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
    socket = IO.io(
        'https://chat-app-backend1234-78677c67120d.herokuapp.com',
        <String, dynamic>{
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
