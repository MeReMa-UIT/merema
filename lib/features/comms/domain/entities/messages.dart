class Message {
  final String content;
  final int conversationId;
  final bool isSeen;
  final int messageId;
  final int senderAccId;
  final String sentAt;

  Message({
    required this.content,
    required this.conversationId,
    required this.isSeen,
    required this.messageId,
    required this.senderAccId,
    required this.sentAt,
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      content: map['content'] ?? '',
      conversationId: map['conversation_id'] ?? 0,
      isSeen: map['is_seen'] ?? false,
      messageId: map['message_id'] ?? 0,
      senderAccId: map['sender_acc_id'] ?? 0,
      sentAt: map['sent_at'] ?? '',
    );
  }
}
