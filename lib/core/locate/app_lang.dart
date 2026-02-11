import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/locate/translations.dart';
import 'package:tag_links/state/lang_provider.dart';

enum AppLang { es, en }

extension AppLangX on AppLang {
  String get label {
    switch (this) {
      case AppLang.es:
        return 'Español';
      case AppLang.en:
        return 'English';
    }
  }
}

String t(WidgetRef ref, String key, {String fallback = ''}) {
  final lang = ref.watch(langProvider);

  return translations[key]?[lang] ?? translations[key]?[AppLang.es] ?? fallback;
}
