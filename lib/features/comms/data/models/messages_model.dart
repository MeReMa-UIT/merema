import 'package:merema/features/comms/domain/entities/messages.dart';

class MessageModel extends Message {
  const MessageModel({
    required super.content,
    required super.senderId,
    required super.sentAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      content: json['content'],
      senderId: json['sender_id'],
      sentAt: json['sent_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'sender_id': senderId,
      'sent_at': sentAt,
    };
  }
}

class MessagesModel extends Messages {
  const MessagesModel({
    required super.messages,
  });

  factory MessagesModel.fromJson(List<dynamic> json) {
    final messagesList =
        json.map((messageJson) => MessageModel.fromJson(messageJson)).toList();

    return MessagesModel(
      messages: messagesList,
    );
  }

  List<Map<String, dynamic>> toJson() {
    return messages
        .map((message) => (message as MessageModel).toJson())
        .toList();
  }
}
