import 'package:flutter/material.dart';
import 'package:top_one/tool/logger.dart';
import 'package:top_one/tool/time.dart';

class AppNavigator {
  static Future<T?> pushRoute<T extends Object?>(Route<T> route) async {
    return AppNavigatorObserver().navigator!.push(route);
  }

  static Future<void> pushPage(Widget screen) async {
    await pushRoute(
      PageRouteBuilder(pageBuilder: (BuildContext context,
          Animation<double> animation, Animation<double> secondaryAnimation) {
        return FadeTransition(opacity: animation, child: screen);
      }),
    );
  }

  static void popPage() {
    AppNavigatorObserver().navigator!.pop();
  }
}

class AppNavigatorObserver extends NavigatorObserver {
  AppNavigatorObserver._internal();

  static final AppNavigatorObserver _instance =
      AppNavigatorObserver._internal();

  factory AppNavigatorObserver() => _instance;

  static final RouteObserver<PageRoute> routeObserver =
      RouteObserver<PageRoute>();

  Map<String, int> pageTime = {};
  String currentPageChains = '';
  String currentTabPageName = '';

  @override
  void didPush(Route route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);

    if (route == null) {
      currentPageChains += '/unknown_page';
      return;
    }

    if (route.settings.name == '/') {
      currentPageChains = 'root';
    } else {
      currentPageChains += '/${route.settings.name}';
    }

    pageTime[currentPageChains] = currentTimestamp();

    logDebug(
        '[AppNavigatorObserver]didPush: $currentPageChains, $currentTabPageName');
  }

  @override
  void didPop(Route route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    String pageName = '/${route.settings.name}';

    String before = currentPageChains;
    if (!currentPageChains.endsWith(pageName)) return;

    currentPageChains = currentPageChains.substring(
        0, currentPageChains.length - pageName.length);

    logDebug(
        '[AppNavigatorObserver]didPop: $pageName, $currentPageChains, $currentTabPageName');

    if (pageName == '/unknown_page' || pageName == 'HomePage') return;

    if (pageTime[before] != null) {
      int duration = currentTimestamp() - pageTime[before]!;

      // EventModel eventModel = EventManager().makePageEvent(
      //     pageName.substring(1, pageName.length), duration, before);
      // if (eventModel != null) {
      //   reportEventLog(eventModel);
      // }
    }
  }

  /// NOTE: 切换.
  void onSwitchTabPage(String tabPageName) {
    // if (currentTabPageName != '' && currentPageChains.endsWith('/HomePage')) {
    //   EventModel eventModel = EventManager().makePageEvent('HomePage/$tabPageName', 0, currentPageChains);
    //   if (eventModel != null) {
    //     reportEventLog(eventModel);
    //   }
    // }

    // pageTime[getPageName()] = Utils.currentTimestamp();

    // currentTabPageName = tabPageName;
  }

  String getPageName() {
    if (currentPageChains.endsWith('/HomePage') && currentTabPageName != '') {
      return 'HomePage/$currentTabPageName';
    } else {
      return currentPageChains;
    }
  }

  void onAppPaused(bool pause) {
    List<String> pages = currentPageChains.split('/');
    String pageName = pages.last;
    if (pageName == 'HomePage' || pageTime[pageName] == null) {
      return;
    }
    // int duration = currentTimestamp() - pageTime[currentPageChains]!;
    if (pause) {
      // EventModel eventModel =
      //     EventManager().makePageEvent(pageName, duration, currentPageChains);
      // if (eventModel != null) {
      //   reportEventLog(eventModel);
      // }
    } else {
      pageTime[currentPageChains] = currentTimestamp();
    }
  }
}
