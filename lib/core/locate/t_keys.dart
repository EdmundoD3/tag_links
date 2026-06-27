// lib/core/locate/t_keys.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_lang.dart';
import 'lang_provider.dart';
import 'translations/actions_translations.dart';
import 'translations/ads_translates.dart';
import 'translations/alert_translations.dart';
import 'translations/auth_translations.dart';
import 'translations/errors_translations.dart';
import 'translations/form_translations.dart';
import 'translations/page_translations.dart';
import 'translations/premium_translations.dart';
import 'translations/sync_translations.dart';
import 'translations/tags_translations.dart';
import 'translations/ui_translate.dart';

// La extensión vive aquí para que siempre esté disponible al importar TKeys
extension RefTranslate on WidgetRef {
  String tr(String key, {String? fallback}) {
    final lang = watch(langProvider);
    final translate = TKeys.map[key]?[lang];

    if (translate != null) return translate;

    if (kDebugMode) {
      debugPrint("--------------- Key no encontrada: $key -----------------");
    }

    return TKeys.map[key]?[AppLang.es] ?? fallback ?? key;
  }
}

abstract class TKeys {
  static const actions = TranslatesActions();
  static const ui = TranslatesUI();
  static const tags = TranslatesTags();
  static const errors = TranslatesErrors();
  static const alerts = TranslatesAlerts();
  static const sync = TranslatesSync();
  static const forms = TranslatesForms();
  static const pages = TranslatesPages();
  static const ads = TranslatesAds();
  static const auth = TranslatesAuth();
  static const premium = TranslatesPremium();


  static final Map<String, Map<AppLang, String>> map = {
    ...TranslatesActions.translations,
    ...TranslatesUI.translations,
    ...TranslatesTags.translations,
    ...TranslatesErrors.translations,
    ...TranslatesAlerts.translations,
    ...TranslatesSync.translations,
    ...TranslatesForms.translations,
    ...TranslatesPages.translations,
    ...TranslatesAds.translations,
    ...TranslatesAuth.translations,
    ...TranslatesPremium.translations,
  };
}
