// lib/ui/ads/ad_mob_config.dart
import 'package:flutter/foundation.dart';

class AdMobConfig {
  static const bannerAdUnitId = kReleaseMode
      ? 'ca-app-pub-TU_ID_REAL/BANNER_ID'
      : 'ca-app-pub-3940256099942544/6300978111'; // test banner

  static const interstitialAdUnitId = kReleaseMode
      ? 'ca-app-pub-TU_ID_REAL/INTERSTICIAL_ID'
      : 'ca-app-pub-3940256099942544/1033173712'; // test interstitial oficial de Google

  static const interstitialAdUnitDays = 2;

  static const rewardedAdUnitId = kReleaseMode
      ? 'ca-app-pub-TU_ID_REAL/XXXXXXXX'
      : 'ca-app-pub-3940256099942544/5224354917'; // test rewarded
}
