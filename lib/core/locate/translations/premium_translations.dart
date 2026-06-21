import '../app_lang.dart';

class TranslatesPremium {
  const TranslatesPremium();

  final String title = 'premiumTitle';
  final String benefit = 'premiumBenefit';
  final String maybeLater = 'premiumMaybeLater';
  final String thanks = 'premiumThanks';
  final String buyYear = 'premiumBuyYear';

  static const Map<String, Map<AppLang, String>> translations = {
    'premiumTitle': {
      AppLang.es: 'Premium',
      AppLang.en: 'Premium',
      AppLang.de: 'Premium',
      AppLang.pt: 'Premium',
      AppLang.fr: 'Premium',
      AppLang.ru: 'Премиум',
      AppLang.ja: 'プレミアム',
      AppLang.zh: '高级版',
    },
    'premiumBenefit': {
      AppLang.es: 'Sin anuncios.',
      AppLang.en: 'No ads.',
      AppLang.de: 'Keine Werbung.',
      AppLang.pt: 'Sem anúncios.',
      AppLang.fr: 'Sans publicité.',
      AppLang.ru: 'Без рекламы.',
      AppLang.ja: '広告なし。',
      AppLang.zh: '无广告。',
    },
    'premiumMaybeLater': {
      AppLang.es: 'Quizás más tarde',
      AppLang.en: 'Maybe later',
      AppLang.de: 'Vielleicht später',
      AppLang.pt: 'Talvez mais tarde',
      AppLang.fr: 'Peut-être plus tard',
      AppLang.ru: 'Возможно позже',
      AppLang.ja: '後で',
      AppLang.zh: '以后再说',
    },
    'premiumThanks': {
      AppLang.es: '¡Gracias por tu compra! Ya eres Premium.',
      AppLang.en: 'Thank you for your purchase! You are now Premium.',
      AppLang.de: 'Danke für deinen Kauf! Du bist jetzt Premium.',
      AppLang.pt: 'Obrigado pela sua compra! Agora você é Premium.',
      AppLang.fr: 'Merci pour votre achat ! Vous êtes maintenant Premium.',
      AppLang.ru: 'Спасибо за покупку! Теперь у вас Премиум.',
      AppLang.ja: 'ご購入ありがとうございます！プレミアムになりました。',
      AppLang.zh: '感谢你的购买！你现在已成为高级用户。',
    },
    'premiumBuyYear': {
      AppLang.es: 'Desbloquear Premium por 1 año',
      AppLang.en: 'Unlock Premium for 1 year',
      AppLang.de: 'Premium für 1 Jahr freischalten',
      AppLang.pt: 'Desbloquear Premium por 1 ano',
      AppLang.fr: 'Débloquer Premium pendant 1 an',
      AppLang.ru: 'Разблокировать Премиум на 1 год',
      AppLang.ja: 'プレミアムを1年間アンロック',
      AppLang.zh: '解锁高级版一年',
    },
  };
}
