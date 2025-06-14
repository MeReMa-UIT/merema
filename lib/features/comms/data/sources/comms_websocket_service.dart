import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/io.dart';
import 'package:merema/core/consts/consts.dart';

class CommsWebSocketService {
  IOWebSocketChannel? _channel;
  late StreamController<Map<String, dynamic>> _controller;

  CommsWebSocketService() {
    _controller = StreamController<Map<String, dynamic>>.broadcast();
  }

  Future<void> openConnection(String token) async {
    _channel = IOWebSocketChannel.connect(
      Uri.parse(Consts.wsUrl),
      headers: {
        'Authorization': token,
      },
    );
    _channel!.stream.listen((data) {
      final decoded = json.decode(data);
      _controller.add(decoded);
    });
  }

  Stream<Map<String, dynamic>> get stream => _controller.stream;

  void sendMessage({
    required int partnerAccId,
    required String text,
    required int conversationId,
  }) {
    final payload = {
      'type': 'sendMessage',
      'partner_acc_id': partnerAccId,
      'text': text,
      'conversation_id': conversationId,
    };
    _channel?.sink.add(json.encode(payload));
  }

  void loadHistory({
    required int conversationId,
    int? limit,
    int? offset,
  }) {
    final payload = {
      'type': 'loadHistory',
      'conversation_id': conversationId,
      if (limit != null) 'limit': limit,
      if (offset != null) 'offset': offset,
    };
    _channel?.sink.add(json.encode(payload));
  }

  void markSeenMessage({
    required int partnerAccId,
    required String readTime,
    required int conversationId,
  }) {
    final payload = {
      'type': 'markSeenMessage',
      'partner_acc_id': partnerAccId,
      'read_time': readTime,
      'conversation_id': conversationId,
    };
    _channel?.sink.add(json.encode(payload));
  }

  void dispose() {
    _channel?.sink.close();
    _controller.close();
  }
}
