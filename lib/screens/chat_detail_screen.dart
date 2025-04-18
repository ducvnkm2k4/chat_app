import 'dart:developer';

import 'package:chat_app/models/message.dart';
import 'package:chat_app/screens/login_screen.dart';
import 'package:chat_app/service/message_services.dart';
import 'package:chat_app/service/url_predictor.dart';
import 'package:chat_app/service/user_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({super.key});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  String? userId;
  final Map<String, String> _userNameCache = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  Future<String> _getUserName(String uid) async {
    if (_userNameCache.containsKey(uid)) {
      return _userNameCache[uid]!;
    }
    final user = await UserServices.findUserByID(uid);
    final name = user?.userName ?? 'Không rõ';
    _userNameCache[uid] = name;
    return name;
  }

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('uId');
    setState(() {});
  }

  List<String> extractUrls(String text) {
    final regex = RegExp(
      r'((https?:\/\/)?([\w\-]+\.)+[a-zA-Z]{2,}(/[^\s]*)?)',
      caseSensitive: false,
    );
    return regex.allMatches(text).map((match) {
      final url = match.group(0)!;
      return url.startsWith('http') ? url : 'http://$url';
    }).toList();
  }

  void _onclickSendMessage() async {
    String message = _messageController.text.trim();
    if (message.isEmpty || userId == null) return;

    final urls = extractUrls(message);
    log('list url: $urls');
    bool isDangerous = false;

    for (final url in urls) {
      final score = await NativeUrlDetector.predictUrl(url);
      log('URL: $url — Score: $score');
      // Nếu score < 0.5 thì class 0 (nguy hiểm), còn >= 0.5 thì class 1 (an toàn)
      if (score! < 0.5) {
        isDangerous = true;
        break;
      }
    }

    final msg = Message(
      sender: userId!,
      createAt: DateTime.now(),
      message: message,
      state: isDangerous,
    );

    await MessageServices().sendMessage('BnMICz2yob3nnOlQ4fCt', msg, userId!);
    _messageController.clear();
    _loadData();
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
            child: Text('chat group'),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await UserServices.logOutUser();
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
          _buildList(),
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

  Widget _buildList() {
    return Expanded(
      child: StreamBuilder<List<Map<String, dynamic>>?>(
        stream: MessageServices().streamMessages('BnMICz2yob3nnOlQ4fCt'),
        builder: (context, snapshot) {
          log('message: ${snapshot.data?.length}');
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Chưa có tin nhắn nào'));
          }

          final messages = snapshot.data!;

          return ListView.builder(
            controller: _scrollController,
            reverse: true,
            padding: const EdgeInsets.all(8),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              final isMe = message['sender'] == userId;

              return Align(
                alignment: isMe ? Alignment.bottomRight : Alignment.bottomLeft,
                child: Column(
                  crossAxisAlignment:
                      isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: FutureBuilder(
                        future: _getUserName(message['sender']),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Text("Đang tải...",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey));
                          }
                          if (snapshot.hasError) {
                            return const Text("Lỗi tải tên",
                                style:
                                    TextStyle(fontSize: 12, color: Colors.red));
                          }
                          return Text(
                            snapshot.data ?? "Không rõ",
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          );
                        },
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
                        text: message['message'],
                        style: TextStyle(
                          color: isMe ? Colors.white : Colors.black,
                        ),
                        linkStyle: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
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
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
