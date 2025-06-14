import 'package:equatable/equatable.dart';

class Contact extends Equatable {
  final int partnerAccId;
  final String partnerName;
  final String lastMessageAt;
  final int conversationId;

  const Contact({
    required this.partnerAccId,
    required this.partnerName,
    required this.lastMessageAt,
    required this.conversationId,
  });

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      partnerAccId: map['partner_acc_id'] ?? 0,
      partnerName: map['partner_name'] ?? '',
      lastMessageAt: map['last_message_at'] ?? '',
      conversationId: map['conversation_id'] ?? 0,
    );
  }

  @override
  List<Object?> get props =>
      [partnerAccId, partnerName, lastMessageAt, conversationId];
}
