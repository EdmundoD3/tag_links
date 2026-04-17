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
      AppLang.ja: '検索...',
      AppLang.zh: '搜索...',
    },
    'noFolders': {
      AppLang.es: 'No hay carpetas',
      AppLang.en: 'No folders',
      AppLang.de: 'Keine Ordner',
      AppLang.pt: 'Nenhuma pasta',
      AppLang.fr: 'Aucun dossier',
      AppLang.ru: 'Нет папок',
      AppLang.ja: 'フォルダがありません',
      AppLang.zh: '没有文件夹',
    },
    'emptyNotes': {
      AppLang.es: 'No hay notas',
      AppLang.en: 'No notes',
      AppLang.de: 'Keine Notizen',
      AppLang.pt: 'Nenhuma nota',
      AppLang.fr: 'Aucune note',
      AppLang.ru: 'Нет заметок',
      AppLang.ja: 'ノートがありません',
      AppLang.zh: '没有笔记',
    },
    'goToFolder': {
      AppLang.es: 'Ir a la carpeta',
      AppLang.en: 'Go to folder',
      AppLang.de: 'Zum Ordner gehen',
      AppLang.pt: 'Ir para a pasta',
      AppLang.fr: 'Aller au dossier',
      AppLang.ru: 'Перейти в папку',
      AppLang.ja: 'フォルダへ移動',
      AppLang.zh: '前往文件夹',
    },
    'markAsFavorite': {
      AppLang.es: 'Marcar como favorito',
      AppLang.en: 'Mark as favorite',
      AppLang.de: 'Als Favorit markieren',
      AppLang.pt: 'Marcar como favorito',
      AppLang.fr: 'Marquer comme favori',
      AppLang.ru: 'Добавить в избранное',
      AppLang.ja: 'お気に入りに追加',
      AppLang.zh: '标记为收藏',
    },
    'switchFolder': {
      AppLang.es: 'Carpetas',
      AppLang.en: 'Folders',
      AppLang.de: 'Ordner',
      AppLang.pt: 'Pastas',
      AppLang.fr: 'Dossiers',
      AppLang.ru: 'Папки',
      AppLang.ja: 'フォルダ',
      AppLang.zh: '文件夹',
    },
    'switchNote': {
      AppLang.es: 'Notas',
      AppLang.en: 'Notes',
      AppLang.de: 'Notizen',
      AppLang.pt: 'Notas',
      AppLang.fr: 'Notes',
      AppLang.ru: 'Заметки',
      AppLang.ja: 'ノート',
      AppLang.zh: '笔记',
    },
    'fabAddNote': {
      AppLang.es: 'Agregar nota',
      AppLang.en: 'Add note',
      AppLang.de: 'Notiz hinzufügen',
      AppLang.pt: 'Adicionar nota',
      AppLang.fr: 'Ajouter une note',
      AppLang.ru: 'Добавить заметку',
      AppLang.ja: 'ノートを追加',
      AppLang.zh: '添加笔记',
    },
    'fabAddFolder': {
      AppLang.es: 'Agregar carpeta',
      AppLang.en: 'Add folder',
      AppLang.de: 'Ordner hinzufügen',
      AppLang.pt: 'Adicionar pasta',
      AppLang.fr: 'Ajouter un dossier',
      AppLang.ru: 'Добавить папку',
      AppLang.ja: 'フォルダを追加',
      AppLang.zh: '添加文件夹',
    },
    'createFolder': {
      AppLang.es: 'Crear carpeta',
      AppLang.en: 'Create folder',
      AppLang.de: 'Ordner erstellen',
      AppLang.pt: 'Criar pasta',
      AppLang.fr: 'Créer un dossier',
      AppLang.ru: 'Создать папку',
      AppLang.ja: 'フォルダ作成',
      AppLang.zh: '创建文件夹',
    },
    'readMore': {
      AppLang.es: 'ver más...',
      AppLang.en: 'show more...',
      AppLang.de: 'Mehr anzeigen...',
      AppLang.pt: 'ver mais...',
      AppLang.fr: 'voir plus...',
      AppLang.ru: 'показать больше...',
      AppLang.ja: 'もっと見る...',
      AppLang.zh: '查看更多...',
    },
    'readLess': {
      AppLang.es: 'ver menos...',
      AppLang.en: 'show less...',
      AppLang.de: 'Weniger anzeigen...',
      AppLang.pt: 'ver menos...',
      AppLang.fr: 'voir moins...',
      AppLang.ru: 'показать меньше...',
      AppLang.ja: '閉じる...',
      AppLang.zh: '收起...',
    },
    'noTagsFound': {
      AppLang.es: 'No se encontraron etiquetas',
      AppLang.en: 'No tags found',
      AppLang.de: 'Keine Tags gefunden',
      AppLang.pt: 'Nenhuma tag encontrada',
      AppLang.fr: 'Aucun tag trouvé',
      AppLang.ru: 'Теги не найдены',
      AppLang.ja: 'タグが見つかりません',
      AppLang.zh: '未找到标签',
    },
    'viewAll': {
      AppLang.es: 'Ver todo',
      AppLang.en: 'View all',
      AppLang.de: 'Alle anzeigen',
      AppLang.pt: 'Ver tudo',
      AppLang.fr: 'Voir tout',
      AppLang.ru: 'Показать всё',
      AppLang.ja: 'すべて表示',
      AppLang.zh: '查看全部',
    },
    'viewOnlyFavorites': {
      AppLang.es: 'Ver solo favoritos',
      AppLang.en: 'View only favorites',
      AppLang.de: 'Nur Favoriten anzeigen',
      AppLang.pt: 'Ver apenas favoritos',
      AppLang.fr: 'Voir uniquement les favoris',
      AppLang.ru: 'Показать только избранное',
      AppLang.ja: 'お気に入りのみ表示',
      AppLang.zh: '仅查看收藏',
    },
  };
}
