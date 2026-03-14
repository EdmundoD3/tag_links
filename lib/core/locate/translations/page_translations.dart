import 'package:tag_links/core/locate/app_lang.dart';

final Map<String, Map<AppLang, String>> translationsPage = {
  'appName': {AppLang.es: 'Tag Links', AppLang.en: 'Tag Links'},
  'pendingNotesTitle': {
    AppLang.es: 'Elige una carpeta donde almacenar la nota',
    AppLang.en: 'Choose a folder where to store the note',
  },
  'pendingNotesConfirmTitle': {
    AppLang.es: 'No almacenar la nota',
    AppLang.en: 'Don\'t store the note',
  },
  'pendingNotesConfirMessage': {
    AppLang.es: '¿Estás seguro de descartar la nota?',
    AppLang.en: 'Are you sure you want to discard the note?',
  },
  
  //settings page
  'settingsTitle': {AppLang.es: 'Configuración', AppLang.en: 'Settings'},
  
  'settingsTheme': {
    AppLang.es: 'Tema',
    AppLang.en: 'Theme',
  },
  'settingsLanguage': {
    AppLang.es: 'Idioma',
    AppLang.en: 'Language',
  },

  // helpers
  'fabAddNote': {AppLang.es: 'Agregar nota', AppLang.en: 'Add note'},
  'fabAddFolder': {AppLang.es: 'Agregar carpeta', AppLang.en: 'Add folder'},
};
