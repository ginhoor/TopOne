import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path_provider/path_provider.dart';
import 'package:top_one/app/app.dart';
import 'package:top_one/firebase_options.dart';
import 'package:top_one/tool/logger.dart';
import 'package:top_one/tool/shared_preferences_helper.dart';

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
    // DeviceOrientation.portraitDown
  ]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  await FirebaseAppCheck.instance.activate(
      webRecaptchaSiteKey: 'recaptcha-v3-site-key',
      // Default provider for Android is the Play Integrity provider. You can use the "AndroidProvider" enum to choose
      // your preferred provider. Choose from:
      // 1. debug provider
      // 2. safety net provider
      // 3. play integrity provider
      androidProvider: AndroidProvider.playIntegrity
      // kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
      );
  await FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);

  await SharedPreferencesHelper().setup();

  MobileAds.instance.initialize();
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('zh')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const App(),
    ),
  );
}
