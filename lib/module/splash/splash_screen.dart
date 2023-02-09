import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:top_one/app/app_navigator_observer.dart';
import 'package:top_one/app/app_preferences.dart';
import 'package:top_one/app/routes.dart';
import 'package:top_one/theme/fitness_app_theme.dart';

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
    var model = PageViewModel(
      title: "Title of custom body page",
      bodyWidget: Container(),
      footer: Container(),
      image: const Center(child: Icon(Icons.android)),
    );
    return IntroductionScreen(
      pages: [model],
      showSkipButton: false,
      showNextButton: false,
      showDoneButton: false,
      skipOrBackFlex: 0,
      dotsFlex: 0,
      nextFlex: 0,
      freeze: true,
      isProgress: false,
      globalBackgroundColor: FitnessAppTheme.background,
    );
  }
}
