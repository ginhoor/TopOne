import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tool_kit/manager/locale_manager.dart';
import 'package:top_one/app/app_module/app_info_module.dart';
import 'package:top_one/gen/locale_keys.gen.dart';
import 'package:top_one/view/hud_easy_loading.dart';
import 'package:top_one/view/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class SystemComponentManager {
  static final SystemComponentManager instance = SystemComponentManager._instance();
  factory SystemComponentManager() => instance;
  SystemComponentManager._instance();

  Future<void> launchInBrowser(String url) async {
    var uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<bool> sendFeedbackEmail(BuildContext context) async {
    await HUDEasyLoading.showLoading();
    final String email = 'gfr.top.one@gmail.com';
    final String subject = 'Feedback';
    final String body = 'app:${AppInfoModule.instance.sysInfo?.packageName}\n'
        'app_version:${AppInfoModule.instance.appVersion}\n'
        "device_type:${AppInfoModule.instance.sysInfo?.device}\n"
        'android_version:${AppInfoModule.instance.sysInfo?.systemVersion}\n'
        'country_code:${LocaleManager().currentCountryCode}\n'
        'system_language:${LocaleManager().currentLanguageCode}\n';
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: Uri.encodeComponent(email),
      queryParameters: {
        'subject': Uri.encodeComponent(subject),
        'body': body,
      },
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      var result = launchUrl(emailLaunchUri);
      await HUDEasyLoading.dismiss();
      return result;
    }
    ToastManager.instance.showTextToast(context, LocaleKeys.email_settings_is_wrong_title.tr());
    await HUDEasyLoading.dismiss();
    return false;
  }
}
