import 'package:flutter/foundation.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/features/comms/domain/usecases/open_ws_connection.dart';
import 'package:merema/features/comms/domain/usecases/close_ws_connection.dart';
import 'package:merema/features/comms/domain/repositories/comms_repository.dart';
import 'package:merema/core/layers/domain/entities/user_role.dart';

class CommsNotifier extends ChangeNotifier {
  bool _isConnected = false;
  List<Map<String, dynamic>> _newMessages = [];

  bool get isConnected => _isConnected;
  List<Map<String, dynamic>> get newMessages => _newMessages;

  Future<void> openConnectionForRole(UserRole role) async {
    if (role == UserRole.doctor || role == UserRole.patient) {
      try {
        await sl<OpenWsConnectionUseCase>().call(null);
        _isConnected = true;
        _setupMessageListener();
        notifyListeners();
      } catch (e) {
        debugPrint('Failed to open WebSocket connection: $e');
      }
    }
  }

  void _setupMessageListener() {
    sl<CommsRepository>().onMessageHistory.listen((event) {
      if (event.containsKey('messages')) {
        final messages = event['messages'];
        if (messages is List) {
          _newMessages = List<Map<String, dynamic>>.from(messages);
          notifyListeners();
        }
      }
    });
  }

  Future<void> closeConnection() async {
    try {
      await sl<CloseWsConnectionUseCase>().call(null);
      _isConnected = false;
      _newMessages.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to close WebSocket connection: $e');
    }
  }

  void clearNewMessages() {
    _newMessages.clear();
    notifyListeners();
  }
}
