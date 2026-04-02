import 'package:tag_links/core/locate/app_lang.dart';

class TranslatesErrors {
  const TranslatesErrors();
  
  final String notOpenLink = 'notOpenLink';
  final String openLink = 'errorOpenLink';

  static const Map<String, Map<AppLang, String>> translations = {
    'notOpenLink': {
      AppLang.es: 'No se encontró una app para abrir este enlace',
      AppLang.en: 'No app found to open this link',
    },
    'errorOpenLink': {
      AppLang.es: 'URL no válida o mal formada',
      AppLang.en: 'Invalid or malformed URL',
    },
  };
}