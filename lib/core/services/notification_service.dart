import 'package:flutter/material.dart';
import 'package:merema/features/comms/presentation/widgets/message_notification.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  BuildContext? _context;
  GlobalKey<NavigatorState>? _navigatorKey;

  void initialize(BuildContext context) {
    _context = context;
  }

  void setNavigatorKey(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
  }

  BuildContext? get currentContext {
    return _navigatorKey?.currentContext ?? _context;
  }

  void showMessageNotification({
    required String senderName,
    required String messageContent,
    Duration duration = const Duration(seconds: 3),
  }) {
    final context = currentContext;
    if (context == null) return;

    MessageNotificationOverlay.show(
      context: context,
      senderName: senderName,
      messageContent: messageContent,
      duration: duration,
    );
  }

  void hideNotification() {
    MessageNotificationOverlay.hide();
  }
}
