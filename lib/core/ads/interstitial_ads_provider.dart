import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tag_links/core/ads/ad_mob_config.dart';
import 'package:tag_links/core/ads/ads_disable_provider.dart';
import 'package:tag_links/core/app_purchases/premium_provider.dart';

final showInterstitialAdsProvider = Provider<bool>((ref) {
  final isPremium = ref.watch(premiumNotifierProvider);
  if (isPremium) return false;

  final adsActivas = ref.watch(isAdsActiveProvider);
  if (!adsActivas) return false;

  final nextAllowed = ref.watch(interstitialAdsProvider);
  
  // Si aún está cargando el SharedPreferences, no permitimos mostrar
  if (nextAllowed == null) return false;

  return DateTime.now().isAfter(nextAllowed);
});

final interstitialAdsProvider =
    NotifierProvider<InterstitialAdsNotifier, DateTime?>(
      InterstitialAdsNotifier.new,
    );

class InterstitialAdsNotifier extends Notifier<DateTime?> {
  final _storage = _InterstitialAdsStorage();

  static const int _cooldownDays = AdMobConfig.interstitialAdUnitDays;

@override
  DateTime? build() {
    // Iniciamos con una fecha lejana para bloquear anuncios mientras carga el disco
    final loadingLock = DateTime.now().add(const Duration(days: 365));
    
    // Usamos microtask para no bloquear el renderizado inicial
    Future.microtask(() => _load()); 
    
    return loadingLock; 
  }

  Future<void> _load() async {
    try {
      final stored = await _storage.getLastShown();
      if (stored != null) {
        state = stored;
      } else {
        // Usuario nuevo: 2 días de gracia
        final firstDelay = DateTime.now().add(const Duration(days: 2));
        await _storage.saveLastShown(firstDelay);
        state = firstDelay; // Actualizamos el estado al final
      }
    } catch (e) {
      debugPrint("Error cargando ads storage: $e");
      // En caso de error, mantenemos el bloqueo o ponemos una fecha segura
      state = DateTime.now().add(const Duration(days: 1));
    }
  }

  /// Verifica si ya puede mostrarse la ad

  Future<void> registerAdShown() async {
    final nextAllowed = DateTime.now().add(Duration(days: _cooldownDays));

    state = nextAllowed;
    await _storage.saveLastShown(nextAllowed);
  }

  bool get canShowAd {
    if (state == null) return true;
    return DateTime.now().isAfter(state!);
  }

  /// Reset manual (debug/testing)
  Future<void> reset() async {
    state = null;
    await _storage.clear();
  }
}

class _InterstitialAdsStorage {
  static const _key = 'interstitial_last_shown';

  Future<void> saveLastShown(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, date.millisecondsSinceEpoch);
  }

  Future<DateTime?> getLastShown() async {
    final prefs = await SharedPreferences.getInstance();
    final ms = prefs.getInt(_key);
    if (ms == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
