import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class HUDEasyLoading {
  static final HUDEasyLoading instance = HUDEasyLoading._instance();
  factory HUDEasyLoading() => instance;
  HUDEasyLoading._instance();

  static Widget Function(BuildContext, Widget?) init({Widget Function(BuildContext, Widget?)? builder}) =>
      EasyLoading.init();

  static bool get isShowing {
    return EasyLoading.isShow;
  }

  static Future<void> showLoading({String? status}) {
    EasyLoading.instance
      ..contentPadding = EdgeInsets.all(10)
      ..textPadding = EdgeInsets.all(10)
      ..loadingStyle = EasyLoadingStyle.dark
      ..userInteractions = false
      ..fontSize = 15;
    return EasyLoading.show(status: status);
  }

  // static Future<void> showError(String text) {
  //   EasyLoading.instance
  //     ..textPadding = EdgeInsets.all(10)
  //     ..loadingStyle = EasyLoadingStyle.light
  //     ..fontSize = 15;
  //   return EasyLoading.showError(text);
  // }

  static Future<void> dismiss() async {
    if (EasyLoading.isShow) return await EasyLoading.dismiss();
  }
}
