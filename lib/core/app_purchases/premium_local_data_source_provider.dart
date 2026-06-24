import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tag_links/data/shared_prefs_provider.dart';

final premiumLocalDataSourceProvider = Provider<PremiumLocalDataSource>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return PremiumLocalDataSource(prefs);
});

class PremiumLocalDataSource {
  static const _prefKey = 'is_premium_user';
  static const _lastRestoreKey = 'last_restore';

  final SharedPreferences _prefs;

  PremiumLocalDataSource(this._prefs);

  bool getIsPremium() {
    return _prefs.getBool(_prefKey) ?? false;
  }

  Future<void> setIsPremium(bool value) async {
    await _prefs.setBool(_prefKey, value);
  }

  int getLastRestore() {
    return _prefs.getInt(_lastRestoreKey) ?? 0;
  }

  Future<void> setLastRestore(int timestamp) async {
    await _prefs.setInt(_lastRestoreKey, timestamp);
  }
}
