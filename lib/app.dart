import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:top_one/nav/navigation_home_screen.dart';

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
    /// CPU: 6% 90%; 3%
    // return MaterialApp(
    //   home: Scaffold(
    //     body: Container(
    //       child: Center(
    //         child: Text('Hello'),
    //       ),
    //     ),
    //   ),
    // );

    // return MaterialApp(
    //   home: Scaffold(
    //     body: AniPage(),
    //   ),
    // );

    /// CPU: 80% 180%; gif_ani-15%  gif-6%
    // return MaterialApp(
    //   home: TestHomePage(),
    // );

    return MultiProvider(
      providers: [ChangeNotifierProvider.value(value: _appVM)],
      child: const MaterialApp(
        title: '大群',
        navigatorObservers: [
          // AppNavigatorObserver(),
          // AppNavigatorObserver.routeObserver,
          // LeakNavigatorObserver(shouldCheck: (route) {
          // return false;
          // }),
        ],
        // theme: AppTheme.defaultLightTheme,
        debugShowCheckedModeBanner: false,
        // routes: Routes.route(),
        // onGenerateRoute: (settings) => Routes.onGenerateRoute(settings),
        // onUnknownRoute: (settings) => Routes.onUnknownRoute(settings),
        home: NavigationHomeScreen(),
        // localizationsDelegates: [
        // GlobalMaterialLocalizations.delegate,
        // GlobalWidgetsLocalizations.delegate,
        // GlobalCupertinoLocalizations.delegate,
        // ],
        // supportedLocales: [
        //   Locale('zh', 'CN'),
        //   Locale('en', 'US'),
        // ],
      ),
    );
  }

  // void checkLoadProcess() {
  //   _appVM.isReady = true;
  //   bool biometricCheck =
  //       SharedPreferencesHelper().getBool(SharedPreferenceKeys.BIOMETRIC_LOCK);
  //   if (showLaunchPage()) {
  //     logDebug('checkLoadProcess');
  //     Utils.pushPage(LaunchSplashPage(
  //       appVM: _appVM,
  //     ));
  //     return;
  //   } else {
  //     if (biometricCheck) {
  //       Utils.localAuthCheck().then((value) {
  //         if (value) {
  //           _appVM.gesCheck(biometricCheck: true);
  //         }
  //       });
  //     } else {
  //       _appVM.gesCheck();
  //     }
  //   }

  //   // loadProcess++;
  //   // if (loadProcess == 2) {
  //   //   _appVM.isReady = true;
  //   //   bool biometricCheck = SharedPreferencesHelper().getBool(SharedPreferenceKeys.BIOMETRIC_LOCK);
  //   //   if (biometricCheck) {
  //   //     Utils.localAuthCheck().then((value) {
  //   //       if (value) {
  //   //         gesCheck();
  //   //       }
  //   //     });
  //   //   } else {
  //   //     gesCheck();
  //   //   }
  //   // }
  // }

  // bool showLaunchPage() {
  //   if (AppGlobalConfigManager().appGlobalConfig == null) {
  //     return false;
  //   }
  //   if (AppGlobalConfigManager().appGlobalConfig.launchScreen == null) {
  //     return false;
  //   }
  //   LaunchScreen launchScreen =
  //       AppGlobalConfigManager().appGlobalConfig.launchScreen;
  //   int startTime =
  //       DateTime.parse(launchScreen.beginTime).millisecondsSinceEpoch;
  //   int finishTime =
  //       DateTime.parse(launchScreen.endTime).microsecondsSinceEpoch;
  //   int currentSeconds = Utils.currentSeconds();
  //   int currentMillions = DateTime.now().microsecondsSinceEpoch;
  //   String picUrl = launchScreen.picUrl;
  //   String updateAt = '_' +
  //       DateTime.parse(launchScreen.updateAt).microsecondsSinceEpoch.toString();
  //   String userid = UserManager().currentUserid();
  //   if ((startTime != null &&
  //           finishTime != null &&
  //           (currentMillions < startTime || currentMillions > finishTime)) ||
  //       Utils.isEmpty(userid) ||
  //       Utils.isEmpty(picUrl)) {
  //     return false;
  //   }
  //   Utils.currentNetworkMilliseconds();
  //   switch (launchScreen.launchType) {
  //     case 1: //只显示一次
  //       String typeOne = SharedPreferencesHelper().getString(
  //           SharedPreferenceKeys.LUANCH_PAGE_SHOW_TYPE_ONE + updateAt);
  //       if (Utils.isEmpty(typeOne)) {
  //         SharedPreferencesHelper().setString(
  //             SharedPreferenceKeys.LUANCH_PAGE_SHOW_TYPE_ONE + updateAt,
  //             picUrl);
  //         return true;
  //       }
  //       if (typeOne == picUrl) {
  //         return false;
  //       }
  //       SharedPreferencesHelper().setString(
  //           SharedPreferenceKeys.LUANCH_PAGE_SHOW_TYPE_ONE + updateAt, picUrl);
  //       return true;
  //     case 2: //每日显示一次
  //       String typeTwo = SharedPreferencesHelper().getString(
  //           SharedPreferenceKeys.LUANCH_PAGE_SHOW_TYPE_ONE + updateAt);
  //       String currentDay = Utils.getNowTimeDayString();
  //       if (Utils.isEmpty(typeTwo)) {
  //         SharedPreferencesHelper().setString(
  //             SharedPreferenceKeys.LUANCH_PAGE_SHOW_TYPE_ONE + updateAt,
  //             Utils.getNowTimeDayString());
  //         return true;
  //       }
  //       if (currentDay != typeTwo) {
  //         SharedPreferencesHelper().setString(
  //             SharedPreferenceKeys.LUANCH_PAGE_SHOW_TYPE_ONE + updateAt,
  //             Utils.getNowTimeDayString());
  //         return true;
  //       }
  //       return false;
  //     case 3: //每日时间段内首次都显示
  //       List times = json.decode(launchScreen.times);
  //       List<LaunchTimes> timesList =
  //           times.map((e) => LaunchTimes.fromJson(e)).toList();
  //       // timesList.add(new LaunchTimes(beginTime: currentSeconds-60,endTime: currentSeconds+60));
  //       String day = Utils.getNowTimeDayString() + '_';
  //       for (LaunchTimes launchTimes in timesList) {
  //         if (currentSeconds > launchTimes.beginTime &&
  //             currentSeconds < launchTimes.endTime) {
  //           String dayKey = SharedPreferencesHelper().getString(
  //               SharedPreferenceKeys.LUANCH_PAGE_SHOW_DAY_TIMES_KEY + updateAt);
  //           String keys = '${day}_${launchTimes.beginTime}$updateAt';
  //           if (Utils.isEmpty(dayKey) || dayKey != keys) {
  //             SharedPreferencesHelper().setString(
  //                 SharedPreferenceKeys.LUANCH_PAGE_SHOW_DAY_TIMES_KEY +
  //                     updateAt,
  //                 keys);
  //             return true;
  //           }
  //           return false;
  //         }
  //       }
  //       return false;
  //     default:
  //       return false;
  //   }
  // }

  Future<void> initAppModule() async {
    // await SharedPreferencesHelper().init();
    // AppConfig().appEnv =
    //     SharedPreferencesHelper().getString(SharedPreferenceKeys.APP_ENV) == ''
    //         ? AppConfig.APP_ENV_PROD
    //         : SharedPreferencesHelper().getString(SharedPreferenceKeys.APP_ENV);

    // if (Utils.getPadLogin()) {
    //   await Hive.initFlutter(AppConfig().hiveDirPad);
    // } else {
    //   await Hive.initFlutter(AppConfig().hiveDir);
    // }

    // await Utils().init();
    // HttpUtils().addHttpProxy();
    // HttpCrop().addHttpProxy();
    // HttpDaqun().addHttpProxy();
    // HttpYapiUtils().addHttpProxy();
    // await LoggerManager().init();
    // if (Platform.isAndroid) {
    //   await Bugly.initAndroidCrashReport(
    //       appId: 'eeebfca9d7', isDebug: kDebugMode);
    // } else if (Platform.isIOS) {
    //   await Bugly.initIosCrashReport(
    //       appId: 'c7512d7369', debugMode: kDebugMode);
    // }
    // await Bugly.setAppVersion(appVersion: Utils().appVersion);

    // await LocalSearchHelper().init();
    // await EmojiManager().init();
    // await JSBridgeHelper.init();

    // await AuthManager().init();
    // await AppGlobalConfigManager().init();

    // if (!AuditHelper().isAuditMode) {
    //   // JPushManage().initPlatformState();
    //   ShareManage().initPlatformState();
    // }

    // OpenURLManager().initPlatformState();
    // OpenNotificationManager().initPlatform();
    // YochatShortcutManager().initPlatformState();
    // UpdateHelper().init();

    // IMEngine().init(imDatabase: SqliteDatabaseIM());
    // SoundManager().registerAudioHandle();
    // IPushManage().initPlatformState();

    _appVM.init();

    // LeakDetector().onLeakedStream.listen((info) {
    //   Utils.showCommonDialog(content: '检测到内存泄漏').then((value) {
    //     showLeakedInfoPage(AppNavigatorObserver().navigator.context, info);
    //   });
    // });
  }
}
