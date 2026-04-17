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
      AppLang.fr: 'Rechercher...',
      AppLang.ru: 'Поиск...',
    },
    'noFolders': {
      AppLang.es: 'No hay carpetas',
      AppLang.en: 'No folders',
      AppLang.de: 'Keine Ordner',
      AppLang.pt: 'Nenhuma pasta',
      AppLang.fr: 'Aucun dossier',
      AppLang.ru: 'Нет папок',
    },
    'emptyNotes': {
      AppLang.es: 'No hay notas',
      AppLang.en: 'No notes',
      AppLang.de: 'Keine Notizen',
      AppLang.pt: 'Nenhuma nota',
      AppLang.fr: 'Aucune note',
      AppLang.ru: 'Нет заметок',
    },
    'goToFolder': {
      AppLang.es: 'Ir a la carpeta',
      AppLang.en: 'Go to folder',
      AppLang.de: 'Zum Ordner gehen',
      AppLang.pt: 'Ir para a pasta',
      AppLang.fr: 'Aller au dossier',
      AppLang.ru: 'Перейти в папку',
    },
    'markAsFavorite': {
      AppLang.es: 'Marcar como favorito',
      AppLang.en: 'Mark as favorite',
      AppLang.de: 'Als Favorit markieren',
      AppLang.pt: 'Marcar como favorito',
      AppLang.fr: 'Marquer comme favori',
      AppLang.ru: 'Добавить в избранное',
    },
    'switchFolder': {
      AppLang.es: 'Carpetas',
      AppLang.en: 'Folders',
      AppLang.de: 'Ordner',
      AppLang.pt: 'Pastas',
      AppLang.fr: 'Dossiers',
      AppLang.ru: 'Папки',
    },
    'switchNote': {
      AppLang.es: 'Notas',
      AppLang.en: 'Notes',
      AppLang.de: 'Notizen',
      AppLang.pt: 'Notas',
      AppLang.fr: 'Notes',
      AppLang.ru: 'Заметки',
    },
    'fabAddNote': {
      AppLang.es: 'Agregar nota',
      AppLang.en: 'Add note',
      AppLang.de: 'Notiz hinzufügen',
      AppLang.pt: 'Adicionar nota',
      AppLang.fr: 'Ajouter une note',
      AppLang.ru: 'Добавить заметку',
    },
    'fabAddFolder': {
      AppLang.es: 'Agregar carpeta',
      AppLang.en: 'Add folder',
      AppLang.de: 'Ordner hinzufügen',
      AppLang.pt: 'Adicionar pasta',
      AppLang.fr: 'Ajouter un dossier',
      AppLang.ru: 'Добавить папку',
    },
    'createFolder': {
      AppLang.es: 'Crear carpeta',
      AppLang.en: 'Create folder',
      AppLang.de: 'Ordner erstellen',
      AppLang.pt: 'Criar pasta',
      AppLang.fr: 'Créer un dossier',
      AppLang.ru: 'Создать папку',
    },
    'readMore': {
      AppLang.es: 'ver más...',
      AppLang.en: 'show more...',
      AppLang.de: 'Mehr anzeigen...',
      AppLang.pt: 'ver mais...',
      AppLang.fr: 'voir plus...',
      AppLang.ru: 'показать больше...',
    },
    'readLess': {
      AppLang.es: 'ver menos...',
      AppLang.en: 'show less...',
      AppLang.de: 'Weniger anzeigen...',
      AppLang.pt: 'ver menos...',
      AppLang.fr: 'voir moins...',
      AppLang.ru: 'показать меньше...',
    },
    'noTagsFound': {
      AppLang.es: 'No se encontraron etiquetas',
      AppLang.en: 'No tags found',
      AppLang.de: 'Keine Tags gefunden',
      AppLang.pt: 'Nenhuma tag encontrada',
      AppLang.fr: 'Aucun tag trouvé',
      AppLang.ru: 'Теги не найдены',
    },
    'viewAll': {
      AppLang.es: 'Ver todo',
      AppLang.en: 'View all',
      AppLang.de: 'Alle anzeigen',
      AppLang.pt: 'Ver tudo',
      AppLang.fr: 'Voir tout',
      AppLang.ru: 'Показать всё',
    },
    'viewOnlyFavorites': {
      AppLang.es: 'Ver solo favoritos',
      AppLang.en: 'View only favorites',
      AppLang.de: 'Nur Favoriten anzeigen',
      AppLang.pt: 'Ver apenas favoritos',
      AppLang.fr: 'Voir uniquement les favoris',
      AppLang.ru: 'Показать только избранное',
    },
  };
}
