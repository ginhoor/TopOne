import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:gh_tool_package/log/logger.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:top_one/service/ad/ad_service.dart';

class InlineADService {
  AdManagerBannerAd? ad;
  String adUnitId;
  AdSize size;
  AdSize? resultSize;

  Function(AdManagerBannerAd?)? onAdLoaded;
  int retryCount = 0;

  StreamSubscription<ConnectivityResult>? networksOB;

  InlineADService(this.adUnitId,
      {this.onAdLoaded, this.size = AdSize.mediumRectangle}) {
    networksOB = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result != ConnectivityResult.none) {
        if (ad == null) {
          retryCount = 0;
          load();
        }
      }
    });
  }

  Widget adWidget() {
    if (disableAD) {
      return Container();
    }

    if (ad != null && resultSize != null) {
      return SizedBox(
          width: resultSize!.width.toDouble(),
          height: resultSize!.height.toDouble(),
          child: AdWidget(ad: ad!));
    } else {
      return Container();
    }
  }

  void dispose() {
    networksOB?.cancel();
    ad?.dispose();
  }

  Future<void> load() async {
    await AdManagerBannerAd(
      adUnitId: adUnitId,
      sizes: [size],
      request: const AdManagerAdRequest(),
      listener: AdManagerBannerAdListener(
        onAdLoaded: (Ad ad) async {
          logDebug('$AdManagerBannerAd Inline adaptive banner loaded');

          // logDebug(
          //     '$AdManagerBannerAd Inline adaptive banner loaded: ${ad.responseInfo}');
          AdManagerBannerAd bannerAd = ad as AdManagerBannerAd;
          final AdSize? size = await bannerAd.getPlatformAdSize();
          if (size == null) {
            logDebug(
                '$AdManagerBannerAd Error: getPlatformAdSize() returned null for $bannerAd');
            return;
          }
          this.ad = ad;
          resultSize = size;

          if (onAdLoaded != null) onAdLoaded!(ad);
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          logDebug(
              '$AdManagerBannerAd Inline adaptive banner failedToLoad: $error');
          ad.dispose();
          handleRetry(adUnitId);
        },
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
