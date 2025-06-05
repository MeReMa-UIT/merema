class Message {
  final String content;
  final int senderId;
  final String sentAt;

  const Message({
    required this.content,
    required this.senderId,
    required this.sentAt,
  });
}

class Messages {
  final List<Message> messages;

  const Messages({
    required this.messages,
  });
}
