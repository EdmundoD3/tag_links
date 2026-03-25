import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tag_links/core/locate/app_lang.dart';
import 'package:tag_links/data/shared_prefs_provider.dart';

// --- El Provider ---
final langProvider = NotifierProvider<LangNotifier, AppLang>(LangNotifier.new);

class LangNotifier extends Notifier<AppLang> {
  // Ya no necesitamos _load() asíncrono, lo hacemos todo en el build
  _LangStorage get _storage => ref.watch(_langStorageProvider);

  @override
  AppLang build() {
    // 1. Obtenemos la instancia global ya inicializada
    final savedValue = _storage.load();

    if (savedValue != null) {
      // 2. Si hay algo guardado, lo devolvemos de inmediato
      return AppLang.values.firstWhere(
        (e) => e.name == savedValue,
        orElse: () => AppLang.en,
      );
    } else {
      // 3. Primera vez: detectamos sistema
      final systemCode = PlatformDispatcher.instance.locale.languageCode;
      final detected = AppLangX.fromSystemCode(systemCode);
      
      // Guardamos para la próxima vez (fuego y olvido, no bloqueamos el build)
      _storage.save(detected);
      
      return detected;
    }
  }

  void set(AppLang lang) {
    state = lang;
    // Obtenemos la instancia para guardar
    _storage.save(lang);
  }
}

// --- El Almacenamiento ---
final _langStorageProvider = Provider((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return _LangStorage(prefs);
});

class _LangStorage {
  static const String _key = 'lang_preferences';
  final SharedPreferences _pref;
  
  _LangStorage(this._pref);

  // Guardar sigue siendo Future porque impacta el disco
  Future<void> save(AppLang lang) async {
    await _pref.setString(_key, lang.name);
  }

  // Leer ahora es sincrónico (instantáneo)
  String? load() {
    return _pref.getString(_key);
  }
}