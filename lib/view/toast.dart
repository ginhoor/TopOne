import 'package:flutter/material.dart';

void showToast(BuildContext ctx, Widget content) {
  ScaffoldMessenger.of(ctx).showSnackBar(
    SnackBar(content: content),
  );
}
