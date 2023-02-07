import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:top_one/tool/logger.dart';

class BannerADService {
  BannerAd? ad;
  String adUnitId =
      Platform.isAndroid ? 'ca-app-pub-3945813041461839/2193047326' : "";

  Widget? adWidget() {
    if (ad != null) return AdWidget(ad: ad!);

    return null;
  }

  void load() {
    BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          this.ad = ad as BannerAd;
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
        // Called when an ad opens an overlay that covers the screen.
        onAdOpened: (Ad ad) => logDebug('$BannerAd onAdOpened.'),
        // Called when an ad removes an overlay that covers the screen.
        onAdClosed: (Ad ad) => logDebug('$BannerAd onAdClosed.'),
        // Called when an impression occurs on the ad.
        onAdImpression: (Ad ad) {},
      ),
    ).load();
  }
}
