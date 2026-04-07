// lib/core/locate/modules/ads_translate.dart
import '../app_lang.dart';

class TranslatesAds {
  const TranslatesAds();

  // --- Feedback de recompensas ---
  /// ES: "¡Gracias!"
  final String thanksReward = 'thanksForRewardedAd';

  /// ES: "Error al mostrar el anuncio, inténtalo de nuevo más tarde."
  final String errorShowing = 'errorForRewardedAd';

  // --- Modal de gestión de Ads ---
  /// ES: "¿Te estorba la publicidad?"
  final String disableTitle = 'modalDisableAdsTitle';

  /// ES: "Puedes quitar los anuncios viendo un video..."
  final String disableSubtitle = 'modalDisableAdsSubtitle';
  final String remove24h = 'removeAds24h';

  /// ES: "Tal vez luego"
  final String maybeLater = 'maybeLater';

  // --- Apoyo al proyecto ---
  /// ES: '¿Te gusta la app? \n Compártela o apóyanos',
  final String supportTitle = 'supportProject';

  /// ES: 'Ver un anuncio grande'
  final String viewLargeAd = 'viewLargeAd';
  final String disabledForOneDay = 'disableAdsForOneDay';
  final String thanksForUsing = 'thanksForUsingApp';

  // --- Café (Donaciones) ---
  final String buyCoffee = 'buyMeCoffee';
  final String buyCoffeeDesc = 'buyMeCoffeeDescription';

  static const Map<String, Map<AppLang, String>> translations = {
    'thanksForRewardedAd': {AppLang.es: 'Gracias!', AppLang.en: 'Thank you!'},
    'errorForRewardedAd': {
      AppLang.es: 'Error al mostrar el anuncio, inténtalo de nuevo más tarde.',
      AppLang.en: 'Error showing ad, try again later.',
    },
    'modalDisableAdsTitle': {
      AppLang.es: '¿Quieres quitar la publicidad?',
      AppLang.en: 'Want to remove ads?',
    },
    'modalDisableAdsSubtitle': {
      AppLang.es:
          'Puedes quitar los anuncios viendo un video o apoyar el proyecto',
      AppLang.en:
          'You can remove ads by watching a short video or supporting the project.',
    },
    'removeAds24h': {
      AppLang.es: 'Quitar anuncios por 24h',
      AppLang.en: 'Remove ads for 24 hours',
    },
    'maybeLater': {AppLang.es: 'Tal vez luego', AppLang.en: 'Maybe later'},
    'supportProject': {
      AppLang.es: '¿Te gusta la app? \n Compártela o apóyanos',
      AppLang.en: 'Enjoying the app? \n Share or support us',
    },
    'viewLargeAd': {
      AppLang.es: 'Ver un anuncio grande',
      AppLang.en: 'View a large ad',
    },
    'disableAdsForOneDay': {
      AppLang.es: 'Se desactivará por un día la publicidad',
      AppLang.en: 'The ad will be disabled for one day',
    },
    'thanksForUsingApp': {
      AppLang.es: '¡Gracias por usar la App!',
      AppLang.en: 'Thank you for using the App!',
    },
    'buyMeCoffee': {
      AppLang.es: 'Invítame un café',
      AppLang.en: 'Buy me a coffee',
    },
    'buyMeCoffeeDescription': {
      AppLang.es:
          'Si te gusta la app, invítame un café para apoyar el proyecto',
      AppLang.en:
          'If you like the app, buy me a coffee to support the project.',
    },
  };
}
