import 'package:flutter/src/widgets/navigator.dart';
import 'package:flutter_tool_kit/error/axv_error.dart';
import 'package:flutter_tool_kit/interface/page_route_handler_interface.dart';
import 'package:top_one/app/app_navigator_observer.dart';
import 'package:top_one/model/tt_result.dart';
import 'package:top_one/module/video/video_preview_page.dart';

class VideoPreviewPageRouteHandler implements PageRouteHandler {
  static final VideoPreviewPageRouteHandler instance = VideoPreviewPageRouteHandler._instance();
  factory VideoPreviewPageRouteHandler() => instance;
  VideoPreviewPageRouteHandler._instance();

  @override
  String routeName = "video";

  Route page(TTResult metaData, String? localFilePath) {
    var settings = RouteSettings(name: routeName, arguments: {"localFilePath": localFilePath, "metaData": metaData});
    var route = generateRoute(settings);
    if (route == null) throw AXVError.paramsInvalid;
    return route;
  }

  @override
  Route? generateRoute(RouteSettings settings) {
    if (settings.name == null || settings.name != routeName) return null;

    var params = settings.arguments as Map<String, dynamic>?;
    var metaData = params?["metaData"] as TTResult?;
    var localFilePath = params?["localFilePath"] as String?;

    if (metaData != null && localFilePath != null) {
      return AppNavigator.buildRouter(settings, VideoPreviewPage(metaData: metaData, localFilePath: localFilePath));
    }
    return null;
  }
}
