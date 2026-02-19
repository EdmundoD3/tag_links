import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tag_links/core/theme/app_theme.dart';

final paletteProvider =
    NotifierProvider<PaletteNotifier, AppPalette>(
  PaletteNotifier.new,
);

class PaletteNotifier extends Notifier<AppPalette> {
  final _storage = _PaletteStorage();

  @override
  AppPalette build() {
    _load();
    return AppPalette.light; // fallback inmediato
  }

  Future<void> _load() async {
    final palette = await _storage.load();
    state = palette;
  }

  Future<void> set(AppPalette palette) async {
    state = palette;
    await _storage.save(palette);
  }
}


class _PaletteStorage {
  static const String _key = 'palette_preferences';

  Future<void> save(AppPalette palette) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, palette.name);
  }

  Future<AppPalette> load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);

    return AppPalette.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AppPalette.light,
    );
  }
}
