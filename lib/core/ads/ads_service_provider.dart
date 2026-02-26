// En tu archivo de providers
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tag_links/core/ads/ad_mob_config.dart';

class AdService {
  RewardedAd? _rewardedAd;
  bool _isLoading = false;

  // 1. Creamos un método para cargar el anuncio EN SILENCIO
  void loadRewardedAd() {
    if (_rewardedAd != null || _isLoading) return; // Si ya hay uno o está cargando, no hacer nada

    _isLoading = true;
    RewardedAd.load(
      adUnitId: AdMobConfig.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isLoading = false;
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          _isLoading = false;
        },
      ),
    );
  }

  // 2. Modificamos el método de mostrar para que sea instantáneo
  Future<bool> showRewardedAd() async {
    if (_rewardedAd == null) {
      loadRewardedAd(); // Intentar cargar uno para la próxima vez
      return false; // No había anuncio listo
    }

    final completer = Completer<bool>();

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd(); // ¡Cargamos el siguiente de una vez!
        if (!completer.isCompleted) completer.complete(false);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
        if (!completer.isCompleted) completer.complete(false);
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        if (!completer.isCompleted) completer.complete(true);
      },
    );

    return completer.future;
  }
}
final adServiceProvider = Provider((ref) => AdService());
