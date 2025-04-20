class Message {
  String sender;
  DateTime createAt;
  String message;
  bool state;
  Message({
    required this.state,
    required this.sender,
    required this.createAt,
    required this.message,
  });

  Map<String, dynamic> toMap(String sender) {
    return {
      'sender': sender,
      'createAt': createAt.toIso8601String(),
      'message': message,
      'state': state
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      state: map['state'],
      sender: map['sender'],
      createAt: map['createAt'].toDate(),
      message: map['message'] ?? '',
    );
  }

  @override
  String toString() {
    return 'Message(createAt: $createAt, message: $message,sender:$sender)';
  }
}
