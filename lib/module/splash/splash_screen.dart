import 'package:flutter/material.dart';
import 'package:top_one/app/app_navigator_observer.dart';
import 'package:top_one/app/app_preferences.dart';
import 'package:top_one/app/routes.dart';
import 'package:top_one/view/app_title_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Duration splashWaitDuration = const Duration(seconds: 2);
  late String nextScreenRoute;
  @override
  void initState() {
    super.initState();
    if (AppPreference().getInt(AppPreferenceKey.latest_agree_privacy_date) ==
        null) {
      nextScreenRoute = Routes.privacyScreenRoute;
    } else {
      nextScreenRoute = Routes.indexScreenRoute;
    }
    Future.delayed(splashWaitDuration)
        .then((value) => {AppNavigator.pushReplacementNamed(nextScreenRoute)});
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(30.0)),
            child: Image(
              image: ResizeImage(
                ExactAssetImage('assets/icon/ttd_icon.png'),
                width: 150,
                height: 150,
                allowUpscaling: true,
              ),
            ),
          ),
          SizedBox(height: 40),
          Padding(
            padding: EdgeInsets.only(left: 16),
            child: AppTitleLogo(),
          )
        ],
      ),
    );
  }
}
