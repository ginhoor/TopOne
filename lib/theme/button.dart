import 'package:flutter/material.dart';
import 'package:top_one/gen/colors.gen.dart';
import 'package:top_one/theme/theme_config.dart';

Widget normalBtn(String title,
    {required void Function() onTap, Color backgroundColor = Colors.white, Color textColor = ColorName.blackText}) {
  return generateBtn(title, onTap: onTap, backgroundColor: backgroundColor, textColor: textColor);
}

Widget actionBtn(String title,
    {required void Function() onTap,
    Color backgroundColor = ColorName.mainThemeAction,
    Color textColor = Colors.white}) {
  return generateBtn(title, onTap: onTap, backgroundColor: backgroundColor, textColor: textColor);
}

Widget generateBtn(String title,
    {required void Function() onTap, Color backgroundColor = Colors.white, Color textColor = ColorName.blackText}) {
  return MaterialButton(
    onPressed: onTap,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(title, style: TextStyle(color: textColor, fontSize: 16)),
      ],
    ),
    color: backgroundColor,
    textColor: textColor,
    shape: RoundedRectangleBorder(borderRadius: dBorderRadius),
  );
}
