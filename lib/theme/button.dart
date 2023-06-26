import 'package:flutter/material.dart';
import 'package:top_one/gen/colors.gen.dart';

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
    {required void Function() onTap,
    Color backgroundColor = Colors.white,
    Color textColor = ColorName.blackText,
    TextStyle? textStyle}) {
  return MaterialButton(
    onPressed: onTap,
    child: Text(
      title,
      style: textStyle ?? TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w400),
    ),
    elevation: 4,
    highlightElevation: 2,
    color: backgroundColor,
    shape: StadiumBorder(),
  );
}
