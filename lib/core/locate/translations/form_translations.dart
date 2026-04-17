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
      AppLang.pt: 'Nome da pasta',
    },
    'formFolderTitleRequired': {
      AppLang.es: 'El título es obligatorio',
      AppLang.en: 'The title is required',
      AppLang.de: 'Titel ist erforderlich',
      AppLang.pt: 'O título é obrigatório',
    },
    'formFolderDescription': {
      AppLang.es: 'Descripción',
      AppLang.en: 'Description',
      AppLang.de: 'Beschreibung',
      AppLang.pt: 'Descrição',
    },
    'moveToFolder': {
      AppLang.es: 'Mover',
      AppLang.en: 'Move',
      AppLang.de: 'Verschieben',
      AppLang.pt: 'Mover',
    },
    'newFolder': {
      AppLang.es: 'Nueva carpeta',
      AppLang.en: 'New folder',
      AppLang.de: 'Neuer Ordner',
      AppLang.pt: 'Nova pasta',
    },
    'editFolder': {
      AppLang.es: 'Editar carpeta',
      AppLang.en: 'Edit folder',
      AppLang.de: 'Ordner bearbeiten',
      AppLang.pt: 'Editar pasta',
    },

    // Note Form
    'newNote': {
      AppLang.es: 'Nueva nota',
      AppLang.en: 'New note',
      AppLang.de: 'Neue Notiz',
      AppLang.pt: 'Nova nota',
    },
    'fastNote': {
      AppLang.es: 'Nota rápida',
      AppLang.en: 'Fast note',
      AppLang.de: 'Schnelle Notiz',
      AppLang.pt: 'Nota rápida',
    },
    'hiddenFastNote': {
      AppLang.es: 'Ocultar',
      AppLang.en: 'Hide',
      AppLang.de: 'Ausblenden',
      AppLang.pt: 'Ocultar',
    },
    'content': {
      AppLang.es: 'Contenido',
      AppLang.en: 'Content',
      AppLang.de: 'Inhalt',
      AppLang.pt: 'Conteúdo',
    },
    'title': {
      AppLang.es: 'Título',
      AppLang.en: 'Title',
      AppLang.de: 'Titel',
      AppLang.pt: 'Título',
    },
  };
}
