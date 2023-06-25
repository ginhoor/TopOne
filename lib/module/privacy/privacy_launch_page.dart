import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tool_kit/config/app_preference.dart';
import 'package:gh_tool_package/extension/time.dart';
import 'package:gh_tool_package/system/web.dart';
import 'package:top_one/app/app_module/app_info_module.dart';
import 'package:top_one/app/app_navigator_observer.dart';
import 'package:top_one/app/app_preference.dart';
import 'package:top_one/generated/locale_keys.g.dart';
import 'package:top_one/module/index/index_page+route.dart';
import 'package:top_one/theme/app_theme.dart';
import 'package:top_one/theme/theme_config.dart';
import 'package:top_one/view/toast.dart';
import 'package:top_one/view/utils.dart';

class PrivacyLaunchPage extends StatefulWidget {
  const PrivacyLaunchPage({super.key});

  @override
  State<PrivacyLaunchPage> createState() => _PrivacyLaunchPageState();
}

class _PrivacyLaunchPageState extends State<PrivacyLaunchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: _content,
      ),
    );
  }

  Widget get _content {
    var subtitleStyle = const TextStyle(color: AppTheme.nearlyBlack, fontSize: 15, fontWeight: FontWeight.w300);

    return Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: Padding(
            padding: EdgeInsets.only(top: dPadding * 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "welcome_to".tr(),
                  style: const TextStyle(color: AppTheme.nearlyBlack, fontSize: 30, fontWeight: FontWeight.w300),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Video Downloader for TikTok",
                        style: TextStyle(color: AppTheme.nearlyBlack, fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(left: 24, right: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min, // 设置 Column 的高度为子项内容的高度
              children: [
                RichText(
                  textAlign: TextAlign.start,
                  text: TextSpan(
                    children: [
                      TextSpan(style: subtitleStyle, text: LocaleKeys.privacy_subtile_1.tr()),
                      TextSpan(
                        style: subtitleStyle.copyWith(color: AppTheme.actionGreen),
                        text: " ${LocaleKeys.terms_of_use.tr()} ",
                        recognizer: TapGestureRecognizer()..onTap = () => launchInBrowser(kTermsOfServiceURL),
                      ),
                      TextSpan(
                        style: subtitleStyle,
                        text: LocaleKeys.privacy_subtile_2.tr(),
                      ),
                      TextSpan(
                        style: subtitleStyle.copyWith(color: AppTheme.actionGreen),
                        text: " ${LocaleKeys.privacy_policy.tr()}",
                        recognizer: TapGestureRecognizer()..onTap = () => launchInBrowser(kPrivacyPolicyURL),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: dPadding),
                SizedBox(
                  height: dBtnSize,
                  child: generateActionButton("continue", AppTheme.actionGreen, AppTheme.nearlyWhite, () async {
                    var page = IndexPageRouteHandler.instance.page();
                    AppNavigator.pushReplacementRoute(page);
                    AppPreference.instance.setInt(AppPreferenceKey.latestAgreePrivacyDate.value, currentTimestamp);
                  }),
                ),
                SizedBox(
                  height: dBtnSize * 1.5,
                  child: generateActionButton("later", Colors.transparent, AppTheme.nearlyBlack, () async {
                    showToast(context, const Text("privacy_skip_tips").tr());
                  }),
                ),
                SizedBox(height: dPadding * 2),
              ],
            ),
          ),
        ),
        // Positioned(
        //   bottom: MediaQuery.of(context).padding.bottom + 40 + 10 + 100,
        //   height: 100,
        //   width: MediaQuery.of(context).size.width,
        //   child: Padding(
        //     padding: const EdgeInsets.only(left: 40, right: 40),
        //     child: Align(
        //       alignment: Alignment.bottomLeft,
        //       child: RichText(
        //         textAlign: TextAlign.start,
        //         maxLines: 5,
        //         text: TextSpan(
        //           children: [
        //             TextSpan(
        //               style: subtitleStyle,
        //               text: "privacy_subtile_1".tr(),
        //             ),
        //             TextSpan(
        //               style: subtitleStyle.copyWith(color: AppTheme.actionGreen),
        //               text: " ${"terms_of_use".tr()} ",
        //               recognizer: TapGestureRecognizer()..onTap = () => launchInBrowser(kTermsOfServiceURL),
        //             ),
        //             TextSpan(
        //               style: subtitleStyle,
        //               text: "privacy_subtile_2".tr(),
        //             ),
        //             TextSpan(
        //               style: subtitleStyle.copyWith(color: AppTheme.actionGreen),
        //               text: " ${"privacy_policy".tr()}",
        //               recognizer: TapGestureRecognizer()..onTap = () => launchInBrowser(kPrivacyPolicyURL),
        //             ),
        //           ],
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
