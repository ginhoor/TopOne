import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:top_one/app/app_navigator_observer.dart';
import 'package:top_one/app/app_preferences.dart';
import 'package:top_one/app/routes.dart';
import 'package:top_one/theme/fitness_app_theme.dart';
import 'package:top_one/tool/logger.dart';
import 'package:top_one/tool/time.dart';
import 'package:top_one/view/toast.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  @override
  Widget build(BuildContext context) {
    var model = PageViewModel(
      title: "Title of custom body page",
      bodyWidget: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Click on "),
          Icon(Icons.edit),
          Text(" to edit a post"),
          TextButton(
              onPressed: () {
                logDebug("continue onPressed");
                AppNavigatorObserver()
                    .navigator!
                    .pushReplacementNamed(Routes.indexScreenRoute);
                AppPreference().setInt(
                    AppPreferenceKey.latest_agree_privacy_date,
                    currentTimestamp());
                // AppNavigator.pushReplacement(IndexScreen());
              },
              child: Text("continue").tr()),
          TextButton(
              onPressed: () {
                showToast(context, Text("later onPressed"));
              },
              child: Text("later").tr())
        ],
      ),
      footer: Container(color: Colors.amber),
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
