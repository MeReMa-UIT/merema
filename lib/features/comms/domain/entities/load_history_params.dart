class LoadHistoryParams {
  final int conversationId;
  final int? limit;
  final int? offset;

  LoadHistoryParams({
    required this.conversationId,
    this.limit,
    this.offset,
  });
}
