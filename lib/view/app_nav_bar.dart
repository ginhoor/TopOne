import 'package:flutter/material.dart';
import 'package:top_one/app/app_navigator_observer.dart';

import '../theme/fitness_app_theme.dart';

AppBar defaultAppNavbar(Widget titleWidget) {
  return AppBar(
    backgroundColor: FitnessAppTheme.nearlyWhite,
    centerTitle: true,
    title: titleWidget,
    elevation: 1,
    titleTextStyle: const TextStyle(
      color: FitnessAppTheme.nearlyBlack,
      fontSize: 17,
      fontWeight: FontWeight.bold,
    ),
    leading: IconButton(
      icon:
          const Icon(Icons.arrow_back_ios, color: FitnessAppTheme.nearlyBlack),
      onPressed: () => {AppNavigator.popPage()},
    ),
  );
}
