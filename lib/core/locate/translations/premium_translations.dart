import '../app_lang.dart';

class TanslatesPremium {
  const TanslatesPremium();
  
  final String title = 'premiumTitle';
  final String benefit = 'premiumBenefit';
  final String maybeLater = 'premiumMaybeLater';
  final String thanks = 'premiumThanks';

  static const Map<String, Map<AppLang, String>> translations = {
    'premiumTitle': {AppLang.es: 'Premium', AppLang.en: 'Premium'},
    'premiumBenefit': {AppLang.es: 'Sin anuncios.', AppLang.en: 'No ads.'},
    'premiumMaybeLater': {AppLang.es: 'Quizás más tarde', AppLang.en: 'Maybe later'},
    'premiumThanks': {AppLang.es: '¡Gracias por tu compra! Ya eres Premium.', AppLang.en: 'Thank you for your purchase! You are now Premium.'},
  };
}