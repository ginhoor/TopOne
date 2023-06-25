import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:top_one/app/app_navigator_observer.dart';
import 'package:top_one/theme/app_theme.dart';

class DialogManager {
  static final DialogManager instance = DialogManager._instance();
  factory DialogManager() => instance;

  DialogManager._instance();

  showMessageDialog(BuildContext context,
      {Widget? title, Widget? message, required List<TextButton> actions, bool hasCancel = true}) async {
    List<TextButton> newActions = [];
    if (hasCancel) {
      newActions.add(
        TextButton(
          child: Text("cancel".tr(), style: TextStyle(color: AppTheme.redDialogActionTitle)),
          onPressed: () => AppNavigator.popPage(),
        ),
      );
    }
    newActions.addAll(actions);
    return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          List<Widget> texts = [title ?? Text(""), message ?? Text("")];
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
            content: Container(
              width: double.maxFinite,
              child: ListView.separated(
                separatorBuilder: (BuildContext context, int index) => SizedBox(height: 8),
                shrinkWrap: true,
                itemCount: texts.length,
                itemBuilder: (ctx, i) => (texts[i]),
              ),
            ),
            actions: newActions,
          );
        });
  }
}
