import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:top_one/app/app.dart';
import 'package:top_one/data/hive_datasource.dart';
import 'package:top_one/firebase_options.dart';
import 'package:top_one/service/download_service.dart';

Future<void> beforeRun() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(
      <DeviceOrientation>[DeviceOrientation.portraitUp]);

  await EasyLocalization.ensureInitialized();
  await DownloadService.ensureInitialized();
  // firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  // ad
  MobileAds.instance.initialize();
  // db
  await HiveDatasource.ensureInitialized();
}

void main() async {
  await beforeRun();
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('zh'), Locale('id')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const App(),
    ),
  );
}
