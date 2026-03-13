import 'package:tag_links/core/locate/app_lang.dart';
import 'package:tag_links/core/locate/translations/alert_translations.dart';
import 'package:tag_links/core/locate/translations/errors_translations.dart';
import 'package:tag_links/core/locate/translations/form_translations.dart';
import 'package:tag_links/core/locate/translations/helpers_translations.dart';
import 'package:tag_links/core/locate/translations/page_translations.dart';
import 'package:tag_links/core/locate/translations/rewarded_ad.dart';

final Map<String, Map<AppLang, String>> mainPage = {};

final Map<String, Map<AppLang, String>> translations = {
  //homePage
  ...translationsPage,
  //formFolder
  ...formTranslations,
  //alerts
  ...alertTranslations,
  //helpers
  ...helpersTranslations,
  //errors
  ...errorsTranslations,
  //thanks
  ...rewardedTranslations,
};
