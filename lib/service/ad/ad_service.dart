import 'dart:io';

import 'package:top_one/service/ad/interstitial_ad_service.dart';
import 'package:top_one/tool/logger.dart';
import 'package:top_one/tool/time.dart';

class ADService {
  ADService._internal();
  static final ADService _instance = ADService._internal();
  factory ADService() => _instance;

  /// index
  final String bannderUnitId1 = Platform.isAndroid
      ? 'ca-app-pub-3945813041461839/2193047326'
      : "ca-app-pub-3945813041461839/2193047326";

  /// history
  final String bannderUnitId2 = Platform.isAndroid
      ? 'ca-app-pub-3945813041461839/5675667770'
      : "ca-app-pub-3945813041461839/5675667770";

  final String appOpenUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/3419835294'
      : 'ca-app-pub-3940256099942544/3419835294';

  final String interstitialUnitId1 = Platform.isAndroid
      ? 'ca-app-pub-3945813041461839/6643428221'
      : 'ca-app-pub-3945813041461839/6643428221';
  final String interstitialUnitId2 = Platform.isAndroid
      ? 'ca-app-pub-3945813041461839/8084771905'
      : 'ca-app-pub-3945813041461839/8084771905';

  final String interstitialUnitId3 = Platform.isAndroid
      ? 'ca-app-pub-3945813041461839/6941482138'
      : 'ca-app-pub-3945813041461839/6941482138';

  final String nativeUnitId = Platform.isAndroid
      ? 'ca-app-pub-3945813041461839/5869672103'
      : 'ca-app-pub-3945813041461839/5869672103';

  /// 开屏广告
  final String TESTAppOpenUnitId = "ca-app-pub-3940256099942544/5662855259";

  /// 横幅广告
  final String TESTBannerUnitId = "ca-app-pub-3940256099942544/2934735716";

  /// 插页式广告
  final String TESTInterstitialUnitId =
      "ca-app-pub-3940256099942544/4411468910";

  /// 插页式视频广告
  final String TESTInterstitialVideoUnitId =
      "ca-app-pub-3940256099942544/5135589807";

  /// 激励广告
  final String TESTRewardUnitId = "ca-app-pub-3940256099942544/1712485313";

  /// 插页式激励广告
  final String TESTInterstitialRewardUnitId =
      "ca-app-pub-3940256099942544/6978759866";

  /// 原生高级广告
  final String TESTNativeUnitId = "ca-app-pub-3940256099942544/3986624511";

  /// 原生高级视频广告
  final String TESTNativeVideoUnitId = "ca-app-pub-3940256099942544/2521693316";

  int latestInterstitialAdShowTime = 0;
  updateLatestInterstitialAdShowTime() {
    latestInterstitialAdShowTime = currentTimestamp();
  }

  bool shouldShowInterstitialAd() {
    final offset = currentTimestamp() - latestInterstitialAdShowTime;
    logDebug("shouldShowInterstitialAd offset: $offset");
    return offset > 60;
  }

  InterstitialAdService? indexINTAdService;
  InterstitialAdService? historyINTAdService;
  InterstitialAdService? videoPlayINTAdService;

  preloadAds() {
    indexINTAdService = InterstitialAdService(
      ADService().TESTInterstitialVideoUnitId,
      // kDebugMode
      //   ? ADService().TESTInterstitialVideoUnitId
      //   : ADService().interstitialUnitId1
    )..load(null);

    historyINTAdService =
        InterstitialAdService(ADService().TESTInterstitialVideoUnitId
            // kDebugMode
            //   ? ADService().TESTInterstitialVideoUnitId
            //   : ADService().interstitialUnitId2
            )
          ..load(null);

    videoPlayINTAdService =
        InterstitialAdService(ADService().TESTInterstitialVideoUnitId
            // kDebugMode
            //   ? ADService().TESTInterstitialVideoUnitId
            //   : ADService().interstitialUnitId3
            )
          ..load(null);
  }
}
