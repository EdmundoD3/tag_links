import '../app_lang.dart';

class TranslatesAlerts {
  const TranslatesAlerts();

  // --- Notas ---
  final String deleteNoteTitle = 'alertDeleteNoteTitle';
  final String deleteNote = 'alertDeleteNote';
  final String deleteNoteSuccess = 'alertDeleteNoteSucces';
  final String deleteNoteError = 'alertDeleteNoteError';
  final String moveNoteTitle = 'alertMoveNoteTitle';
  final String moveNote = 'alertMoveNote';

  // --- Carpetas ---
  final String deleteFolderTitle = 'alertDeleteFolderTitle';
  final String deleteFolder = 'alertDeleteFolder';
  final String deleteFolderSuccess = 'alertDeleteFolderSucces';
  final String deleteFolderError = 'alertDeleteFolderError';
  final String moveFolder = 'alertMoveFolder';
  final String moveFolderTitle = 'alertMoveFolderTitle';
  final String movePendingFolder = 'alertMovePendingFolder';
  final String moveFolverIsDeepError = 'alertMoveFolderErrorIsDeepFolder';
  final String moveFolverIsSameFolderError = 'alertMoveFolderErrorIsSameFolder';

  // --- Etiquetas ---
  final String deleteTagTitle = 'alertDeleteTagTitle';
  final String deleteTagPermanent = 'alertDeleteTagPermanent';
  final String deleteTagSuccess = 'alertDeleteTagSuccess';
  final String deleteTagError = 'alertDeleteTagError';

  // --- Banners / Acciones ---
  final String pendingNote = 'bannerPendingNote';
  final String notMove = 'bannerNotMove';
  final String discardAction = 'discardAction';
  final String limitReached = 'limitReached';
  final String limitReachedMessage = 'flattenMessage';

  //--Form --
  final String discard = 'alertDiscard';
  final String discardFormTitle = 'alertDiscardFormTitle';

