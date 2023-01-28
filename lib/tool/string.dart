//aes加密
import 'dart:math';

import 'package:easy_localization/easy_localization.dart' as localization;

String generateRandomString(int len) {
  var r = Random();
  return String.fromCharCodes(
      List.generate(len, (index) => r.nextInt(33) + 89));
}

/// NOTE: output: 04/17 15:23:05
String timeFormatMDHMS(int millseconds, {String split = '/'}) {
  return localization.DateFormat('MM${split}dd HH:mm:ss')
      .format(DateTime.fromMillisecondsSinceEpoch(millseconds));
}
