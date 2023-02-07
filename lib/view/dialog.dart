import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:top_one/app/app_navigator_observer.dart';

Future<void> showGHDialog(
    BuildContext context, Text title, Text message, TextButton action) async {
  return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: title,
          content: SingleChildScrollView(child: message),
          actions: [
            action,
            TextButton(
              child: const Text('cancel').tr(),
              onPressed: () {
                AppNavigator.popPage();
              },
            )
          ],
        );
      });
}
