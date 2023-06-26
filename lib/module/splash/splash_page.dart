import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tool_kit/config/app_preference.dart';
import 'package:top_one/app/app_navigator_observer.dart';
import 'package:top_one/app/app_preference.dart';
import 'package:top_one/gen/assets.gen.dart';
import 'package:top_one/gen/colors.gen.dart';
import 'package:top_one/module/index/index_page+route.dart';
import 'package:top_one/module/privacy/privacy_launch_page+route.dart';
import 'package:top_one/theme/app_theme.dart';
import 'package:top_one/theme/theme_config.dart';

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
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + dPadding * 4),
            child: Column(
              children: [
                _appLogo,
                SizedBox(height: 50),
                _textLogo,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget get _appLogo {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(30.0)),
      child: Image(
        image: Assets.image.appLogo.provider(),
        width: 150,
        height: 150,
      ),
    );
  }

  Widget get _textLogo {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Video Downloader",
          style: TextStyle(color: ColorName.blackText, fontSize: 20, fontWeight: FontWeight.w400, height: 1.5),
        ),
        Text(
          "For",
          style: TextStyle(color: ColorName.blackText, fontSize: 20, fontWeight: FontWeight.w400, height: 1.5),
        ),
        Text(
          "TikTok",
          style: TextStyle(color: ColorName.blackText, fontSize: 30, fontWeight: FontWeight.w600, height: 1.5),
        )
      ],
    );
  }
}
