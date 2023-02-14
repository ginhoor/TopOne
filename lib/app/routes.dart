import 'package:flutter/material.dart';
import 'package:top_one/app/app_navigator_observer.dart';
import 'package:top_one/module/index/index_screen.dart';
import 'package:top_one/module/privacy/privacy_screen.dart';

class Routes {
  static const indexScreenRoute = "index_screen";
  static const privacyScreenRoute = "privacy_screen";

  static Route onGenerateRoute(RouteSettings settings) {
    if (settings.name == null) return onUnknownRoute();
    // final pathElements = settings.name?.split('/');
    Uri uri = Uri.parse(settings.name!);
    String route = uri.path;
    switch (route) {
      case indexScreenRoute:
        return AppNavigator.buildRouter(const IndexScreen());
      case privacyScreenRoute:
        return AppNavigator.buildRouter(const PrivacyScreen());
      default:
        return onUnknownRoute();
    }
  }

  static Route onUnknownRoute() {
    return MaterialPageRoute(
      builder: (_) => const Scaffold(
        body: Center(
          child: Text('404...', style: TextStyle(fontSize: 40)),
        ),
      ),
      settings: const RouteSettings(name: "/404"),
    );
  }
}
