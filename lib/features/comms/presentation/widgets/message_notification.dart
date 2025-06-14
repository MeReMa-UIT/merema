import 'package:flutter/material.dart';
import 'package:merema/core/theme/app_pallete.dart';
import 'dart:async';

class MessageNotification extends StatelessWidget {
  final String senderName;
  final String messageContent;
  final VoidCallback? onDismiss;

  const MessageNotification({
    super.key,
    required this.senderName,
    required this.messageContent,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppPallete.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppPallete.primaryColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppPallete.darkGrayColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.message,
                color: AppPallete.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      senderName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: AppPallete.textColor,
                      ),
                    ),
                    Text(
                      messageContent,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppPallete.lightGrayColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (onDismiss != null)
                GestureDetector(
                  onTap: onDismiss,
                  child: const Icon(
                    Icons.close,
                    color: AppPallete.lightGrayColor,
                    size: 16,
                  ),
                ),
            ],
          ),
        ));
  }
}

class MessageNotificationOverlay {
  static OverlayEntry? _overlayEntry;
  static Timer? _timer;

  static void show({
    required BuildContext context,
    required String senderName,
    required String messageContent,
    Duration duration = const Duration(seconds: 4),
  }) {
    hide();

    _overlayEntry = OverlayEntry(
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final maxWidth = screenWidth * 0.9 > 300 ? 300.0 : screenWidth * 0.9;
        return Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          right: 16,
          child: SizedBox(
            width: maxWidth,
            child: MessageNotification(
              senderName: senderName,
              messageContent: messageContent,
              onDismiss: hide,
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);

    _timer = Timer(duration, hide);
  }

  static void hide() {
    _timer?.cancel();
    _timer = null;
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  static void stop() {
    hide();
  }
}
