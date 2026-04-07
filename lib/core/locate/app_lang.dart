enum AppLang { es, en }

extension AppLangX on AppLang {
  // 1. El nombre que el usuario ve en la configuración
  String get label {
    switch (this) {
      case AppLang.es:
        return 'Español';
      case AppLang.en:
        return 'English';
      // Agrega aquí los nuevos idiomas conforme crezca tu app
    }
  }

  // 2. El código ISO que devuelve el sistema (Android/iOS)
  String get isoCode {
    switch (this) {
      case AppLang.es:
        return 'es';
      case AppLang.en:
        return 'en';
    }
  }

  // 3. Método estático para convertir un código de sistema a tu Enum
  static AppLang fromSystemCode(String code) {
    // Tomamos solo los primeros 2 caracteres por si viene 'es_MX' o 'en_US'
    final cleanCode = code.split('_')[0].toLowerCase();

    return AppLang.values.firstWhere(
      (lang) => lang.isoCode == cleanCode,
      orElse: () => AppLang.en, // Idioma por defecto si no lo soportas
    );
  }
}