  static const Map<String, Map<AppLang, String>> translations = {
    // Notes
    'alertDeleteNoteTitle': {
      AppLang.es: 'Eliminar nota',
      AppLang.en: 'Delete note',
      AppLang.de: 'Notiz löschen',
      AppLang.pt: 'Excluir nota',
      AppLang.fr: 'Supprimer la note',
      AppLang.ru: 'Удалить заметку',
      AppLang.ja: 'ノートを削除',
      AppLang.zh: '删除笔记',
    },
    'alertDeleteNote': {
      AppLang.es: '¿Estás seguro de eliminar la nota?',
      AppLang.en: 'Are you sure you want to delete the note?',
      AppLang.de: 'Möchtest du die Notiz wirklich löschen?',
      AppLang.pt: 'Tem certeza de que deseja excluir a nota?',
      AppLang.fr: 'Êtes-vous sûr de vouloir supprimer la note ?',
      AppLang.ru: 'Вы уверены, что хотите удалить заметку?',
      AppLang.ja: 'このノートを削除してもよろしいですか？',
      AppLang.zh: '确定要删除这条笔记吗？',
    },
    'alertDeleteNoteSucces': {
      AppLang.es: 'Nota eliminada',
      AppLang.en: 'Note deleted',
      AppLang.de: 'Notiz gelöscht',
      AppLang.pt: 'Nota excluída',
      AppLang.fr: 'Note supprimée',
      AppLang.ru: 'Заметка удалена',
      AppLang.ja: 'ノートを削除しました',
      AppLang.zh: '笔记已删除',
    },
    'alertDeleteNoteError': {
      AppLang.es: 'Error al eliminar',
      AppLang.en: 'Error deleting note',
      AppLang.de: 'Fehler beim Löschen',
      AppLang.pt: 'Erro ao excluir a nota',
      AppLang.fr: 'Erreur lors de la suppression',
      AppLang.ru: 'Ошибка при удалении',
      AppLang.ja: '削除中にエラーが発生しました',
      AppLang.zh: '删除失败',
    },
    'alertMoveNoteTitle': {
      AppLang.es: 'Cambiar de carpeta',
      AppLang.en: 'Change folder',
      AppLang.de: 'Ordner ändern',
      AppLang.pt: 'Mudar de pasta',
      AppLang.fr: 'Changer de dossier',
      AppLang.ru: 'Изменить папку',
      AppLang.ja: 'フォルダを変更',
      AppLang.zh: '移动到文件夹',
    },
    'alertMoveNote': {
      AppLang.es: '¿Estás seguro de mover la nota?',
      AppLang.en: 'Are you sure you want to move the note?',
      AppLang.de: 'Möchtest du die Notiz verschieben?',
      AppLang.pt: 'Tem certeza de que deseja mover a nota?',
      AppLang.fr: 'Êtes-vous sûr de vouloir déplacer la note ?',
      AppLang.ru: 'Вы уверены, что хотите переместить заметку?',
      AppLang.ja: 'このノートを移動してもよろしいですか？',
      AppLang.zh: '确定要移动这条笔记吗？',
    },

    // Folders
    'alertDeleteFolderTitle': {
      AppLang.es: 'Eliminar carpeta',
      AppLang.en: 'Delete folder',
      AppLang.de: 'Ordner löschen',
      AppLang.pt: 'Excluir pasta',
      AppLang.fr: 'Supprimer le dossier',
      AppLang.ru: 'Удалить папку',
      AppLang.ja: 'フォルダを削除',
      AppLang.zh: '删除文件夹',
    },
    'alertDeleteFolder': {
      AppLang.es: '¿Estás seguro de eliminar la carpeta?',
      AppLang.en: 'Are you sure you want to delete the folder?',
      AppLang.de: 'Möchtest du den Ordner wirklich löschen?',
      AppLang.pt: 'Tem certeza de que deseja excluir a pasta?',
      AppLang.fr: 'Êtes-vous sûr de vouloir supprimer le dossier ?',
      AppLang.ru: 'Вы уверены, что хотите удалить папку?',
      AppLang.ja: 'このフォルダを削除してもよろしいですか？',
      AppLang.zh: '确定要删除这个文件夹吗？',
    },
    'alertDeleteFolderSucces': {
      AppLang.es: 'Carpeta eliminada',
      AppLang.en: 'Folder deleted',
      AppLang.de: 'Ordner gelöscht',
      AppLang.pt: 'Pasta excluída',
      AppLang.fr: 'Dossier supprimé',
      AppLang.ru: 'Папка удалена',
      AppLang.ja: 'フォルダを削除しました',
      AppLang.zh: '文件夹已删除',
    },
    'alertDeleteFolderError': {
      AppLang.es: 'Error al eliminar',
      AppLang.en: 'Error deleting folder',
      AppLang.de: 'Fehler beim Löschen',
      AppLang.pt: 'Erro ao excluir a pasta',
      AppLang.fr: 'Erreur lors de la suppression',
      AppLang.ru: 'Ошибка при удалении',
      AppLang.ja: '削除中にエラーが発生しました',
      AppLang.zh: '删除文件夹失败',
    },
    'alertMoveFolder': {
      AppLang.es: '¿Estás seguro de mover la carpeta?',
      AppLang.en: 'Are you sure you want to move the folder?',
      AppLang.de: 'Möchtest du den Ordner verschieben?',
      AppLang.pt: 'Tem certeza de que deseja mover a pasta?',
      AppLang.fr: 'Êtes-vous sûr de vouloir déplacer le dossier ?',
      AppLang.ru: 'Вы уверены, что хотите переместить папку?',
      AppLang.ja: 'このフォルダを移動してもよろしいですか？',
      AppLang.zh: '确定要移动这个文件夹吗？',
    },
    'alertMoveFolderTitle': {
      AppLang.es: 'Cambiar de carpeta',
      AppLang.en: 'Change folder',
      AppLang.de: 'Ordner ändern',
      AppLang.pt: 'Mudar de pasta',
      AppLang.fr: 'Changer de dossier',
      AppLang.ru: 'Изменить папку',
      AppLang.ja: 'フォルダを変更',
      AppLang.zh: '更改文件夹',
    },
    'alertMovePendingFolder': {
      AppLang.es: 'Tienes una carpeta pendiente de mover',
      AppLang.en: 'You have a folder pending to move',
      AppLang.de: 'Du hast einen Ordner, der noch verschoben werden muss',
      AppLang.pt: 'Você tem uma pasta pendente para mover',
      AppLang.fr: 'Vous avez un dossier en attente de déplacement',
      AppLang.ru: 'У вас есть папка, ожидающая перемещения',
      AppLang.ja: '移動待ちのフォルダがあります',
      AppLang.zh: '有一个文件夹待移动',
    },

    // Tags
    'alertDeleteTagTitle': {
      AppLang.es: 'Eliminar etiqueta',
      AppLang.en: 'Delete tag',
      AppLang.de: 'Tag löschen',
      AppLang.pt: 'Excluir etiqueta',
      AppLang.fr: 'Supprimer le tag',
      AppLang.ru: 'Удалить тег',
      AppLang.ja: 'タグを削除',
      AppLang.zh: '删除标签',
    },
    'alertDeleteTagPermanent': {
      AppLang.es:
          '¿Estás seguro de eliminar permanentemente esta etiqueta? Se quitará de todas las notas.',
      AppLang.en:
          'Are you sure you want to permanently delete this tag? It will be removed from all notes.',
      AppLang.de:
          'Möchtest du dieses Tag dauerhaft löschen? Es wird aus allen Notizen entfernt.',
      AppLang.pt:
          'Tem certeza de que deseja excluir permanentemente esta etiqueta? Ela será removida de todas as notas.',
      AppLang.fr:
          'Êtes-vous sûr de vouloir supprimer définitivement ce tag ? Il sera retiré de toutes les notes.',
      AppLang.ru:
          'Вы уверены, что хотите навсегда удалить этот тег? Он будет удалён из всех заметок.',
      AppLang.ja: 'このタグを完全に削除してもよろしいですか？すべてのノートから削除されます。',
      AppLang.zh: '确定要永久删除此标签吗？它将从所有笔记中移除。',
    },
    'alertDeleteTagSuccess': {
      AppLang.es: 'Etiqueta eliminada para siempre',
      AppLang.en: 'Tag deleted permanently',
      AppLang.de: 'Tag dauerhaft gelöscht',
      AppLang.pt: 'Etiqueta excluída permanentemente',
      AppLang.fr: 'Tag supprimé définitivement',
      AppLang.ru: 'Тег удалён навсегда',
      AppLang.ja: 'タグを完全に削除しました',
      AppLang.zh: '标签已永久删除',
    },
    'alertDeleteTagError': {
      AppLang.es: 'Error al intentar borrar la etiqueta',
      AppLang.en: 'Error deleting tag',
      AppLang.de: 'Fehler beim Löschen des Tags',
      AppLang.pt: 'Erro ao excluir a etiqueta',
      AppLang.fr: 'Erreur lors de la suppression du tag',
      AppLang.ru: 'Ошибка при удалении тега',
      AppLang.ja: 'タグの削除中にエラーが発生しました',
      AppLang.zh: '删除标签失败',
    },

    // Banners
    'bannerPendingNote': {
      AppLang.es: 'Tienes una nota pendiente de almacenar',
      AppLang.en: 'You have a note pending to store',
      AppLang.de: 'Du hast eine Notiz, die noch gespeichert werden muss',
      AppLang.pt: 'Você tem uma nota pendente para armazenar',
      AppLang.fr: 'Vous avez une note en attente d’enregistrement',
      AppLang.ru: 'У вас есть заметка, которую нужно сохранить',
      AppLang.ja: '保存待ちのノートがあります',
      AppLang.zh: '有一条笔记待保存',
    },
    'bannerNotMove': {
      AppLang.es: 'No mover',
      AppLang.en: "Don't move",
      AppLang.de: 'Nicht verschieben',
      AppLang.pt: 'Não mover',
      AppLang.fr: 'Ne pas déplacer',
      AppLang.ru: 'Не перемещать',
      AppLang.ja: '移動しない',
      AppLang.zh: '不移动',
    },
    'discardAction': {
      AppLang.es: '¿Estás seguro de descartar la acción?',
      AppLang.en: 'Are you sure you want to discard the action?',
      AppLang.de: 'Möchtest du die Aktion verwerfen?',
      AppLang.pt: 'Tem certeza de que deseja descartar a ação?',
      AppLang.fr: 'Êtes-vous sûr de vouloir ignorer l’action ?',
      AppLang.ru: 'Вы уверены, что хотите отменить действие?',
      AppLang.ja: 'この操作を破棄してもよろしいですか？',
      AppLang.zh: '确定要放弃此操作吗？',
    },
    'alertDiscard': {
      AppLang.es: 'Descartar cambios',
      AppLang.en: 'Discard changes',
      AppLang.de: 'Änderungen verwerfen',
      AppLang.pt: 'Descartar alterações',
      AppLang.fr: 'Ignorer les modifications',
      AppLang.ru: 'Отменить изменения',
      AppLang.ja: '変更を破棄',
      AppLang.zh: '放弃更改',
    },
    'alertDiscardFormTitle': {
      AppLang.es: 'Falta el título. ¿Quieres descartarla?',
      AppLang.en: 'Missing title. Do you want to discard it?',
      AppLang.de: 'Titel fehlt. Möchtest du sie verwerfen?',
      AppLang.pt: 'Falta o título. Deseja descartá-la?',
      AppLang.fr: 'Titre manquant. Voulez-vous l’ignorer ?',
      AppLang.ru: 'Отсутствует заголовок. Отменить?',
      AppLang.ja: 'タイトルがありません。破棄しますか？',
      AppLang.zh: '缺少标题，要放弃吗？',
    },
  };
}
