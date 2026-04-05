import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tag_links/core/app_purchases/premium_provider.dart';
import 'package:tag_links/data/shared_prefs_provider.dart';

final isAdsActiveProvider = Provider<bool>((ref) {
  final isPremium = ref.watch(premiumStatusProvider);
  debugPrint('isPremium: $isPremium');
  if (isPremium == true) return false;

  final asyncValue = ref.watch(adsDisabledUntilProvider);

  return asyncValue.when(
    loading: () => false, // mientras carga no mostrar
    error: (_, _) => true, // si algo falla, mejor mostrar
    data: (disabledUntil) {
      if (disabledUntil == null) return true;
      return DateTime.now().isAfter(disabledUntil);
    },
  );
});

final adsDisabledUntilProvider =
    AsyncNotifierProvider<AdsDisabledNotifier, DateTime?>(
      AdsDisabledNotifier.new,
    );

class AdsDisabledNotifier extends AsyncNotifier<DateTime?> {
  _AdsStorage get _storage  => ref.watch(adsStorageProvider);

  @override
  Future<DateTime?> build() async {
    final stored = await _storage.getDisabledUntil();

    if (stored != null && DateTime.now().isAfter(stored)) {
      await _storage.clear();
      return null;
    }

    return stored;
  }

  Future<void> disableForHours(int hours) async {
    final until = DateTime.now().add(Duration(hours: hours));
    state = AsyncData(until);
    await _storage.saveDisabledUntil(until);
  }

  Future<void> enableAds() async {
    state = const AsyncData(null);
    await _storage.clear();
  }
  /// Reset manual (debug/testing)
  Future<void> reset() async {
    _storage.clear();
    state = const AsyncData(null);
  }
}

final adsStorageProvider = Provider((ref) {
  final prefs = ref.read(sharedPrefsProvider);
  return _AdsStorage(prefs);
});

class _AdsStorage {
  static const _key = 'ads_disabled_until';
  final SharedPreferences _prefs;
  _AdsStorage(this._prefs);

  Future<void> saveDisabledUntil(DateTime until) async {
    await _prefs.setInt(_key, until.millisecondsSinceEpoch);
  }

  Future<DateTime?> getDisabledUntil() async {
    final ms = _prefs.getInt(_key);
    if (ms == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<void> clear() async {
    await _prefs.remove(_key);
  }
}
