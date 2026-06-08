enum AppLang {
  es,
  en,
  de,
  pt,
  fr,
  ru,
  ja,
  zh,
}

extension AppLangX on AppLang {
  String get label {
    switch (this) {
      case AppLang.es:
        return 'Español';
      case AppLang.en:
        return 'English';
      case AppLang.de:
        return 'Deutsch';
      case AppLang.pt:
        return 'Português';
      case AppLang.fr:
        return 'Français';
      case AppLang.ru:
        return 'Русский';
      case AppLang.ja:
        return '日本語';
      case AppLang.zh:
        return '中文';
    }
  }

  String get isoCode {
    switch (this) {
      case AppLang.es:
        return 'es';
      case AppLang.en:
        return 'en';
      case AppLang.de:
        return 'de';
      case AppLang.pt:
        return 'pt';
      case AppLang.fr:
        return 'fr';
      case AppLang.ru:
        return 'ru';
      case AppLang.ja:
        return 'ja';
      case AppLang.zh:
        return 'zh';
    }
  }

  String get emoji {
    switch (this) {
      case AppLang.es:
        return '🇪🇸';
      case AppLang.en:
        return '🇺🇸';
      case AppLang.de:
        return '🇩🇪';
      case AppLang.pt:
        return '🇧🇷';
      case AppLang.fr:
        return '🇫🇷';
      case AppLang.ru:
        return '🇷🇺';
      case AppLang.ja:
        return '🇯🇵';
      case AppLang.zh:
        return '🇨🇳';
    }
  }

  static AppLang fromSystemCode(String code) {
    final cleanCode = code.split('_')[0].toLowerCase();

    return AppLang.values.firstWhere(
      (lang) => lang.isoCode == cleanCode,
      orElse: () => AppLang.en,
    );
  }
}