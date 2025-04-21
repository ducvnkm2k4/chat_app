import 'dart:developer';

import 'package:chat_app/screens/login_screen.dart';
import 'package:chat_app/service/message_provider.dart';
import 'package:chat_app/service/message_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({super.key});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  String? userId;
  String? _username;
  late IO.Socket socket;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  @override
  void initState() {
    super.initState();
    _initSocket();
  }

  void _initSocket() {
    socket = IO.io('http://192.168.161.167:8000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.onConnect((_) {
      log('🔌 Socket connected!');
    });

    socket.on('new_message', (data) {
      log('📥 New message from socket: $data');
      Provider.of<MessageProvider>(context, listen: false).addMessage(data);
    });
  }

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('uId');
    log('userId: $userId');

    final data = await MessageServices().getMessages();
    log(data.toString());
    Provider.of<MessageProvider>(context, listen: false)
        .setMessages(data.reversed.toList());
  }

  void _onclickSendMessage() async {
    String message = _messageController.text.trim();

    // Xoá nội dung input
    _messageController.clear();
    // Thêm vào danh sách UI
    log('list: ${Provider.of<MessageProvider>(context, listen: false).messages}');

    // Gửi tin nhắn đến backend
    bool success = await MessageServices().sendMessage(message, userId!);

    if (!success) {
      Fluttertoast.showToast(
        msg: "❌ Gửi tin nhắn thất bại. Vui lòng thử lại!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: const Center(
          child: Padding(
            padding: EdgeInsets.only(left: 30.0),
            child: Text('Chat Group'),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // FutureBuilder để tải dữ liệu ban đầu
          Expanded(
            child: Consumer<MessageProvider>(
              builder: (context, messageProvider, child) {
                final messages = messageProvider.messages;
                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe =
                        message['user_id'].toString() == userId.toString();
                    final senderName = message['username'] ?? 'Không rõ';
                    final isPhishing = message['is_phishing'] == true;
                    if (isMe && _username == null) {
                      _username = message['username'];
                    }

                    return Align(
                      alignment:
                          isMe ? Alignment.bottomRight : Alignment.bottomLeft,
                      child: Column(
                        crossAxisAlignment: isMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Text(
                              senderName,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                            decoration: BoxDecoration(
                              color: isMe ? Colors.indigo : Colors.grey[300],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Linkify(
                              onOpen: (link) async {
                                final url = Uri.parse(link.url);
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url,
                                      mode: LaunchMode.externalApplication);
                                } else {
                                  throw 'Không mở được liên kết: ${link.url}';
                                }
                              },
                              text: message['content'],
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black,
                              ),
                              linkStyle: const TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          if (isPhishing)
                            Container(
                              margin: const EdgeInsets.only(
                                  left: 12, right: 12, bottom: 8),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '⚠️ Người dùng $senderName đã gửi một URL nghi ngờ lừa đảo!',
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Input Message
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Nhập tin nhắn...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(24)),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    maxLines: null,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: Colors.blue,
                  onPressed: _onclickSendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    socket.dispose(); // Hủy kết nối WebSocket khi dispose
    super.dispose();
  }
}
