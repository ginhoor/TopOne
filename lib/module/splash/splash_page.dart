import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tool_kit/config/app_preference.dart';
import 'package:top_one/app/app_navigator_observer.dart';
import 'package:top_one/app/app_preference.dart';
import 'package:top_one/module/index/index_page+route.dart';
import 'package:top_one/module/privacy/privacy_launch_page+route.dart';
import 'package:top_one/theme/app_theme.dart';
import 'package:top_one/view/app_title_logo.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Duration splashWaitDuration = const Duration(seconds: 2);
  late String nextScreenRoute;

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(splashWaitDuration).then((value) {
      if (AppPreference.instance.getInt(AppPreferenceKey.latestAgreePrivacyDate.value) == null) {
        var page = PrivacyLaunchPageRouteHandler.instance.page();
        AppNavigator.pushReplacementRoute(page);
      } else {
        var page = IndexPageRouteHandler.instance.page();
        AppNavigator.pushReplacementRoute(page);
      }
    });
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(30.0)),
                child: Image(
                  image: ResizeImage(ExactAssetImage('assets/icon/ttd_icon.png'),
                      width: 150, height: 150, allowUpscaling: true),
                ),
              ),
              SizedBox(height: 40),
              Padding(padding: EdgeInsets.only(left: 16), child: AppTitleLogo())
            ],
          ),
        ),
      ),
    );
  }
}
