import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tool_kit/log/logger.dart';
import 'package:flutter_tool_kit/manager/file_manager.dart';
import 'package:top_one/app/app_module/app_info_module.dart';
import 'package:top_one/app/app_module/datasource_module.dart';
import 'package:top_one/app/app_module/network_module.dart';
import 'package:top_one/app/app_module/preference_module.dart';
import 'package:top_one/app/app_module/resource_module.dart';
import 'package:top_one/app/app_navigator_observer.dart';
import 'package:top_one/app/routes.dart';
import 'package:top_one/module/splash/splash_page.dart';
import 'package:top_one/theme/app_theme.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<StatefulWidget> createState() => _AppState();
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class _AppState extends State<App> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    initAppModule();
  }

  static Future<void> initAppModule() async {
    await AppInfoModule.instance.loadModule();
    await ResourceModule.instance.loadModule();
    await PreferenceModule.instance.loadModule();
    await DatasourceModule.instance.loadModule();
    await NetworkModule.instance.loadModule();

    FileManager.getDocumentsDirPath().then((value) {
      logDebug("document: $value");
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.inactive:
        logDebug("Switch AppLifecycleState.inactive");
        break;
      case AppLifecycleState.resumed:
        logDebug("Switch AppLifecycleState.resumed");
        break;
      case AppLifecycleState.paused:
        logDebug("Switch AppLifecycleState.paused");
        break;
      case AppLifecycleState.detached:
        logDebug("Switch AppLifecycleState.detached");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 强制展示顶部底部安全区域
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    // 状态栏透明
    // SystemChrome.setSystemUIOverlayStyle(
    //     const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarBrightness: Brightness.dark));

    return ProviderScope(
      child: MaterialApp(
        navigatorKey: navigatorKey,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        title: appName,
        navigatorObservers: [AppNavigatorObserver()],
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
              body: SplashPage(),
            ),
          ),
        ),
        builder: EasyLoading.init(),
      ),
    );
  }
}
