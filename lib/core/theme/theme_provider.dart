import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tag_links/core/theme/app_theme.dart';
import 'package:tag_links/data/shared_prefs_provider.dart';

// --- El Almacenamiento ---
final _paletteStorageProvider = Provider((ref) {
  final prefs = ref.read(sharedPrefsProvider);
  return _PaletteStorage(prefs);
});

// --- El Notifier ---
final paletteProvider = NotifierProvider<PaletteNotifier, AppPalette>(
  PaletteNotifier.new,
);

class PaletteNotifier extends Notifier<AppPalette> {
  @override
  AppPalette build() {
    // 1. Obtenemos el almacenamiento (que ya tiene las prefs del main)
    final storage = ref.watch(_paletteStorageProvider);

    // 2. Cargamos sincrónicamente.
    // Al retornar esto directamente, MyApp ya tiene el color correcto
    // desde el primer frame.
    return storage.load();
  }

  void set(AppPalette palette) {
    // 3. Actualizamos estado UI
    state = palette;

    // 4. Persistimos en disco (usando read por ser un evento)
    ref.read(_paletteStorageProvider).save(palette);
  }
}

class _PaletteStorage {
  static const String _key = 'palette_preferences';
  final SharedPreferences _prefs;

  _PaletteStorage(this._prefs);

  Future<void> save(AppPalette palette) async {
    await _prefs.setString(_key, palette.name);
  }

  AppPalette load() {
    final value = _prefs.getString(_key);
    return AppPalette.values.firstWhere(
      (e) => e.name == value,
      orElse: () => defaultTheme, // defaultTheme definido en app_theme.dart
    );
  }
}
