import 'package:flutter/material.dart';
import 'package:flutter_tool_kit/interface/page_route_handler_interface.dart';
import 'package:top_one/module/history/history_page+route.dart';

class Routes {
  static Route onGenerateRoute(RouteSettings settings) {
    List<PageRouteHandler> handlers = [
      HistoryPageRouteHandler.instance,
      // SplashPageRouteHandler.instance,
      // SettingsPageRouteHandler.instance,
      // AboutPageRouteHandler.instance,
      // RemoveObjectsPageRouteHandler.instance,
      // DebugPageRouteHandler.instance,
      // LaunchGuidePageRouteHandler.instance,
    ];

    for (var handler in handlers) {
      Route? route;
      route = handler.generateRoute(settings);
      if (route != null) return route;
    }

    return onUnknownRoute();
    // if (settings.name == null) return onUnknownRoute();
    // // final pathElements = settings.name?.split('/');
    // Uri uri = Uri.parse(settings.name!);
    // String route = uri.path;
    // switch (route) {
    //   case IndexPageRoute:
    //     return AppNavigator.buildRouter(const IndexPage());
    //   case PrivacyLaunchPageRoute:
    //     return AppNavigator.buildRouter(const PrivacyLaunchPage());
    //   default:
    //     return onUnknownRoute();
    // }
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
