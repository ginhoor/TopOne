import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gh_tool_package/config/app_preference.dart';
import 'package:provider/provider.dart';
import 'package:top_one/api/http_engine.dart';
import 'package:top_one/app/app_navigator_observer.dart';
import 'package:top_one/app/routes.dart';
import 'package:top_one/data/tt_result_datasource.dart';
import 'package:top_one/module/splash/splash_screen.dart';
import 'package:top_one/service/ad/ad_service.dart';
import 'package:top_one/service/app_info_service.dart';
import 'package:top_one/service/download_service.dart';
import 'package:top_one/theme/app_theme.dart';

import 'app_vm.dart';

class App extends StatefulWidget {
  const App({super.key});
// const App({required Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AppState();
}

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

class _AppState extends State<App> with WidgetsBindingObserver {
  final AppVM _appVM = AppVM();

  @override
  void initState() {
    super.initState();
    initAppModule();
  }

  static Future<void> initAppModule() async {
    ADService().preloadAds();
    DownloadService().setupDirs();

    await AppInfoService().init();
    await AppPreference().setup();
    await TTResultDatasource.setup();
    await HttpEngine.setup();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider.value(value: _appVM)],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        title: appName,
        navigatorObservers: [
          AppNavigatorObserver(),
          AppNavigatorObserver.routeObserver,
        ],
        debugShowCheckedModeBanner: false,
        onGenerateRoute: (settings) => Routes.onGenerateRoute(settings),
        onUnknownRoute: (settings) => Routes.onUnknownRoute(),
        home: Container(
          color: AppTheme.background,
          child: const SafeArea(
            top: false,
            bottom: false,
            child: Scaffold(
              backgroundColor: AppTheme.background,
              body: SplashScreen(),
            ),
          ),
        ),
        builder: EasyLoading.init(),
      ),
    );
  }
}
