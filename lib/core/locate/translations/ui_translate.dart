// lib/core/locate/modules/ui_translate.dart
import '../app_lang.dart';

class TranslatesUI {
  const TranslatesUI();

  final String searchHint = 'searchHintText';
  final String noFolders = 'noFolders';
  final String emptyNotes = 'emptyNotes';
  final String goToFolder = 'goToFolder';
  
  final String favorite = 'markAsFavorite';
  final String folders = 'switchFolder';
  final String notes = 'switchNote';
  final String addNote = 'fabAddNote';
  final String addFolder = 'fabAddFolder';
  final String createFolder = 'createFolder';
  final String readMore = 'readMore';
  final String readLess = 'readLess';
  final String noTagsFound = 'noTagsFound';
  final String viewAll = 'viewAll';
  final String viewOnlyFavorites = 'viewOnlyFavorites';
  

  static const Map<String, Map<AppLang, String>> translations = {
    'searchHintText': {AppLang.es: 'Buscar...', AppLang.en: 'Search...'},
    'noFolders': {AppLang.es: 'No hay carpetas', AppLang.en: 'No folders'},
    'emptyNotes': {AppLang.es: 'No hay notas', AppLang.en: 'No notes'},
    'goToFolder': {AppLang.es: 'Ir a la carpeta', AppLang.en: 'Go to folder'},
    'markAsFavorite': {
      AppLang.es: 'Marcar como favorito',
      AppLang.en: 'Mark as favorite',
    },
    'switchFolder': {AppLang.es: 'Carpetas', AppLang.en: 'Folders'},
    'switchNote': {AppLang.es: 'Notas', AppLang.en: 'Notes'},
    'fabAddNote': {AppLang.es: 'Agregar nota', AppLang.en: 'Add note'},
    'fabAddFolder': {AppLang.es: 'Agregar carpeta', AppLang.en: 'Add folder'},
        'createFolder': {
      AppLang.es: 'Crear carpeta', 
      AppLang.en: 'Create folder'
    },
    'readMore': {AppLang.es: 'ver más...', AppLang.en: 'show more...'},
    'readLess': {AppLang.es: 'ver menos...', AppLang.en: 'show less...'},
    'noTagsFound': {AppLang.es: 'No se encontraron etiquetas', AppLang.en: 'No tags found'},
    'viewAll': {AppLang.es: 'Ver todo', AppLang.en: 'View all'},
    'viewOnlyFavorites': {AppLang.es: 'Ver solo favoritos', AppLang.en: 'View only favorites'},
  };
}
