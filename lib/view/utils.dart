import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:top_one/theme/fitness_app_theme.dart';
import 'package:top_one/tool/color.dart';

final OutlineInputBorder outlineInputBorder = OutlineInputBorder(
  gapPadding: 5,
  borderRadius: const BorderRadius.all(Radius.circular(8.0)),
  borderSide: BorderSide(
    width: 0,
    color: Colors.grey[200]!,
  ),
);

Widget addFadeTransition(Widget child, Animation<double> animation) {
  return FadeTransition(
    opacity: animation,
    child: Transform(
      transform:
          Matrix4.translationValues(0.0, 30 * (1.0 - animation.value), 0.0),
      child: Padding(
          padding:
              const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
          child: child),
    ),
  );
}

Widget addShadows(Widget child) {
  return Container(
    //阴影
    decoration: BoxDecoration(
      color: FitnessAppTheme.white,
      borderRadius: const BorderRadius.all(
        Radius.circular(8.0),
      ),
      boxShadow: <BoxShadow>[
        BoxShadow(
            color: FitnessAppTheme.grey.withOpacity(0.2),
            offset: const Offset(1.1, 1.1),
            blurRadius: 10.0),
      ],
    ),
    child: child,
  );
}

Widget generateActionButton(String title, void Function() onTap) {
  return Center(
    child: Material(
      borderRadius: BorderRadius.circular(8.0),
      // 设置背景颜色 默认矩形
      color: FitnessAppTheme.nearlyWhite,
      child: InkWell(
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        //点击事件回调
        onTap: onTap,
        //不要在这里设置背景色，for则会遮挡水波纹效果,如果设置的话尽量设置Material下面的color来实现背景色
        child: Container(
          //设置child 居中
          alignment: const Alignment(0, 0),
          child: Text(
            title,
            style: const TextStyle(
              color: FitnessAppTheme.nearlyBlack,
              fontSize: 16.0,
            ),
          ).tr(),
        ),
      ),
    ),
  );
}

Widget createProgress(Animation<double> animation) {
  var radius = const Radius.circular(4.0);
  return Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Container(
      height: 4,
      width: 70,
      decoration: BoxDecoration(
        color: HexColor('#87A0E5').withOpacity(0.2),
        borderRadius: BorderRadius.all(radius),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: ((70 / 1.2) * animation.value),
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                HexColor('#87A0E5'),
                HexColor('#87A0E5').withOpacity(0.5),
              ]),
              borderRadius: BorderRadius.all(radius),
            ),
          )
        ],
      ),
    ),
  );
}
