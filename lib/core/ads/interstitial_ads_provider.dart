import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tag_links/core/ads/ad_mob_config.dart';
import 'package:tag_links/core/app_purchases/premium_provider.dart';

final showInterstitialAdsProvider = Provider<bool>((ref) {
  final isPremium = ref.watch(premiumProvider);
  if (isPremium == true) return false;

  final nextAllowed = ref.watch(interstitialAdsProvider);

  if (nextAllowed == null) return false; // aún cargando

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
    _load();
    return null;
  }
  
  Future<void> _load() async {
    final stored = await _storage.getLastShown();

    if (stored == null) {
      // Primera vez que usa la app
      final firstDelay = DateTime.now().add(const Duration(days: 2));
      state = firstDelay;
      await _storage.saveLastShown(firstDelay);
    } else {
      state = stored;
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
