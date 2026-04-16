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
    },
    'premiumBenefit': {
      AppLang.es: 'Sin anuncios.',
      AppLang.en: 'No ads.',
      AppLang.de: 'Keine Werbung.',
    },
    'premiumMaybeLater': {
      AppLang.es: 'Quizás más tarde',
      AppLang.en: 'Maybe later',
      AppLang.de: 'Vielleicht später',
    },
    'premiumThanks': {
      AppLang.es: '¡Gracias por tu compra! Ya eres Premium.',
      AppLang.en: 'Thank you for your purchase! You are now Premium.',
      AppLang.de: 'Danke für deinen Kauf! Du bist jetzt Premium.',
    },
  };
}