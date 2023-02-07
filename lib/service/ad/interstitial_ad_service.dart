import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:top_one/tool/logger.dart';

class InterstitialAdService {
  InterstitialAd? ad;
  String adUnitId1 =
      Platform.isAndroid ? 'ca-app-pub-3945813041461839/6643428221' : '';
  String adUnitId2 =
      Platform.isAndroid ? 'ca-app-pub-3945813041461839/8084771905' : '';
  String currentId = "";
  void show() async {
    if (ad != null) {
      ad!.show();
    } else {
      if (currentId.isNotEmpty) {
        load(currentId);
      }
    }
  }

  void dispose() {
    ad?.dispose();
  }

  Future<void> load(String adUnitId) async {
    currentId = adUnitId;
    await InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        // Called when an ad is successfully received.
        onAdLoaded: (InterstitialAd ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
              // Called when the ad showed the full screen content.
              onAdShowedFullScreenContent: (ad) {},
              // Called when an impression occurs on the ad.
              onAdImpression: (ad) {},
              // Called when the ad failed to show full screen content.
              onAdFailedToShowFullScreenContent: (ad, err) {
                ad.dispose();
              },
              // Called when the ad dismissed full screen content.
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
              },
              // Called when a click is recorded for an ad.
              onAdClicked: (ad) {});

          // Keep a reference to the ad so you can show it later.
          this.ad = ad;
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (LoadAdError error) {
          // ignore: avoid_print
          logDebug('$InterstitialAd failed to load: $error');
        },
      ),
    );
  }
}
