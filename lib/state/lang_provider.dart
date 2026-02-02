import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tag_links/locate/app_lang.dart';

final langProvider = NotifierProvider<LangNotifier, AppLang>(LangNotifier.new);

class LangNotifier extends Notifier<AppLang> {
  final _storage = _LangStorage();

  @override
  AppLang build() {
    _load();
    return AppLang.en; // default
  }

  Future<void> _load() async {
    final lang = await _storage.load();
    state = lang;
  }

  void set(AppLang lang) {
    state = lang;
    _storage.save(lang);
  }
}

class _LangStorage {
  static const String _key = 'lang_preferences';

  Future<void> save(AppLang lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, lang.name);
  }

  Future<AppLang> load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);

    return AppLang.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AppLang.en,
    );
  }
}
