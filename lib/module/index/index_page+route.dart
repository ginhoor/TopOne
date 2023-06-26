import 'package:flutter/src/widgets/navigator.dart';
import 'package:flutter_tool_kit/error/axv_error.dart';
import 'package:flutter_tool_kit/interface/page_route_handler_interface.dart';
import 'package:top_one/app/app_navigator_observer.dart';
import 'package:top_one/module/index/index_page.dart';

class IndexPageRouteHandler implements PageRouteHandler {
  static final IndexPageRouteHandler instance = IndexPageRouteHandler._instance();
  factory IndexPageRouteHandler() => instance;
  IndexPageRouteHandler._instance();

  @override
  String routeName = "index";
  Route page() {
    var settings = RouteSettings(name: routeName);
    var route = generateRoute(settings, animated: false);
    if (route == null) throw AXVError.paramsInvalid;
    return route;
  }

  @override
  Route? generateRoute(RouteSettings settings, {bool animated = true}) {
    if (settings.name == null || settings.name != routeName) return null;
    return AppNavigator.buildRouter(settings, const IndexPage(), animated: animated);
  }
}
