// lib/core/locate/modules/pages_translate.dart
import '../app_lang.dart';

class TranslatesPages {
  const TranslatesPages();

  final String appName = 'appName';
  
  // Pending Notes Page
  final String pendingNotesTitle = 'pendingNotesTitle';
  final String discardNoteTitle = 'pendingNotesConfirmTitle';
  final String discardNoteMessage = 'pendingNotesConfirMessage';
  
  // Settings Page
  final String settingsTitle = 'settingsTitle';
  final String theme = 'settingsTheme';
  final String language = 'settingsLanguage';

  static const Map<String, Map<AppLang, String>> translations = {
    // -------------------- Pages --------------------
    'appName': {AppLang.es: 'Tag Links', AppLang.en: 'Tag Links'},
    
    'pendingNotesTitle': {
      AppLang.es: 'Elige una carpeta donde almacenar la nota',
      AppLang.en: 'Choose a folder where to store the note',
    },
    'pendingNotesConfirmTitle': {
      AppLang.es: 'No almacenar la nota',
      AppLang.en: "Don't store the note",
    },
    'pendingNotesConfirMessage': {
      AppLang.es: '¿Estás seguro de descartar la nota?',
      AppLang.en: 'Are you sure you want to discard the note?',
    },

    'settingsTitle': {AppLang.es: 'Configuración', AppLang.en: 'Settings'},
    'settingsTheme': {AppLang.es: 'Tema', AppLang.en: 'Theme'},
    'settingsLanguage': {AppLang.es: 'Idioma', AppLang.en: 'Language'},
  };
}