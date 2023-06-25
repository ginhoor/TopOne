import 'package:flutter/src/widgets/navigator.dart';
import 'package:flutter_tool_kit/error/axv_error.dart';
import 'package:flutter_tool_kit/interface/page_route_handler_interface.dart';
import 'package:top_one/app/app_navigator_observer.dart';
import 'package:top_one/module/debug/debug_page.dart';

class DebugPageRouteHandler implements PageRouteHandler {
  static final DebugPageRouteHandler instance = DebugPageRouteHandler._instance();
  factory DebugPageRouteHandler() => instance;
  DebugPageRouteHandler._instance();

  @override
  String routeName = "debug";

  Route page() {
    var settings = RouteSettings(name: routeName);
    var route = generateRoute(settings);
    if (route == null) throw AXVError.paramsInvalid;
    return route;
  }

  @override
  Route? generateRoute(RouteSettings settings) {
    if (settings.name == null || settings.name != routeName) return null;
    return AppNavigator.buildRouter(settings, DebugPage());
  }
}
