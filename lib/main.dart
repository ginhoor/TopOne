import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path_provider/path_provider.dart';
import 'package:top_one/app/app.dart';
import 'package:top_one/app/logger.dart';
import 'package:top_one/firebase_options.dart';
import 'package:top_one/service/ad/ad_service.dart';

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

  await SystemChrome.setPreferredOrientations(
      <DeviceOrientation>[DeviceOrientation.portraitUp]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  MobileAds.instance.initialize();
  ADService().preloadAds();
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('zh')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const App(),
    ),
  );
}
