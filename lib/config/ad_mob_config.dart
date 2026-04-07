// lib/ui/ads/ad_mob_config.dart
import 'package:flutter/foundation.dart';

class AdMobConfig {
  static const bannerAdUnitId = kReleaseMode
      ? 'ca-app-pub-9608093026390913/2291028168'
      : 'ca-app-pub-3940256099942544/6300978111'; // test banner

  static const interstitialAdUnitId = kReleaseMode
      ? 'ca-app-pub-9608093026390913/1104375901'
      : 'ca-app-pub-3940256099942544/1033173712'; // test interstitial oficial de Google

  static const interstitialAdUnitDays = 2;

  static const rewardedAdUnitId = kReleaseMode
      ? 'ca-app-pub-9608093026390913/5043620910'
      : 'ca-app-pub-3940256099942544/5224354917'; // test rewarded
}

// en https://admob.google.com/home/

// 2. Registrar tu app
// En el menú → Apps
// Click en “Agregar app”
// Puedes agregarla aunque no esté publicada aún

// 3. Crear unidades de anuncio

// Dentro de tu app:

// Ve a Ad units (Unidades de anuncio)
// Click en “Agregar unidad de anuncio”
// Elige tipo:
// Banner
// Interstitial
// Rewarded