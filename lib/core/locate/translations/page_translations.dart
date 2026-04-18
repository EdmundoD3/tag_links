// lib/core/locate/modules/pages_translate.dart
import 'package:tag_links/config/name_of_app.dart';

import '../app_lang.dart';

class TranslatesPages {
  const TranslatesPages();

  final String appName = 'appName';

  // Pending Notes Page
  final String pendingNotesTitle = 'pendingNotesTitle';
  final String discardNoteTitle = 'pendingNotesConfirmTitle';
  final String discardNoteMessage = 'pendingNotesConfirmMessage';

  // Settings Page
  final String settingsTitle = 'settingsTitle';
  final String theme = 'settingsTheme';
  final String language = 'settingsLanguage';

  static const Map<String, Map<AppLang, String>> translations = {
    // -------------------- Pages --------------------
    'appName': {
      AppLang.es: NameOfApp.upperCase,
      AppLang.en: NameOfApp.upperCase,
      AppLang.de: NameOfApp.upperCase,
      AppLang.pt: NameOfApp.upperCase,
      AppLang.fr: NameOfApp.upperCase,
      AppLang.ru: NameOfApp.upperCase,
      AppLang.ja: NameOfApp.upperCase,
      AppLang.zh: NameOfApp.upperCase,
    },

    'pendingNotesTitle': {
      AppLang.es: 'Elige una carpeta donde almacenar la nota',
      AppLang.en: 'Choose a folder where to store the note',
      AppLang.de: 'Wähle einen Ordner für die Notiz',
      AppLang.pt: 'Escolha uma pasta onde armazenar a nota',
      AppLang.fr: 'Choisissez un dossier où enregistrer la note',
      AppLang.ru: 'Выберите папку для сохранения заметки',
      AppLang.ja: 'ノートを保存するフォルダを選択してください',
      AppLang.zh: '请选择一个文件夹来保存笔记',
    },
    'pendingNotesConfirmTitle': {
      AppLang.es: 'No almacenar la nota',
      AppLang.en: "Don't store the note",
      AppLang.de: 'Notiz nicht speichern',
      AppLang.pt: 'Não armazenar a nota',
      AppLang.fr: 'Ne pas enregistrer la note',
      AppLang.ru: 'Не сохранять заметку',
      AppLang.ja: 'ノートを保存しない',
      AppLang.zh: '不保存笔记',
    },
    'pendingNotesConfirmMessage': {
      AppLang.es: '¿Estás seguro de descartar la nota?',
      AppLang.en: 'Are you sure you want to discard the note?',
      AppLang.de: 'Möchtest du die Notiz wirklich verwerfen?',
      AppLang.pt: 'Tem certeza de que deseja descartar a nota?',
      AppLang.fr: 'Êtes-vous sûr de vouloir ignorer la note ?',
      AppLang.ru: 'Вы уверены, что хотите удалить заметку?',
      AppLang.ja: 'このノートを破棄してもよろしいですか？',
      AppLang.zh: '确定要放弃这条笔记吗？',
    },

    'settingsTitle': {
      AppLang.es: 'Configuración',
      AppLang.en: 'Settings',
      AppLang.de: 'Einstellungen',
      AppLang.pt: 'Configurações',
      AppLang.fr: 'Paramètres',
      AppLang.ru: 'Настройки',
      AppLang.ja: '設定',
      AppLang.zh: '设置',
    },
    'settingsTheme': {
      AppLang.es: 'Tema',
      AppLang.en: 'Theme',
      AppLang.de: 'Design',
      AppLang.pt: 'Tema',
      AppLang.fr: 'Thème',
      AppLang.ru: 'Тема',
      AppLang.ja: 'テーマ',
      AppLang.zh: '主题',
    },
    'settingsLanguage': {
      AppLang.es: 'Idioma',
      AppLang.en: 'Language',
      AppLang.de: 'Sprache',
      AppLang.pt: 'Idioma',
      AppLang.fr: 'Langue',
      AppLang.ru: 'Язык',
      AppLang.ja: '言語',
      AppLang.zh: '语言',
    },
  };
}
