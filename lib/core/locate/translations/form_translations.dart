import '../app_lang.dart';

class TranslatesForms {
  const TranslatesForms();

  // --- Carpetas (Folders) ---
  final String folderName = 'formFolderTitle';
  final String folderNameRequired = 'formFolderTitleRequired';
  final String folderDescription = 'formFolderDescription';
  final String moveToFolder = 'moveToFolder';
  final String newFolder = 'newFolder';
  final String editFolder = 'editFolder';

  // --- Notas (Notes) ---
  final String newNote = 'newNote';
  final String fastNote = 'fastNote';
  final String hiddenFastNote = 'hiddenFastNote';
  final String content = 'content';
  final String title = 'title';

  static const Map<String, Map<AppLang, String>> translations = {
    // Folder Form
    'formFolderTitle': {
      AppLang.es: 'Nombre de la carpeta',
      AppLang.en: 'Folder name',
      AppLang.de: 'Ordnername',
    },
    'formFolderTitleRequired': {
      AppLang.es: 'El título es obligatorio',
      AppLang.en: 'The title is required',
      AppLang.de: 'Titel ist erforderlich',
    },
    'formFolderDescription': {
      AppLang.es: 'Descripción',
      AppLang.en: 'Description',
      AppLang.de: 'Beschreibung',
    },
    'moveToFolder': {
      AppLang.es: 'Mover',
      AppLang.en: 'Move',
      AppLang.de: 'Verschieben',
    },
    'newFolder': {
      AppLang.es: 'Nueva carpeta',
      AppLang.en: 'New folder',
      AppLang.de: 'Neuer Ordner',
    },
    'editFolder': {
      AppLang.es: 'Editar carpeta',
      AppLang.en: 'Edit folder',
      AppLang.de: 'Ordner bearbeiten',
    },

    // Note Form
    'newNote': {
      AppLang.es: 'Nueva nota',
      AppLang.en: 'New note',
      AppLang.de: 'Neue Notiz',
    },
    'fastNote': {
      AppLang.es: 'Nota rápida',
      AppLang.en: 'Fast note',
      AppLang.de: 'Schnelle Notiz',
    },
    'hiddenFastNote': {
      AppLang.es: 'Ocultar',
      AppLang.en: 'Hide',
      AppLang.de: 'Ausblenden',
    },
    'content': {
      AppLang.es: 'Contenido',
      AppLang.en: 'Content',
      AppLang.de: 'Inhalt',
    },
    'title': {
      AppLang.es: 'Título',
      AppLang.en: 'Title',
      AppLang.de: 'Titel',
    },
  };
}