import 'package:flutter/material.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<dynamic>? navigateTo(String routeName, {Object? arguments}) {
    return navigatorKey.currentState
        ?.pushNamed(routeName, arguments: arguments);
  }

  Future<dynamic>? pushAndRemoveUntil(Route newRoute, {Object? arguments}) {
    return navigatorKey.currentState
        ?.pushAndRemoveUntil(newRoute, (route) => false);
  }

  void goBack() {
    return navigatorKey.currentState?.pop();
  }
}
