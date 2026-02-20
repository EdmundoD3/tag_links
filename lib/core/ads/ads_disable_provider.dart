import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tag_links/core/app_purchases/premium_provider.dart';

final isAdsActiveProvider = Provider<bool>((ref) {
  final isPremium = ref.watch(premiumProvider);
  if (isPremium == true) return false;

  final asyncValue = ref.watch(adsDisabledUntilProvider);

  return asyncValue.when(
    loading: () => false, // mientras carga no mostrar
    error: (_, __) => true, // si algo falla, mejor mostrar
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
  final _AdsStorage _storage = _AdsStorage();

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

class _AdsStorage {
  static const _key = 'ads_disabled_until';

  Future<void> saveDisabledUntil(DateTime until) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, until.millisecondsSinceEpoch);
  }

  Future<DateTime?> getDisabledUntil() async {
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
