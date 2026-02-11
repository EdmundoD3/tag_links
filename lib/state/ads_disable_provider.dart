import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tag_links/state/premium_provider.dart';

final isAdsActiveProvider = Provider<bool?>((ref) {
  final isPremium = ref.watch(premiumProvider);
  if (isPremium == true) return false;

  final disabledUntil = ref.watch(adsDisabledUntilProvider);
  if (disabledUntil == null) return true;

  return DateTime.now().isAfter(disabledUntil);
});
final adsDisabledUntilProvider =
    NotifierProvider<AdsDisabledNotifier, DateTime?>(
  AdsDisabledNotifier.new,
);

class AdsDisabledNotifier extends Notifier<DateTime?> {
  final _AdsStorage _storage = _AdsStorage();

  @override
  DateTime? build() {
    _load();
    return null; // loading
  }

  Future<void> _load() async {
    final stored = await _storage.getDisabledUntil();

    if (stored != null && DateTime.now().isAfter(stored)) {
      // Ya expiró → limpiamos
      state = null;
      await _storage.clear();
    } else {
      state = stored;
    }
  }

  /// Desactiva ads por X horas
  Future<void> disableForHours(int hours) async {
    final until = DateTime.now().add(Duration(hours: hours));
    state = until;
    await _storage.saveDisabledUntil(until);
  }

  /// Fuerza reactivar ads
  Future<void> enableAds() async {
    state = null;
    await _storage.clear();
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
