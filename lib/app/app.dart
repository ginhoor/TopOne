import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:top_one/app/app_navigator_observer.dart';
import 'package:top_one/module/index/index_screen.dart';
import 'package:top_one/service/ad/ad_service.dart';
import 'package:top_one/service/app_info_service.dart';
import 'package:top_one/service/download_service.dart';
import 'package:top_one/theme/fitness_app_theme.dart';
import 'package:top_one/tool/shared_preferences_helper.dart';

import 'app_vm.dart';

class App extends StatefulWidget {
  const App({super.key});
// const App({required Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  final AppVM _appVM = AppVM();

  @override
  void initState() {
    super.initState();
    // if (AuditHelper().isAuditMode) {
    //   checkLoadProcess();
    // } else {
    initAppModule().then((value) {
      // checkLoadProcess();
    });
  }

  @override
  void dispose() {
    // if (_logoPageTimer != null && _logoPageTimer.isActive) {
    // _logoPageTimer.cancel();
    // }
    // WidgetsBinding.instance.removeObserver(this);
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
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        title: appName,
        navigatorObservers: [
          AppNavigatorObserver(),
          AppNavigatorObserver.routeObserver,
        ],
        // theme: AppTheme.defaultLightTheme,
        debugShowCheckedModeBanner: false,
        // routes: Routes.route(),
        // onGenerateRoute: (settings) => Routes.onGenerateRoute(settings),
        // onUnknownRoute: (settings) => Routes.onUnknownRoute(settings),
        home: Container(
          color: FitnessAppTheme.background,
          child: const SafeArea(
            top: false,
            bottom: false,
            child: Scaffold(
              backgroundColor: FitnessAppTheme.background,
              body: IndexScreen(),
            ),
          ),
        ),
        builder: EasyLoading.init(),
      ),
    );
  }

  Future<void> initAppModule() async {
    DownloadService().setupDirs();
    await AppInfoService().init();
    ADService().preloadAds();
    await SharedPreferencesHelper().setup();
    _appVM.init();
  }
}
