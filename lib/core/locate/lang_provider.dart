import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tag_links/core/locate/app_lang.dart';

// --- El Provider ---
final langProvider = NotifierProvider<LangNotifier, AppLang>(LangNotifier.new);

class LangNotifier extends Notifier<AppLang> {
  final _storage = _LangStorage();

  @override
  AppLang build() {
    _load();
    return AppLang.en; // Estado inicial temporal
  }

  Future<void> _load() async {
    final savedValue = await _storage.load();

    if (savedValue != null) {
      // 1. Si hay algo guardado, lo usamos
      state = AppLang.values.firstWhere(
        (e) => e.name == savedValue,
        orElse: () => AppLang.en,
      );
    } else {
      // 2. Si es la primera vez (null), detectamos sistema
      final systemCode = PlatformDispatcher.instance.locale.languageCode;
      final detected = AppLangX.fromSystemCode(systemCode);
      
      state = detected;
      // Guardamos la detección para que la próxima vez entre por el IF
      await _storage.save(detected);
    }
  }

  void set(AppLang lang) {
    state = lang;
    _storage.save(lang);
  }
}

// --- El Almacenamiento (Más limpio) ---
class _LangStorage {
  static const String _key = 'lang_preferences';

  Future<void> save(AppLang lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, lang.name);
  }

  /// Retorna el string guardado o null si no existe
  Future<String?> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }
}