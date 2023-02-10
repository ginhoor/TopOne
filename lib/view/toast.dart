import 'package:flutter/material.dart';

void showToast(BuildContext context, Widget content) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: content),
  );
}
