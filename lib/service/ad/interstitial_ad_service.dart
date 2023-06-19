import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_tool_kit/log/logger.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:top_one/service/ad/ad_service.dart';

class InterstitialAdService {
  InterstitialAd? ad;
  String adUnitId;
  bool showing = false;

  Function(InterstitialAd?)? onAdLoaded;
  Function(InterstitialAd?)? onAdClicked;
  int retryCount = 0;
  StreamSubscription<ConnectivityResult>? networksOB;
  InterstitialAdService(this.adUnitId, {this.onAdLoaded, this.onAdClicked}) {
    networksOB = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result != ConnectivityResult.none) {
        if (ad == null) {
          retryCount = 0;
          load((p0) => null);
        }
      }
    });
  }

  void show(Function(InterstitialAd?)? completion) async {
    if (!ADService().enable) {
      if (completion != null) completion(null);
      return;
    }
    if (!ADService().shouldShowInterstitialAd()) {
      if (completion != null) completion(ad);
      return;
    }
    if (ad != null) {
      await ad!.show();
      ADService().updateLatestInterstitialAdShowTime();
      if (completion != null) completion(ad!);
    } else {
      load((ad) {});
      if (completion != null) completion(null);
    }
  }

  void dispose() {
    ad?.dispose();
  }

  Future<void> load(Function(InterstitialAd?)? completion) async {
    await InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        // Called when an ad is successfully received.
        onAdLoaded: (InterstitialAd ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
              // Called when the ad showed the full screen content.
              onAdShowedFullScreenContent: (ad) {
                showing = true;
              },
              // Called when an impression occurs on the ad.
              onAdImpression: (ad) {},
              // Called when the ad failed to show full screen content.
              onAdFailedToShowFullScreenContent: (ad, err) {
                showing = false;
                ad.dispose();
                this.ad = null;
              },
              // Called when the ad dismissed full screen content.
              onAdDismissedFullScreenContent: (ad) {
                showing = false;
                ad.dispose();
                this.ad = null;
                load((p0) => null);
              },
              // Called when a click is recorded for an ad.
              onAdClicked: (ad) {
                if (onAdClicked != null) onAdClicked!(ad);
              });

          // Keep a reference to the ad so you can show it later.
          this.ad = ad;
          if (onAdLoaded != null) onAdLoaded!(ad);

          retryCount = 0;
          if (completion != null) completion(ad);
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (LoadAdError error) {
          // ignore: avoid_print
          logDebug('$InterstitialAd failed to load: $error');
          handleRetry(adUnitId, completion);
        },
      ),
    );
  }

  handleRetry(String adUnitId, Function(InterstitialAd?)? completion) {
    retryCount += 1;
    if (retryCount == 1) {
      load(completion);
    } else if (retryCount == 2) {
      Future.delayed(const Duration(seconds: 10), () {
        load(completion);
      });
    } else if (retryCount == 3) {
      Future.delayed(const Duration(seconds: 30), () {
        load(completion);
      });
    } else {
      if (completion != null) completion(null);
    }
  }
}
