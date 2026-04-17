import '../app_lang.dart';

class TranslatesPremium {
  const TranslatesPremium();

  final String title = 'premiumTitle';
  final String benefit = 'premiumBenefit';
  final String maybeLater = 'premiumMaybeLater';
  final String thanks = 'premiumThanks';

  static const Map<String, Map<AppLang, String>> translations = {
    'premiumTitle': {
      AppLang.es: 'Premium',
      AppLang.en: 'Premium',
      AppLang.de: 'Premium',
      AppLang.pt: 'Premium',
      AppLang.fr: 'Premium',
      AppLang.ru: 'Премиум',
    },
    'premiumBenefit': {
      AppLang.es: 'Sin anuncios.',
      AppLang.en: 'No ads.',
      AppLang.de: 'Keine Werbung.',
      AppLang.pt: 'Sem anúncios.',
      AppLang.fr: 'Sans publicité.',
      AppLang.ru: 'Без рекламы.',
    },
    'premiumMaybeLater': {
      AppLang.es: 'Quizás más tarde',
      AppLang.en: 'Maybe later',
      AppLang.de: 'Vielleicht später',
      AppLang.pt: 'Talvez mais tarde',
      AppLang.fr: 'Peut-être plus tard',
      AppLang.ru: 'Возможно позже',
    },
    'premiumThanks': {
      AppLang.es: '¡Gracias por tu compra! Ya eres Premium.',
      AppLang.en: 'Thank you for your purchase! You are now Premium.',
      AppLang.de: 'Danke für deinen Kauf! Du bist jetzt Premium.',
      AppLang.pt: 'Obrigado pela sua compra! Agora você é Premium.',
      AppLang.fr: 'Merci pour votre achat ! Vous êtes maintenant Premium.',
      AppLang.ru: 'Спасибо за покупку! Теперь у вас Премиум.',
    },
  };
}
