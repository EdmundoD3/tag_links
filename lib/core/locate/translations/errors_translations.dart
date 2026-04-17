import 'package:tag_links/core/locate/app_lang.dart';

class TranslatesErrors {
  const TranslatesErrors();

  final String notOpenLink = 'notOpenLink';
  final String openLink = 'errorOpenLink';

  static const Map<String, Map<AppLang, String>> translations = {
    'notOpenLink': {
      AppLang.es: 'No se encontró una app para abrir este enlace',
      AppLang.en: 'No app found to open this link',
      AppLang.de: 'Keine App gefunden, um diesen Link zu öffnen',
      AppLang.pt: 'Nenhum aplicativo encontrado para abrir este link',
      AppLang.fr: "Aucune application trouvée pour ouvrir ce lien",
      AppLang.ru: 'Не найдено приложение для открытия этой ссылки',
      AppLang.ja: 'このリンクを開くアプリが見つかりません',
      AppLang.zh: '未找到可打开此链接的应用',
    },
    'errorOpenLink': {
      AppLang.es: 'URL no válida o mal formada',
      AppLang.en: 'Invalid or malformed URL',
      AppLang.de: 'Ungültige oder fehlerhafte URL',
      AppLang.pt: 'URL inválida ou malformada',
      AppLang.fr: 'URL invalide ou mal formée',
      AppLang.ru: 'Недействительный или некорректный URL',
      AppLang.ja: '無効または不正なURLです',
      AppLang.zh: 'URL 无效或格式错误',
    },
  };
}
