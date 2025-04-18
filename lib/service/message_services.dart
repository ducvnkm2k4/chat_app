import 'package:chat_app/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageServices {
  final _db = FirebaseFirestore.instance.collection('chats');

  Future<List<Message>> getListMessage(String chatId) async {
    final snapshot = await _db
        .doc(chatId)
        .collection('message')
        .orderBy('createAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Message.fromMap(data);
    }).toList();
  }

  Future<void> sendMessage(
      String chatId, Message message, String sender) async {
    await _db.doc(chatId).collection('message').add(message.toMap(sender));
  }

  Stream<List<Map<String, dynamic>>?> streamMessages(String chatId) {
    return _db
        .doc(chatId)
        .collection('message')
        .orderBy('createAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}
