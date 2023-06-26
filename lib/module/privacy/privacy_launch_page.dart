import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tool_kit/config/app_preference.dart';
import 'package:gh_tool_package/extension/time.dart';
import 'package:top_one/app/app_module/app_info_module.dart';
import 'package:top_one/app/app_navigator_observer.dart';
import 'package:top_one/app/app_preference.dart';
import 'package:top_one/gen/assets.gen.dart';
import 'package:top_one/gen/colors.gen.dart';
import 'package:top_one/gen/locale_keys.gen.dart';
import 'package:top_one/manager/system_component_manager.dart';
import 'package:top_one/module/index/index_page+route.dart';
import 'package:top_one/theme/app_theme.dart';
import 'package:top_one/theme/button.dart';
import 'package:top_one/theme/theme_config.dart';
import 'package:top_one/view/toast.dart';

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

  var subtitleStyle = const TextStyle(color: ColorName.blackText, fontSize: 15, fontWeight: FontWeight.w300);
  Widget get _content {
    return Stack(
      children: [
        _topTitle,
        _bottomAction,
      ],
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

  Widget get _topTitle {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + dPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              LocaleKeys.welcome_to.tr(),
              style: const TextStyle(color: AppTheme.nearlyBlack, fontSize: 30, fontWeight: FontWeight.w300),
            ),
            SizedBox(height: dPadding_2),
            Text(
              "Video Downloader for TikTok",
              style: TextStyle(color: AppTheme.nearlyBlack, fontSize: 20, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: dPadding * 3),
            _appLogo,
          ],
        ),
      ),
    );
  }

  Widget get _bottomAction {
    return Align(
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
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => SystemComponentManager.instance.launchInBrowser(kTermsOfServiceURL),
                  ),
                  TextSpan(
                    style: subtitleStyle,
                    text: LocaleKeys.privacy_subtile_2.tr(),
                  ),
                  TextSpan(
                    style: subtitleStyle.copyWith(color: AppTheme.actionGreen),
                    text: " ${LocaleKeys.privacy_policy.tr()}",
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => SystemComponentManager.instance.launchInBrowser(kPrivacyPolicyURL),
                  ),
                ],
              ),
            ),
            SizedBox(height: dPadding),
            SizedBox(
              height: dBtnSize,
              child: actionBtn(LocaleKeys.continue_title.tr(), onTap: () {
                var page = IndexPageRouteHandler.instance.page();
                AppNavigator.pushReplacementRoute(page);
                AppPreference.instance.setInt(AppPreferenceKey.latestAgreePrivacyDate.value, currentTimestamp);
              }),
            ),
            SizedBox(height: dPadding),
            SizedBox(
              height: dBtnSize,
              child: normalBtn(LocaleKeys.later.tr(), onTap: () {
                ToastManager.instance.showTextToast(context, LocaleKeys.privacy_skip_tips.tr());
              }),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + dPadding),
          ],
        ),
      ),
    );
  }
}
