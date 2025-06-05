import 'dart:async';
import 'package:flutter/material.dart';
import 'package:merema/core/theme/app_pallete.dart';

class DesktopNotificationOverlay extends StatefulWidget {
  final String title;
  final String message;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const DesktopNotificationOverlay({
    super.key,
    required this.title,
    required this.message,
    this.onTap,
    this.onDismiss,
  });

  @override
  State<DesktopNotificationOverlay> createState() =>
      _DesktopNotificationOverlayState();
}

class _DesktopNotificationOverlayState extends State<DesktopNotificationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      if (widget.onDismiss != null) {
        widget.onDismiss!();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 20,
      right: 20,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(8),
            child: GestureDetector(
              onTap: () {
                if (widget.onTap != null) {
                  widget.onTap!();
                }
                _dismiss();
              },
              child: Container(
                width: 300,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppPallete.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppPallete.lightGrayColor),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.message,
                      color: AppPallete.primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppPallete.textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.message,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppPallete.darkGrayColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _dismiss,
                      icon: const Icon(
                        Icons.close,
                        size: 16,
                        color: AppPallete.darkGrayColor,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DesktopNotificationManager {
  static final List<OverlayEntry> _activeNotifications = [];

  static void showNotification(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onTap,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => DesktopNotificationOverlay(
        title: title,
        message: message,
        onTap: onTap,
        onDismiss: () {
          entry.remove();
          _activeNotifications.remove(entry);
        },
      ),
    );

    _activeNotifications.add(entry);
    overlay.insert(entry);

    if (_activeNotifications.length > 3) {
      final oldest = _activeNotifications.removeAt(0);
      oldest.remove();
    }
  }

  static void clearAll() {
    for (final entry in _activeNotifications) {
      entry.remove();
    }
    _activeNotifications.clear();
  }
}
