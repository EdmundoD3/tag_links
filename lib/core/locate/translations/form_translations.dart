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
  final String content = 'content';
  final String title = 'title';

  static const Map<String, Map<AppLang, String>> translations = {
    // Folder Form
    'formFolderTitle': {
      AppLang.es: 'Nombre de la carpeta',
      AppLang.en: 'Folder name',
    },
    'formFolderTitleRequired': {
      AppLang.es: 'El título es obligatorio',
      AppLang.en: 'The title is required',
    },
    'formFolderDescription': {
      AppLang.es: 'Descripción',
      AppLang.en: 'Description',
    },
    'moveToFolder': {AppLang.es: 'Mover', AppLang.en: 'Move'},
    'newFolder': {AppLang.es: 'Nueva carpeta', AppLang.en: 'New folder'},
    'editFolder': {AppLang.es: 'Editar carpeta', AppLang.en: 'Edit folder'},

    // Note Form
    'newNote': {AppLang.es: 'Nueva nota', AppLang.en: 'New note'},
    'content': {AppLang.es: 'Contenido', AppLang.en: 'Content'},
    'title': {AppLang.es: 'Título', AppLang.en: 'Title'},
  };
}
