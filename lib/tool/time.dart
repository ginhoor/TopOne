//aes加密
import 'package:easy_localization/easy_localization.dart' as localization;

/// NOTE: system time;
int currentMicroseconds() {
  return DateTime.now().microsecondsSinceEpoch;
}

int currentMilliseconds() {
  return DateTime.now().millisecondsSinceEpoch;
}

int currentTimestamp() {
  return DateTime.now().millisecondsSinceEpoch ~/ 1000;
}

/// NOTE: output: 04/17 15:23:05
String timeFormatMDHMS(int millseconds, {String split = '/'}) {
  return localization.DateFormat('MM${split}dd HH:mm:ss')
      .format(DateTime.fromMillisecondsSinceEpoch(millseconds));
}
