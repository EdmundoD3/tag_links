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
  final String premium24h = 'premium24h';

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
      AppLang.ru: 'Спасибо!',
      AppLang.ja: 'ありがとうございます！',
      AppLang.zh: '谢谢！',
    },
    'errorForRewardedAd': {
      AppLang.es: 'Error al mostrar el anuncio, inténtalo de nuevo más tarde.',
      AppLang.en: 'Error showing ad, try again later.',
      AppLang.de:
          'Fehler beim Anzeigen der Werbung. Bitte später erneut versuchen.',
      AppLang.pt: 'Erro ao exibir o anúncio, tente novamente mais tarde.',
      AppLang.fr:
          "Erreur lors de l'affichage de la publicité, réessayez plus tard.",
      AppLang.ru: 'Ошибка при показе рекламы. Попробуйте позже.',
      AppLang.ja: '広告の表示中にエラーが発生しました。後でもう一度お試しください。',
      AppLang.zh: '广告加载失败，请稍后再试。',
    },
'modalDisableAdsTitle': {
  AppLang.es: 'Obtén acceso Premium',
  AppLang.en: 'Get Premium Access',
  AppLang.de: 'Premium-Zugang erhalten',
  AppLang.pt: 'Obtenha acesso Premium',
  AppLang.fr: 'Obtenez l’accès Premium',
  AppLang.ru: 'Получите Premium-доступ',
  AppLang.ja: 'プレミアム機能を利用する',
  AppLang.zh: '获取高级权限',
},
'modalDisableAdsSubtitle': {
  AppLang.es:
      'Prueba las funciones Premium durante 24 horas viendo un video o desbloquéalas durante un año apoyando el proyecto.',
  AppLang.en:
      'Try Premium features for 24 hours by watching a video, or unlock them for a year by supporting the project.',
  AppLang.de:
      'Teste Premium-Funktionen 24 Stunden lang durch das Ansehen eines Videos oder schalte sie für ein Jahr frei, indem du das Projekt unterstützt.',
  AppLang.pt:
      'Experimente os recursos Premium por 24 horas assistindo a um vídeo ou desbloqueie-os por um ano apoiando o projeto.',
  AppLang.fr:
      'Essayez les fonctionnalités Premium pendant 24 heures en regardant une vidéo ou débloquez-les pendant un an en soutenant le projet.',
  AppLang.ru:
      'Попробуйте Premium-функции на 24 часа, посмотрев видео, или получите доступ на год, поддержав проект.',
  AppLang.ja:
      '動画を視聴して24時間プレミアム機能を試すか、プロジェクトを支援して1年間利用できます。',
  AppLang.zh:
      '观看视频即可体验24小时高级功能，或通过支持项目解锁一整年。',
},
'premium24h': {
  AppLang.es: 'Premium por 24 horas',
  AppLang.en: 'Premium for 24 Hours',
  AppLang.de: 'Premium für 24 Stunden',
  AppLang.pt: 'Premium por 24 horas',
  AppLang.fr: 'Premium pendant 24 heures',
  AppLang.ru: 'Премиум на 24 часа',
  AppLang.ja: '24時間プレミアム',
  AppLang.zh: '24小时高级版',
},
    'maybeLater': {
      AppLang.es: 'Tal vez luego',
      AppLang.en: 'Maybe later',
      AppLang.de: 'Vielleicht später',
      AppLang.pt: 'Talvez depois',
      AppLang.fr: 'Peut-être plus tard',
      AppLang.ru: 'Возможно позже',
      AppLang.ja: '後で',
      AppLang.zh: '以后再说',
    },
    'supportProject': {
      AppLang.es: '¿Te gusta la app? \n Compártela o apóyanos',
      AppLang.en: 'Enjoying the app? \n Share or support us',
      AppLang.de: 'Gefällt dir die App?\nTeile sie oder unterstütze uns',
      AppLang.pt: 'Gostando do app?\nCompartilhe ou nos apoie',
      AppLang.fr: "Vous aimez l'application ?\nPartagez-la ou soutenez-nous",
      AppLang.ru: 'Нравится приложение?\nПоделитесь им или поддержите нас',
      AppLang.ja: 'アプリを気に入っていますか？\n共有するかサポートしてください',
      AppLang.zh: '喜欢这个应用吗？\n分享或支持我们吧',
    },
    'viewLargeAd': {
      AppLang.es: 'Ver un anuncio grande',
      AppLang.en: 'View a large ad',
      AppLang.de: 'Große Werbung ansehen',
      AppLang.pt: 'Ver um anúncio grande',
      AppLang.fr: 'Voir une grande publicité',
      AppLang.ru: 'Посмотреть большое объявление',
      AppLang.ja: '大きな広告を見る',
      AppLang.zh: '观看大广告',
    },
    'disableAdsForOneDay': {
      AppLang.es: 'Se desactivará por un día la publicidad',
      AppLang.en: 'The ad will be disabled for one day',
      AppLang.de: 'Die Werbung wird für einen Tag deaktiviert',
      AppLang.pt: 'Os anúncios serão desativados por um dia',
      AppLang.fr: 'Les publicités seront désactivées pendant une journée',
      AppLang.ru: 'Реклама будет отключена на один день',
      AppLang.ja: '広告は1日間無効になります',
      AppLang.zh: '广告将禁用一天',
    },
    'thanksForUsingApp': {
      AppLang.es: '¡Gracias por usar la App!',
      AppLang.en: 'Thank you for using the App!',
      AppLang.de: 'Danke, dass du die App nutzt!',
      AppLang.pt: 'Obrigado por usar o app!',
      AppLang.fr: "Merci d'utiliser l'application !",
      AppLang.ru: 'Спасибо за использование приложения!',
      AppLang.ja: 'アプリをご利用いただきありがとうございます！',
      AppLang.zh: '感谢使用本应用！',
    },
    'buyMeCoffee': {
      AppLang.es: 'Invítame un café',
      AppLang.en: 'Buy me a coffee',
      AppLang.de: 'Kauf mir einen Kaffee',
      AppLang.pt: 'Me pague um café',
      AppLang.fr: 'Offrez-moi un café',
      AppLang.ru: 'Купите мне кофе',
      AppLang.ja: 'コーヒーをおごってください',
      AppLang.zh: '请我喝杯咖啡',
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
      AppLang.ru:
          'Если вам нравится приложение, купите мне кофе, чтобы поддержать проект.',
      AppLang.ja: 'アプリを気に入っていただけたら、プロジェクトを支援するためにコーヒーをご馳走してください。',
      AppLang.zh: '如果你喜欢这个应用，请请我喝杯咖啡以支持项目。',
    },
  };
}
