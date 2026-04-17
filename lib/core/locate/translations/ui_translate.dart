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
    'searchHintText': {
      AppLang.es: 'Buscar...',
      AppLang.en: 'Search...',
      AppLang.de: 'Suchen...',
      AppLang.pt: 'Buscar...',
    },
    'noFolders': {
      AppLang.es: 'No hay carpetas',
      AppLang.en: 'No folders',
      AppLang.de: 'Keine Ordner',
      AppLang.pt: 'Nenhuma pasta',
    },
    'emptyNotes': {
      AppLang.es: 'No hay notas',
      AppLang.en: 'No notes',
      AppLang.de: 'Keine Notizen',
      AppLang.pt: 'Nenhuma nota',
    },
    'goToFolder': {
      AppLang.es: 'Ir a la carpeta',
      AppLang.en: 'Go to folder',
      AppLang.de: 'Zum Ordner gehen',
      AppLang.pt: 'Ir para a pasta',
    },
    'markAsFavorite': {
      AppLang.es: 'Marcar como favorito',
      AppLang.en: 'Mark as favorite',
      AppLang.de: 'Als Favorit markieren',
      AppLang.pt: 'Marcar como favorito',
    },
    'switchFolder': {
      AppLang.es: 'Carpetas',
      AppLang.en: 'Folders',
      AppLang.de: 'Ordner',
      AppLang.pt: 'Pastas',
    },
    'switchNote': {
      AppLang.es: 'Notas',
      AppLang.en: 'Notes',
      AppLang.de: 'Notizen',
      AppLang.pt: 'Notas',
    },
    'fabAddNote': {
      AppLang.es: 'Agregar nota',
      AppLang.en: 'Add note',
      AppLang.de: 'Notiz hinzufügen',
      AppLang.pt: 'Adicionar nota',
    },
    'fabAddFolder': {
      AppLang.es: 'Agregar carpeta',
      AppLang.en: 'Add folder',
      AppLang.de: 'Ordner hinzufügen',
      AppLang.pt: 'Adicionar pasta',
    },
    'createFolder': {
      AppLang.es: 'Crear carpeta',
      AppLang.en: 'Create folder',
      AppLang.de: 'Ordner erstellen',
      AppLang.pt: 'Criar pasta',
    },
    'readMore': {
      AppLang.es: 'ver más...',
      AppLang.en: 'show more...',
      AppLang.de: 'Mehr anzeigen...',
      AppLang.pt: 'ver mais...',
    },
    'readLess': {
      AppLang.es: 'ver menos...',
      AppLang.en: 'show less...',
      AppLang.de: 'Weniger anzeigen...',
      AppLang.pt: 'ver menos...',
    },
    'noTagsFound': {
      AppLang.es: 'No se encontraron etiquetas',
      AppLang.en: 'No tags found',
      AppLang.de: 'Keine Tags gefunden',
      AppLang.pt: 'Nenhuma tag encontrada',
    },
    'viewAll': {
      AppLang.es: 'Ver todo',
      AppLang.en: 'View all',
      AppLang.de: 'Alle anzeigen',
      AppLang.pt: 'Ver tudo',
    },
    'viewOnlyFavorites': {
      AppLang.es: 'Ver solo favoritos',
      AppLang.en: 'View only favorites',
      AppLang.de: 'Nur Favoriten anzeigen',
      AppLang.pt: 'Ver apenas favoritos',
    },
  };
}
