class SendMessageParams {
  final int partnerAccId;
  final String text;
  final int conversationId;

  SendMessageParams({
    required this.partnerAccId,
    required this.text,
    required this.conversationId,
  });
}
