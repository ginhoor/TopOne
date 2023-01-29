import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:top_one/app/app.dart';
import 'package:top_one/tool/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  if (Platform.isIOS) {
    getApplicationDocumentsDirectory().then((value) => logDebug(value));
    var dir = await getApplicationSupportDirectory();
    if (!dir.existsSync()) {
      await dir.create();
    }
    await FlutterDownloader.initialize(debug: true, ignoreSsl: true);
  } else {
    await FlutterDownloader.initialize(debug: true, ignoreSsl: true);
  }

  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('zh')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const App(),
    ),
  );
}
