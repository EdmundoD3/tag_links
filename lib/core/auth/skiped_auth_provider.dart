import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/data/shared_prefs_provider.dart';


class SkipedAuthNotifier extends Notifier<bool?> {
  static const String _key = 'skiped_auth';

  @override
  bool? build() {
    // Leemos el valor inicial de SharedPreferences
    final prefs = ref.read(sharedPrefsProvider);
    return prefs.getBool(_key);
  }

  Future<void> saveHasSkippedAuth(bool value) async {
    final prefs = ref.read(sharedPrefsProvider);
    await prefs.setBool(_key, value);
    // 🚩 IMPORTANTE: Actualizamos el estado para que los watchers se enteren
    state = value;
  }

  Future<void> clear() async {
    final prefs = ref.read(sharedPrefsProvider);
    await prefs.remove(_key);
    state = null;
  }
}

// El provider ahora expone directamente el bool?
final skipedAuthProvider = NotifierProvider<SkipedAuthNotifier, bool?>(
  SkipedAuthNotifier.new,
);