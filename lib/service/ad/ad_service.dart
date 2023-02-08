import 'dart:io';

import 'package:top_one/service/ad/app_open_ad_manager.dart';
import 'package:top_one/service/ad/interstitial_ad_service.dart';
import 'package:top_one/tool/logger.dart';
import 'package:top_one/tool/time.dart';

class ADService {
  ADService._internal();
  static final ADService _instance = ADService._internal();
  factory ADService() => _instance;

  /// index
  static String bannderUnitId1 = Platform.isAndroid
      ? 'ca-app-pub-3945813041461839/2193047326'
      : "ca-app-pub-3945813041461839/2193047326";

  /// history
  static String bannderUnitId2 = Platform.isAndroid
      ? 'ca-app-pub-3945813041461839/5675667770'
      : "ca-app-pub-3945813041461839/5675667770";

  static String appOpenUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/3419835294'
      : 'ca-app-pub-3940256099942544/3419835294';

  static String interstitialUnitId1 = Platform.isAndroid
      ? 'ca-app-pub-3945813041461839/6643428221'
      : 'ca-app-pub-3945813041461839/6643428221';
  static String interstitialUnitId2 = Platform.isAndroid
      ? 'ca-app-pub-3945813041461839/8084771905'
      : 'ca-app-pub-3945813041461839/8084771905';

  static String interstitialUnitId3 = Platform.isAndroid
      ? 'ca-app-pub-3945813041461839/6941482138'
      : 'ca-app-pub-3945813041461839/6941482138';

  static String nativeUnitId = Platform.isAndroid
      ? 'ca-app-pub-3945813041461839/5869672103'
      : 'ca-app-pub-3945813041461839/5869672103';

  /// 开屏广告
  static String TESTAppOpenUnitId = "ca-app-pub-3940256099942544/5662855259";

  /// 横幅广告
  static String TESTBannerUnitId = "ca-app-pub-3940256099942544/2934735716";

  /// 插页式广告
  static String TESTInterstitialUnitId =
      "ca-app-pub-3940256099942544/4411468910";

  /// 插页式视频广告
  static String TESTInterstitialVideoUnitId =
      "ca-app-pub-3940256099942544/5135589807";

  /// 激励广告
  static String TESTRewardUnitId = "ca-app-pub-3940256099942544/1712485313";

  /// 插页式激励广告
  static String TESTInterstitialRewardUnitId =
      "ca-app-pub-3940256099942544/6978759866";

  /// 原生高级广告
  static String TESTNativeUnitId = "ca-app-pub-3940256099942544/3986624511";

  /// 原生高级视频广告
  static String TESTNativeVideoUnitId =
      "ca-app-pub-3940256099942544/2521693316";

  AppOpenAdManager appOpenAdManager =
      AppOpenAdManager(ADService.TESTAppOpenUnitId);

  int latestInterstitialAdShowTime = 0;
  updateLatestInterstitialAdShowTime() {
    latestInterstitialAdShowTime = currentTimestamp();
  }

  bool shouldShowInterstitialAd() {
    final offset = currentTimestamp() - latestInterstitialAdShowTime;
    logDebug("shouldShowInterstitialAd offset: $offset");
    return offset > 60;
  }

  InterstitialAdService indexINTAdService = InterstitialAdService(
    TESTInterstitialVideoUnitId,
    // kDebugMode
    //   ? ADService().TESTInterstitialVideoUnitId
    //   : ADService().interstitialUnitId1
  );
  InterstitialAdService historyINTAdService = InterstitialAdService(
    TESTInterstitialVideoUnitId,
    // kDebugMode
    //   ? ADService().TESTInterstitialVideoUnitId
    //   : ADService().interstitialUnitId2
  );
  InterstitialAdService videoPlayINTAdService = InterstitialAdService(
    TESTInterstitialVideoUnitId,
    // kDebugMode
    //   ? ADService().TESTInterstitialVideoUnitId
    //   : ADService().interstitialUnitId3
  );

  preloadAds() {
    indexINTAdService.load(null);
    historyINTAdService.load(null);
    videoPlayINTAdService.load(null);
    appOpenAdManager.loadAd();

    // historyINTAdService =
    //     InterstitialAdService(ADService().TESTInterstitialVideoUnitId
    //         // kDebugMode
    //         //   ? ADService().TESTInterstitialVideoUnitId
    //         //   : ADService().interstitialUnitId2
    //         )
    //       ..load(null);

    // videoPlayINTAdService =
    //     InterstitialAdService(ADService().TESTInterstitialVideoUnitId
    //         // kDebugMode
    //         //   ? ADService().TESTInterstitialVideoUnitId
    //         //   : ADService().interstitialUnitId3
    //         )
    //       ..load(null);
  }
}
