import 'package:flutter/material.dart';
import 'package:top_one/app/app_navigator_observer.dart';
import 'package:top_one/theme/app_theme.dart';

AppBar defaultAppNavbar(Widget titleWidget) {
  return AppBar(
    backgroundColor: AppTheme.nearlyWhite,
    centerTitle: true,
    title: titleWidget,
    elevation: 1,
    titleTextStyle: const TextStyle(
      color: AppTheme.nearlyBlack,
      fontSize: 17,
      fontWeight: FontWeight.bold,
    ),
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_ios, color: AppTheme.nearlyBlack),
      onPressed: () => AppNavigator.popPage(),
    ),
  );
}
