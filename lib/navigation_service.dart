import 'package:flutter/material.dart';

class NavigationService {
  // Global navigation key for whole application
  GlobalKey<NavigatorState> navigationKey = GlobalKey<NavigatorState>();

  /// Get app context
  BuildContext? get appContext => navigationKey.currentContext;

  /// App route observer
  RouteObserver<Route<dynamic>> routeObserver = RouteObserver<Route<dynamic>>();

  static final NavigationService _instance = NavigationService._private();
  factory NavigationService() {
    return _instance;
  }
  NavigationService._private();

  static NavigationService get instance => _instance;
}
