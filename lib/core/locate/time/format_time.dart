import 'package:intl/intl.dart';
import 'package:tag_links/core/locate/app_lang.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/locate/lang_provider.dart';

extension RefFormat on WidgetRef {
  /// Formatea un timestamp o DateTime según el idioma actual del provider
  String fmt(dynamic date, {bool short = false}) {
    // 1. Obtenemos el idioma actual (reactivo)
    final lang = watch(langProvider);
    final String locale = lang.isoCode;

    // 2. Normalizamos la entrada a DateTime
    DateTime dateTime;
    if (date is int) {
      dateTime = DateTime.fromMillisecondsSinceEpoch(date);
    } else if (date is DateTime) {
      dateTime = date;
    } else {
      return "Invalid Date";
    }

    // 3. Elegimos el formato
    // yMMMd: 2 abr 2026 | yMd: 2/4/2026
    final DateFormat formatter = short 
        ? DateFormat.yMd(locale) 
        : DateFormat.yMMMd(locale).add_Hm();

    return formatter.format(dateTime);
  }
}