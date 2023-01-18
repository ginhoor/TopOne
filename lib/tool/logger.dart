import 'package:logger/logger.dart';

final Logger logger = Logger(
  printer: SimplePrinter(
    printTime: true,
    colors: false,
  ),
);

class CrashLog {
  Map<String, dynamic> systemInfo = {};
  String userid = '';
  String crash = '';
  int timestamp = 0;
  String appVersion = '';

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {};
    data['systemInfo'] = systemInfo;
    data['appVersion'] = appVersion;
    data['userid'] = userid;
    data['timestamp'] = timestamp;
    data['crash'] = crash;
    return data;
  }
}

class EventLog {
  Map<String, dynamic> systemInfo = {};
  String userid = '';
  Map<String, dynamic> event = {};
  int timestamp = 0;
  String appVersion = '';

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {};
    data['systemInfo'] = systemInfo;
    data['appVersion'] = appVersion;
    data['userid'] = userid;
    data['timestamp'] = timestamp;
    data['event'] = event;
    return data;
  }
}

class LoggerConstant {
  static String appVersion = '';
  static Map<String, dynamic> systemInfo = {};
}

Map<String, CrashLog> crashLogs = {};

void logVerbose(dynamic message, [dynamic error, StackTrace? stackTrace]) {
  logger.v(message, error, stackTrace);
}

void logDebug(dynamic message, [dynamic error, StackTrace? stackTrace]) {
  logger.d(message, error, stackTrace);
}

void logInfo(dynamic message, [dynamic error, StackTrace? stackTrace]) {
  logger.i(message, error, stackTrace);
}

void logWarn(dynamic message, [dynamic error, StackTrace? stackTrace]) {
  logger.w(message, error, stackTrace);
}

void logError(dynamic message, [dynamic error, StackTrace? stackTrace]) {
  logger.e(message, error, stackTrace);
  // LoggerManager().logger.e(message, error, stackTrace);

  // String errLog = message ?? '';
  // errLog += (error?.toString() ?? '');
  // errLog += (stackTrace?.toString() ?? '');
  // if (errLog != '') {
  //   if (errLog.length > 1500) {
  //     errLog = errLog.substring(0, 1500);
  //   }
  //   if (kReleaseMode) {
  //     reportCrashLog(errLog);
  //   }
  // }
}

// void logScreen(dynamic message) {
//   if (message == null) {
//     return;
//   }
//   LoggerManager()
//       .defaultObserver
//       .recordLog({'[${Utils.currentNetworkMilliseconds()}]': message});
// }

// void reportCrashLog(String errLog) {
//   String hash = md5.convert(utf8.encode(errLog)).toString();
//   if (crashLogs.containsKey(hash)) {
//     return;
//   }
//   CrashLog crashLog = CrashLog();
//   crashLog.appVersion = LoggerConstant.appVersion;
//   crashLog.timestamp = Utils.currentNetworkTimestamp();
//   crashLog.userid = AuthManager().authuserInfo?.userid ?? 'unknown_user';
//   crashLog.systemInfo = LoggerConstant.systemInfo;
//   crashLog.crash = errLog;

//   crashLogs[hash] = crashLog;

//   Dio dio = Dio();
//   Map<String, dynamic> info = {
//     'tag': 'Flutter',
//     'msg': crashLog.toJson(),
//   };
//   try {
//     dio.post(
//       'https://log.daqunchat.net/daqun/log',
//       data: info,
//       options: Options(headers: {
//         'Content-Type': 'application/json',
//       }),
//     );
//   } catch (e) {
//     logDebug('reportCrashLog: $e');
//   }
// }

// void reportEventLog(EventModel eventModel) {
//   EventLog eventLog = EventLog();
//   eventLog.appVersion = LoggerConstant.appVersion;
//   eventLog.timestamp = Utils.currentNetworkTimestamp();
//   eventLog.userid = AuthManager().authuserInfo?.userid ?? 'unknown_user';
//   eventLog.systemInfo = LoggerConstant.systemInfo;
//   eventLog.event = eventModel.toJson();

//   Dio dio = Dio();
//   Map<String, dynamic> info = {
//     'tag': 'Flutter',
//     'msg': eventLog.toJson(),
//   };
//   try {
//     dio.post(
//       'https://log.daqunchat.net/daqun/log',
//       data: info,
//       options: Options(headers: {
//         'Content-Type': 'application/json',
//       }),
//     );
//   } catch (e) {
//     logDebug('reportEventLog: $e');
//   }
// }
