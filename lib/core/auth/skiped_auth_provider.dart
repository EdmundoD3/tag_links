import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tag_links/data/shared_prefs_provider.dart';

final skipedAuthProvider = Provider<SkipedAuthProvider>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return SkipedAuthProvider(prefs);
});

class SkipedAuthProvider {
  static const String _key = 'skiped_auth';
  final SharedPreferences _prefs;

  SkipedAuthProvider(this._prefs);

  /// IDENTIDAD DEL DISPOSITIVO
  /// Siempre debe existir. Si no está, se crea. 
  /// Es la "matrícula" de este teléfono.
  bool? getHasSkippedAuth() {
    return _prefs.getBool(_key);
  }

  Future<void> saveHasSkippedAuth(bool hasSkippedAuth ) async {
    await _prefs.setBool(_key, hasSkippedAuth);
  }

  Future<void> clear() async {
    await _prefs.remove(_key);
  }
}