// lib/core/locate/modules/ads_translate.dart
import '../app_lang.dart';

class TranslatesAds {
  const TranslatesAds();

  // --- Feedback de recompensas ---
  final String thanksReward = 'thanksForRewardedAd';

  final String errorShowing = 'errorForRewardedAd';

  // --- Modal de gestión de Ads ---
  final String disableTitle = 'modalDisableAdsTitle';

  final String disableSubtitle = 'modalDisableAdsSubtitle';
  final String remove24h = 'removeAds24h';

  final String maybeLater = 'maybeLater';

  // --- Apoyo al proyecto ---
  final String supportTitle = 'supportProject';

  final String viewLargeAd = 'viewLargeAd';
  final String disabledForOneDay = 'disableAdsForOneDay';
  final String thanksForUsing = 'thanksForUsingApp';

  // --- Café (Donaciones) ---
  final String buyCoffee = 'buyMeCoffee';
  final String buyCoffeeDesc = 'buyMeCoffeeDescription';

  static const Map<String, Map<AppLang, String>> translations = {
    'thanksForRewardedAd': {
      AppLang.es: 'Gracias!',
      AppLang.en: 'Thank you!',
      AppLang.de: 'Danke!',
      AppLang.pt: 'Obrigado!',
      AppLang.fr: 'Merci !',
    },
    'errorForRewardedAd': {
      AppLang.es: 'Error al mostrar el anuncio, inténtalo de nuevo más tarde.',
      AppLang.en: 'Error showing ad, try again later.',
      AppLang.de:
          'Fehler beim Anzeigen der Werbung. Bitte später erneut versuchen.',
      AppLang.pt: 'Erro ao exibir o anúncio, tente novamente mais tarde.',
      AppLang.fr:
          "Erreur lors de l'affichage de la publicité, réessayez plus tard.",
    },
    'modalDisableAdsTitle': {
      AppLang.es: '¿Quieres quitar la publicidad?',
      AppLang.en: 'Want to remove ads?',
      AppLang.de: 'Möchtest du die Werbung entfernen?',
      AppLang.pt: 'Quer remover os anúncios?',
      AppLang.fr: 'Voulez-vous supprimer les publicités ?',
    },
    'modalDisableAdsSubtitle': {
      AppLang.es:
          'Puedes quitar los anuncios viendo un video o apoyar el proyecto',
      AppLang.en:
          'You can remove ads by watching a short video or supporting the project.',
      AppLang.de:
          'Du kannst Werbung entfernen, indem du ein Video ansiehst oder das Projekt unterstützt.',
      AppLang.pt:
          'Você pode remover os anúncios assistindo a um vídeo ou apoiando o projeto.',
      AppLang.fr:
          'Vous pouvez supprimer les publicités en regardant une vidéo ou en soutenant le projet.',
    },
    'removeAds24h': {
      AppLang.es: 'Quitar anuncios por 24h',
      AppLang.en: 'Remove ads for 24 hours',
      AppLang.de: 'Werbung für 24 Stunden entfernen',
      AppLang.pt: 'Remover anúncios por 24h',
      AppLang.fr: 'Supprimer les publicités pendant 24 h',
    },
    'maybeLater': {
      AppLang.es: 'Tal vez luego',
      AppLang.en: 'Maybe later',
      AppLang.de: 'Vielleicht später',
      AppLang.pt: 'Talvez depois',
      AppLang.fr: 'Peut-être plus tard',
    },
    'supportProject': {
      AppLang.es: '¿Te gusta la app? \n Compártela o apóyanos',
      AppLang.en: 'Enjoying the app? \n Share or support us',
      AppLang.de: 'Gefällt dir die App?\nTeile sie oder unterstütze uns',
      AppLang.pt: 'Gostando do app?\nCompartilhe ou nos apoie',
      AppLang.fr: "Vous aimez l'application ?\nPartagez-la ou soutenez-nous",
    },
    'viewLargeAd': {
      AppLang.es: 'Ver un anuncio grande',
      AppLang.en: 'View a large ad',
      AppLang.de: 'Große Werbung ansehen',
      AppLang.pt: 'Ver um anúncio grande',
      AppLang.fr: 'Voir une grande publicité',
    },
    'disableAdsForOneDay': {
      AppLang.es: 'Se desactivará por un día la publicidad',
      AppLang.en: 'The ad will be disabled for one day',
      AppLang.de: 'Die Werbung wird für einen Tag deaktiviert',
      AppLang.pt: 'Os anúncios serão desativados por um dia',
      AppLang.fr: 'Les publicités seront désactivées pendant une journée',
    },
    'thanksForUsingApp': {
      AppLang.es: '¡Gracias por usar la App!',
      AppLang.en: 'Thank you for using the App!',
      AppLang.de: 'Danke, dass du die App nutzt!',
      AppLang.pt: 'Obrigado por usar o app!',
      AppLang.fr: "Merci d'utiliser l'application !",
    },
    'buyMeCoffee': {
      AppLang.es: 'Invítame un café',
      AppLang.en: 'Buy me a coffee',
      AppLang.de: 'Kauf mir einen Kaffee',
      AppLang.pt: 'Me pague um café',
      AppLang.fr: 'Offrez-moi un café',
    },
    'buyMeCoffeeDescription': {
      AppLang.es:
          'Si te gusta la app, invítame un café para apoyar el proyecto',
      AppLang.en:
          'If you like the app, buy me a coffee to support the project.',
      AppLang.de:
          'Wenn dir die App gefällt, spendiere mir einen Kaffee, um das Projekt zu unterstützen.',
      AppLang.pt:
          'Se você gosta do app, me pague um café para apoiar o projeto.',
      AppLang.fr:
          "Si vous aimez l'application, offrez-moi un café pour soutenir le projet.",
    },
  };
}
