import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:top_one/gen/locale_keys.gen.dart';

class ToastManager {
  static final ToastManager instance = ToastManager._instance();
  factory ToastManager() => instance;
  ToastManager._instance();

  static const _defaultShowToastDuration = Duration(seconds: 2);

  void showTextToast(BuildContext context, String content) {
    showToast(context, Text(content, style: TextStyle(color: Colors.white, fontSize: 14)));
  }

  void showToast(BuildContext context, Widget content,
      {Duration duration = _defaultShowToastDuration, SnackBarAction? action, bool hasDoneAction = true}) {
    var scaffoldMessenger = ScaffoldMessenger.of(context);

    SnackBarAction? barAction;
    if (action != null) {
      barAction = action;
    } else if (hasDoneAction) {
      barAction = SnackBarAction(
        label: LocaleKeys.done.tr(),
        onPressed: () {
          scaffoldMessenger.hideCurrentSnackBar();
        },
        textColor: Colors.white,
      );
    }

    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: content,
        duration: Duration(seconds: 2),
        action: barAction,
      ),
    );
  }
}
