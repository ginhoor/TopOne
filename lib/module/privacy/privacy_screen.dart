import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gh_tool_package/config/app_preference.dart';
import 'package:gh_tool_package/extension/time.dart';
import 'package:gh_tool_package/system/web.dart';
import 'package:top_one/app/app_navigator_observer.dart';
import 'package:top_one/app/app_preference.dart';
import 'package:top_one/app/routes.dart';
import 'package:top_one/service/app_info_service.dart';
import 'package:top_one/theme/app_theme.dart';
import 'package:top_one/view/toast.dart';
import 'package:top_one/view/utils.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  @override
  Widget build(BuildContext context) {
    var subtitleStyle = const TextStyle(
        color: AppTheme.nearlyBlack, fontSize: 15, fontWeight: FontWeight.w300);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          Positioned(
            width: MediaQuery.of(context).size.width,
            top: MediaQuery.of(context).padding.top + 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Videos Downloader for TickTok
                Text(
                  "Welcome to",
                  style: TextStyle(
                      color: AppTheme.nearlyBlack,
                      fontSize: 30,
                      fontWeight: FontWeight.w300),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      // Videos Downloader for TickTok
                      Text(
                        "Videos Downloader for TickTok",
                        style: TextStyle(
                            color: AppTheme.nearlyBlack,
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            height: 1.5),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 40 + 10 + 100,
            height: 80,
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.only(left: 40, right: 40),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: RichText(
                  textAlign: TextAlign.start,
                  maxLines: 5,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        style: subtitleStyle,
                        text: "privacy_subtile_1".tr(),
                      ),
                      TextSpan(
                        style:
                            subtitleStyle.copyWith(color: AppTheme.actionGreen),
                        text: " " + "terms_of_use".tr() + " ",
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => launchInBrowser(kTermsOfServiceURL),
                      ),
                      TextSpan(
                        style: subtitleStyle,
                        text: "privacy_subtile_2".tr(),
                      ),
                      TextSpan(
                        style:
                            subtitleStyle.copyWith(color: AppTheme.actionGreen),
                        text: " " + "privacy_policy".tr(),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => launchInBrowser(kPrivacyPolicyURL),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 40,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 100,
              child: Padding(
                padding: const EdgeInsets.only(left: 40, right: 40),
                child: Column(
                  children: [
                    SizedBox(
                      height: 60,
                      child: generateActionButton("continue",
                          AppTheme.actionGreen, AppTheme.nearlyWhite, () async {
                        AppNavigator.pushReplacementNamed(
                            Routes.indexScreenRoute);
                        AppPreference().setInt(
                            AppPreferenceKey.latest_agree_privacy_date,
                            currentTimestamp());
                      }),
                    ),
                    SizedBox(
                      height: 40,
                      child: generateActionButton(
                          "later", Colors.transparent, AppTheme.nearlyBlack,
                          () async {
                        showToast(context, Text("privacy_skip_tips").tr());
                      }),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
    // return IntroductionScreen(
    //   pages: [model],
    //   showSkipButton: false,
    //   showNextButton: false,
    //   showDoneButton: false,
    //   skipOrBackFlex: 0,
    //   dotsFlex: 0,
    //   nextFlex: 0,
    //   freeze: true,
    //   isProgress: false,
    //   globalBackgroundColor: AppTheme.background,
    // );
  }
}
