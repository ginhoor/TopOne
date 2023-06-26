import 'package:flutter/src/widgets/navigator.dart';
import 'package:flutter_tool_kit/error/axv_error.dart';
import 'package:flutter_tool_kit/interface/page_route_handler_interface.dart';
import 'package:top_one/app/app_navigator_observer.dart';
import 'package:top_one/module/privacy/privacy_launch_page.dart';

class PrivacyLaunchPageRouteHandler implements PageRouteHandler {
  static final PrivacyLaunchPageRouteHandler instance = PrivacyLaunchPageRouteHandler._instance();
  factory PrivacyLaunchPageRouteHandler() => instance;
  PrivacyLaunchPageRouteHandler._instance();

  @override
  String routeName = "privacy_launch";
  Route page() {
    var settings = RouteSettings(name: routeName);
    var route = generateRoute(settings, animated: false);
    if (route == null) throw AXVError.paramsInvalid;
    return route;
  }

  @override
  Route? generateRoute(RouteSettings settings, {bool animated = true}) {
    if (settings.name == null || settings.name != routeName) return null;
    return AppNavigator.buildRouter(settings, const PrivacyLaunchPage(), animated: animated);
  }
}
