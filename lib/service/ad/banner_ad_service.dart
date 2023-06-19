import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tool_kit/log/logger.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:top_one/service/ad/ad_service.dart';

class BannerADService {
  BannerAd? ad;
  String adUnitId;
  AdSize size;

  Function(BannerAd?)? onAdLoaded;
  int retryCount = 0;

  StreamSubscription<ConnectivityResult>? networksOB;

  BannerADService(this.adUnitId, {this.onAdLoaded, this.size = AdSize.mediumRectangle}) {
    networksOB = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result != ConnectivityResult.none) {
        if (ad == null) {
          retryCount = 0;
          load();
        }
      }
    });
  }

  Widget adWidget() {
    if (!ADService().enable) return Container();
    if (ad != null) {
      return SizedBox(
          width: (ad!.size.width).toDouble(), height: (ad!.size.height).toDouble(), child: AdWidget(ad: ad!));
    } else {
      return Container();
    }
  }

  void dispose() {
    networksOB?.cancel();
    ad?.dispose();
  }

  void load() async {
    await BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: size,
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          this.ad = ad as BannerAd;
          if (onAdLoaded != null) {
            onAdLoaded!(ad);
          }
          retryCount = 0;
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, err) {
          logDebug('$BannerAd onAdFailedToLoad: $err');
          ad.dispose();
          handleRetry(adUnitId);
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

  handleRetry(String adUnitId) {
    retryCount += 1;
    if (retryCount == 1) {
      load();
    } else if (retryCount == 2) {
      Future.delayed(const Duration(seconds: 10), () {
        load();
      });
    } else if (retryCount == 3) {
      Future.delayed(const Duration(seconds: 30), () {
        load();
      });
    }
  }
}
