import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tag_links/core/ads/ad_mob_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdService {
  // --- Rewarded Ads ---
  RewardedAd? _rewardedAd;
  bool _isRewardedLoading = false;

  // --- Interstitial Ads ---
  InterstitialAd? _interstitialAd;
  bool _isInterstitialLoading = false;

  // ================= REWARDED LOGIC =================

  Future<bool> showRewardedAd() async {
    if (_rewardedAd == null) {
      loadRewardedAd();
      return false;
    }

    final completer = Completer<bool>();

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
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

  // En tu clase AdService...

void loadRewardedAd() {
  if (_rewardedAd != null || _isRewardedLoading) return;
  _isRewardedLoading = true;

  try {
    RewardedAd.load(
      adUnitId: AdMobConfig.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedLoading = false;
        },
        onAdFailedToLoad: (error) {
          _isRewardedLoading = false;
          _rewardedAd = null;
        },
      ),
    );
  } on Exception catch (e) {
    // Esto captura el error de "Ad already exists" y permite que la app siga viva
    _isRewardedLoading = false;
    debugPrint('AdMob HotRestart Shield (Rewarded): $e');
  }
}

// --- INTERSTITIAL ---
  void loadInterstitialAd() {
    if (_interstitialAd != null || _isInterstitialLoading) return;
    _isInterstitialLoading = true;

    try {
      InterstitialAd.load(
        adUnitId: AdMobConfig.interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            _isInterstitialLoading = false;
          },
          onAdFailedToLoad: (error) {
            _isInterstitialLoading = false;
            _interstitialAd = null;
          },
        ),
      );
    } catch (e) {
      _isInterstitialLoading = false;
      debugPrint("Prevented crash on Hot Restart: $e");
    }
  }

  /// Muestra el intersticial y ejecuta [onAdClosed] al terminar
  void showInterstitialAd({required VoidCallback onAdClosed}) {
    if (_interstitialAd == null) {
      loadInterstitialAd();
      onAdClosed(); // Si no hay anuncio, seguimos con la app
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        loadInterstitialAd(); // Pre-cargar el siguiente
        onAdClosed();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        loadInterstitialAd();
        onAdClosed();
      },
    );

    _interstitialAd!.show();
  }

// Agrega este método a tu clase AdService:
void disposeAll() {
  _rewardedAd?.dispose();
  _interstitialAd?.dispose();
  _rewardedAd = null;
  _interstitialAd = null;
  debugPrint('AdService: Ads liberadas correctamente.');
}
}

final adServiceProvider = Provider((ref) {
  final service = AdService();
  
  // 🔥 ESTO ES LO MÁS IMPORTANTE PARA EL HOT RESTART
  ref.onDispose(() {
    // Intentamos liberar los anuncios antes de que el estado de Dart se borre
    service.disposeAll(); 
  });
  
  return service;
});