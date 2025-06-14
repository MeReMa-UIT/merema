import 'package:flutter/material.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<dynamic>? pushAndRemoveUntil(Route newRoute, {Object? arguments}) {
    return navigatorKey.currentState
        ?.pushAndRemoveUntil(newRoute, (route) => false);
  }
}
