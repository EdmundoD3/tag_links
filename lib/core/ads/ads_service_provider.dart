import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tag_links/config/ad_mob_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdService {
  // --- Rewarded Ads ---
  RewardedAd? _rewardedAd;
  bool _isRewardedLoading = false;

  // --- Interstitial Ads ---
  InterstitialAd? _interstitialAd;
  bool _isInterstitialLoading = false;
  bool _isShowingAd = false;

  // ================= REWARDED LOGIC =================
  Future<bool> showRewardedAd() async {
    if (_isShowingAd) {
      debugPrint('Ya existe un anuncio fullscreen activo');
      return false;
    }

    if (_rewardedAd == null) {
      loadRewardedAd();
      return false;
    }

    _isShowingAd = true;

    final completer = Completer<bool>();

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _resetRewardedAd();

        if (!completer.isCompleted) {
          completer.complete(false);
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _resetRewardedAd();

        if (!completer.isCompleted) {
          completer.complete(false);
        }
      },
    );

    try {
      _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          if (!completer.isCompleted) {
            completer.complete(true);
          }
        },
      );
    } catch (e) {
      _resetRewardedAd();

      if (!completer.isCompleted) {
        completer.complete(false);
      }

      debugPrint('Error mostrando rewarded: $e');
    }

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
    if (_isShowingAd) {
      debugPrint('Ya existe un anuncio fullscreen activo');
      return;
    }

    if (_interstitialAd == null) {
      loadInterstitialAd();
      onAdClosed();
      return;
    }

    _isShowingAd = true;

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _resetInterstitialAd();
        onAdClosed();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _resetInterstitialAd();
        onAdClosed();
      },
    );

    try {
      _interstitialAd!.show();
    } catch (e) {
      _resetInterstitialAd();

      debugPrint('Error mostrando interstitial: $e');

      onAdClosed();
    }
  }

  // Agrega este método a tu clase AdService:
  void disposeAll() {
    _rewardedAd?.dispose();
    _interstitialAd?.dispose();

    _rewardedAd = null;
    _interstitialAd = null;

    _isRewardedLoading = false;
    _isInterstitialLoading = false;
    _isShowingAd = false;

    debugPrint('AdService: Ads liberadas correctamente.');
  }

  void _resetRewardedAd() {
    _resetShowingState();

    _rewardedAd?.dispose();
    _rewardedAd = null;

    loadRewardedAd();
  }

  void _resetInterstitialAd() {
    _resetShowingState();

    _interstitialAd?.dispose();
    _interstitialAd = null;

    loadInterstitialAd();
  }

  void _resetShowingState() {
    _isShowingAd = false;
  }

  bool get isShowingAd => _isShowingAd;
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
