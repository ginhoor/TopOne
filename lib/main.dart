import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tool_kit/log/logger.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:top_one/app/app.dart';
import 'package:top_one/data/hive_datasource.dart';
import 'package:top_one/firebase_options.dart';
import 'package:top_one/service/download_service.dart';

const List<Locale> locales = [
  // ar,de,en,es,fa,fr,hi,id,it,ja,ko,pt-BR,ru,th,tr,vi,zh-Hans,zh-Hant
  Locale('ar'),
  Locale('de'),
  Locale('en'),
  Locale('es'),
  Locale('fa'),
  Locale('fr'),
  Locale('hi'),
  Locale('id'),
  Locale('it'),
  Locale('ja'),
  Locale('en'),
  Locale('ko'),
  Locale.fromSubtags(languageCode: 'pt', scriptCode: 'BR'),
  Locale('ru'),
  Locale('th'),
  Locale('tr'),
  Locale('vi'),
  Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
  Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant')
];

Future<void> beforeRun() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DownloadService.ensureInitialized();
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[DeviceOrientation.portraitUp]);
  await LoggerModule.instance.setup();
  await EasyLocalization.ensureInitialized();
  // firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  // ad
  MobileAds.instance.initialize();
  // db
  await HiveDatasource.ensureInitialized();
}

void main() async {
  runZonedGuarded<Future<void>>(() async {
    await beforeRun();
    FlutterError.onError = (FlutterErrorDetails details) async {
      FlutterError.dumpErrorToConsole(details);
      if (details.stack != null) {
        logError('Flutter Error: ${details.stack}');
        Zone.current.handleUncaughtError(details.exception, details.stack!);
      }
    };
    runApp(
      EasyLocalization(
        supportedLocales: locales,
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        child: const App(),
      ),
    );
  }, (error, stackTrace) {
    logError('', error, stackTrace);
  });
}
