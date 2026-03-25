import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tag_links/data/shared_prefs_provider.dart';

// 2. Tu clase chiquita ahora DEPENDE del provider anterior
final premiumLocalDataSourceProvider = Provider<PremiumLocalDataSource>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return PremiumLocalDataSource(prefs);
});

class PremiumLocalDataSource {
  static const _prefKey = 'is_premium_user';
  final SharedPreferences _prefs;

  PremiumLocalDataSource(this._prefs);

  /// Obtiene el estado guardado (false por defecto si no existe)
  bool getIsPremium() {
    return _prefs.getBool(_prefKey) ?? false;
  }

  /// Guarda el nuevo estado
  Future<void> setIsPremium(bool value) async {
    await _prefs.setBool(_prefKey, value);
  }
}
