import 'package:google_mobile_ads/google_mobile_ads.dart';

class NativeADService {
  static NativeAd? ad;
  // static String adUnitId =
  //     Platform.isAndroid ? 'ca-app-pub-3945813041461839/5869672103' : '';

  static String adUnitId = 'ca-app-pub-3945813041461839/5869672103';

  // Widget? adWidget() {
  //   if (ad != null) return AdWidget(ad: ad!);
  //   return null;
  // }

  // void dispose() {
  //   ad?.dispose();
  // }

  // void load(Function() onAdLoaded) {
  //   NativeAd(
  //     adUnitId: adUnitId,
  //     request: const AdRequest(),
  //     listener: NativeAdListener(
  //       onAdLoaded: (Ad ad) {
  //         this.ad = ad as NativeAd;
  //         onAdLoaded();
  //       },
  //       onAdFailedToLoad: (Ad ad, LoadAdError error) {
  //         ad.dispose();
  //       },
  //       onAdOpened: (Ad ad) => logDebug('$NativeAd onAdOpened.'),
  //       onAdClosed: (Ad ad) => logDebug('$NativeAd onAdClosed.'),
  //     ),
  //     factoryId: 'adFactoryExample',
  //   ).load();
  // }
}
