class MarkSeenMessageParams {
  final int partnerAccId;
  final String readTime;
  final int conversationId;

  MarkSeenMessageParams({
    required this.partnerAccId,
    required this.readTime,
    required this.conversationId,
  });
}
