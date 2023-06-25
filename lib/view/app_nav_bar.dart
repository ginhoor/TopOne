import 'package:flutter/material.dart';

AppBar createAppNavbar(Widget titleWidget, {Widget? leading, List<Widget>? actions, double elevation = 1}) {
  return AppBar(
    backgroundColor: Colors.white,
    centerTitle: true,
    title: titleWidget,
    iconTheme: IconThemeData(color: Colors.black),
    elevation: elevation,
    titleTextStyle: const TextStyle(
      color: Colors.black,
      fontSize: 17,
      fontWeight: FontWeight.bold,
    ),
    leading: leading,
    actions: actions,
  );
}
