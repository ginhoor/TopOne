import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:top_one/app.dart';
import 'package:top_one/tool/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 初始化下载模块
  await FlutterDownloader.initialize(debug: true, ignoreSsl: true);

  if (Platform.isIOS) {
    getApplicationDocumentsDirectory().then((value) => logDebug(value));
  }

  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]).then((_) => runApp(const App()));
}
