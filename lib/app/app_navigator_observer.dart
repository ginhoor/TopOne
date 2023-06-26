import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_tool_kit/log/logger.dart';

class AppNavigator {
  static final AppNavigator instance = AppNavigator._instance();
  factory AppNavigator() => instance;
  AppNavigator._instance();

  static NavigatorState get navigator {
    return AppNavigatorObserver().navigator!;
  }

  static PageRouteBuilder buildRouter(RouteSettings settings, Widget page) {
    return PageRouteBuilder(
      pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
        final begin = Offset(1.0, 0.0);
        final end = Offset.zero;
        final curve = Curves.ease;

        final tween = Tween(begin: begin, end: end);
        final curvedAnimation = CurvedAnimation(parent: animation, curve: curve);

        return SlideTransition(
          position: tween.animate(curvedAnimation),
          child: page,
        );
        //  return FadeTransition(opacity: animation, child: page);
      },
      settings: settings,
    );
  }

  static Future<bool> handleOnWillPop() async {
    if (EasyLoading.isShow) return false;
    if (Platform.isAndroid) {
      popPage();
      // SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      return true;
    }
    exit(0);
  }

  static void popPage() {
    navigator.pop();
  }

  static Future<void> pushPage(RouteSettings settings, Widget page) async {
    await pushRoute(buildRouter(settings, page));
  }

  static Future<T?> pushRoute<T extends Object?>(Route<T> route) async {
    return navigator.push(route);
  }

  static Future<void> pushByNamed(BuildContext context, String routePath, {Object? arguments}) async {
    await Navigator.pushNamed(context, routePath, arguments: arguments);
  }

  static Future<dynamic> pushReplacementNamed(String routeName) async {
    return await navigator.pushReplacementNamed(routeName);
  }

  static Future<dynamic> pushReplacement(RouteSettings settings, Widget page) async {
    return await navigator.pushReplacement(buildRouter(settings, page));
  }

  static Future<T?> pushReplacementRoute<T extends Object?>(Route<T> route) async {
    return await navigator.pushReplacement(route);
  }
}

class AppNavigatorObserver extends NavigatorObserver {
  AppNavigatorObserver._internal();
  static final AppNavigatorObserver _instance = AppNavigatorObserver._internal();
  factory AppNavigatorObserver() => _instance;

  @override
  void didPush(Route route, Route<dynamic>? previousRoute) {
    logDebug('[nav] didPush route.settings : ${route.settings}');
    super.didPush(route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    logDebug('[nav] didReplace newRoute.settings: ${newRoute?.settings}, oldRoute.settings: ${oldRoute?.settings}');
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void didPop(Route route, Route<dynamic>? previousRoute) {
    logDebug('[nav] didPop route.settings : ${route.settings}');
    super.didPop(route, previousRoute);
  }
}
