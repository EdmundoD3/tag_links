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
    },
    'alertDeleteNote': {
      AppLang.es: '¿Estás seguro de eliminar la nota?',
      AppLang.en: 'Are you sure you want to delete the note?',
      AppLang.de: 'Möchtest du die Notiz wirklich löschen?',
      AppLang.pt: 'Tem certeza de que deseja excluir a nota?',
      AppLang.fr: 'Êtes-vous sûr de vouloir supprimer la note ?',
      AppLang.ru: 'Вы уверены, что хотите удалить заметку?',
    },
    'alertDeleteNoteSucces': {
      AppLang.es: 'Nota eliminada',
      AppLang.en: 'Note deleted',
      AppLang.de: 'Notiz gelöscht',
      AppLang.pt: 'Nota excluída',
      AppLang.fr: 'Note supprimée',
      AppLang.ru: 'Заметка удалена',
    },
    'alertDeleteNoteError': {
      AppLang.es: 'Error al eliminar',
      AppLang.en: 'Error deleting note',
      AppLang.de: 'Fehler beim Löschen',
      AppLang.pt: 'Erro ao excluir a nota',
      AppLang.fr: 'Erreur lors de la suppression',
      AppLang.ru: 'Ошибка при удалении',
    },
    'alertMoveNoteTitle': {
      AppLang.es: 'Cambiar de carpeta',
      AppLang.en: 'Change folder',
      AppLang.de: 'Ordner ändern',
      AppLang.pt: 'Mudar de pasta',
      AppLang.fr: 'Changer de dossier',
      AppLang.ru: 'Изменить папку',
    },
    'alertMoveNote': {
      AppLang.es: '¿Estás seguro de mover la nota?',
      AppLang.en: 'Are you sure you want to move the note?',
      AppLang.de: 'Möchtest du die Notiz verschieben?',
      AppLang.pt: 'Tem certeza de que deseja mover a nota?',
      AppLang.fr: 'Êtes-vous sûr de vouloir déplacer la note ?',
      AppLang.ru: 'Вы уверены, что хотите переместить заметку?',
    },

    // Folders
    'alertDeleteFolderTitle': {
      AppLang.es: 'Eliminar carpeta',
      AppLang.en: 'Delete folder',
      AppLang.de: 'Ordner löschen',
      AppLang.pt: 'Excluir pasta',
      AppLang.fr: 'Supprimer le dossier',
      AppLang.ru: 'Удалить папку',
    },
    'alertDeleteFolder': {
      AppLang.es: '¿Estás seguro de eliminar la carpeta?',
      AppLang.en: 'Are you sure you want to delete the folder?',
      AppLang.de: 'Möchtest du den Ordner wirklich löschen?',
      AppLang.pt: 'Tem certeza de que deseja excluir a pasta?',
      AppLang.fr: 'Êtes-vous sûr de vouloir supprimer le dossier ?',
      AppLang.ru: 'Вы уверены, что хотите удалить папку?',
    },
    'alertDeleteFolderSucces': {
      AppLang.es: 'Carpeta eliminada',
      AppLang.en: 'Folder deleted',
      AppLang.de: 'Ordner gelöscht',
      AppLang.pt: 'Pasta excluída',
      AppLang.fr: 'Dossier supprimé',
      AppLang.ru: 'Папка удалена',
    },
    'alertDeleteFolderError': {
      AppLang.es: 'Error al eliminar',
      AppLang.en: 'Error deleting folder',
      AppLang.de: 'Fehler beim Löschen',
      AppLang.pt: 'Erro ao excluir a pasta',
      AppLang.fr: 'Erreur lors de la suppression',
      AppLang.ru: 'Ошибка при удалении',
    },
    'alertMoveFolder': {
      AppLang.es: '¿Estás seguro de mover la carpeta?',
      AppLang.en: 'Are you sure you want to move the folder?',
      AppLang.de: 'Möchtest du den Ordner verschieben?',
      AppLang.pt: 'Tem certeza de que deseja mover a pasta?',
      AppLang.fr: 'Êtes-vous sûr de vouloir déplacer le dossier ?',
      AppLang.ru: 'Вы уверены, что хотите переместить папку?',
    },
    'alertMoveFolderTitle': {
      AppLang.es: 'Cambiar de carpeta',
      AppLang.en: 'Change folder',
      AppLang.de: 'Ordner ändern',
      AppLang.pt: 'Mudar de pasta',
      AppLang.fr: 'Changer de dossier',
      AppLang.ru: 'Изменить папку',
    },
    'alertMovePendingFolder': {
      AppLang.es: 'Tienes una carpeta pendiente de mover',
      AppLang.en: 'You have a folder pending to move',
      AppLang.de: 'Du hast einen Ordner, der noch verschoben werden muss',
      AppLang.pt: 'Você tem uma pasta pendente para mover',
      AppLang.fr: 'Vous avez un dossier en attente de déplacement',
      AppLang.ru: 'У вас есть папка, ожидающая перемещения',
    },

    // Tags
    'alertDeleteTagTitle': {
      AppLang.es: 'Eliminar etiqueta',
      AppLang.en: 'Delete tag',
      AppLang.de: 'Tag löschen',
      AppLang.pt: 'Excluir etiqueta',
      AppLang.fr: 'Supprimer le tag',
      AppLang.ru: 'Удалить тег',
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
    },
    'alertDeleteTagSuccess': {
      AppLang.es: 'Etiqueta eliminada para siempre',
      AppLang.en: 'Tag deleted permanently',
      AppLang.de: 'Tag dauerhaft gelöscht',
      AppLang.pt: 'Etiqueta excluída permanentemente',
      AppLang.fr: 'Tag supprimé définitivement',
      AppLang.ru: 'Тег удалён навсегда',
    },
    'alertDeleteTagError': {
      AppLang.es: 'Error al intentar borrar la etiqueta',
      AppLang.en: 'Error deleting tag',
      AppLang.de: 'Fehler beim Löschen des Tags',
      AppLang.pt: 'Erro ao excluir a etiqueta',
      AppLang.fr: 'Erreur lors de la suppression du tag',
      AppLang.ru: 'Ошибка при удалении тега',
    },

    // Banners
    'bannerPendingNote': {
      AppLang.es: 'Tienes una nota pendiente de almacenar',
      AppLang.en: 'You have a note pending to store',
      AppLang.de: 'Du hast eine Notiz, die noch gespeichert werden muss',
      AppLang.pt: 'Você tem uma nota pendente para armazenar',
      AppLang.fr: 'Vous avez une note en attente d’enregistrement',
      AppLang.ru: 'У вас есть заметка, которую нужно сохранить',
    },
    'bannerNotMove': {
      AppLang.es: 'No mover',
      AppLang.en: "Don't move",
      AppLang.de: 'Nicht verschieben',
      AppLang.pt: 'Não mover',
      AppLang.fr: 'Ne pas déplacer',
      AppLang.ru: 'Не перемещать',
    },
    'discardAction': {
      AppLang.es: '¿Estás seguro de descartar la acción?',
      AppLang.en: 'Are you sure you want to discard the action?',
      AppLang.de: 'Möchtest du die Aktion verwerfen?',
      AppLang.pt: 'Tem certeza de que deseja descartar a ação?',
      AppLang.fr: 'Êtes-vous sûr de vouloir ignorer l’action ?',
      AppLang.ru: 'Вы уверены, что хотите отменить действие?',
    },
    'alertMoveFolderErrorIsDeepFolder': {
      AppLang.es: 'No puedes almacenar carpetas aquí, elije otra carpeta',
      AppLang.en: 'You can\'t store folders here, choose another folder',
      AppLang.de:
          'Hier können keine Ordner gespeichert werden, wähle einen anderen Ordner',
      AppLang.pt: 'Você não pode armazenar pastas aqui, escolha outra pasta',
      AppLang.fr:
          'Vous ne pouvez pas stocker de dossiers ici, choisissez un autre dossier',
      AppLang.ru: 'Вы не можете сохранять папки здесь, выберите другую папку',
    },
    'alertMoveFolderErrorIsSameFolder': {
      AppLang.es: 'No puedes mover una carpeta a sí misma',
      AppLang.en: 'You can\'t move a folder to itself',
      AppLang.de: 'Ein Ordner kann nicht in sich selbst verschoben werden',
      AppLang.pt: 'Você não pode mover uma pasta para ela mesma',
      AppLang.fr: 'Vous ne pouvez pas déplacer un dossier dans lui-même',
      AppLang.ru: 'Нельзя переместить папку в саму себя',
    },
    'limitReached': {
      AppLang.es: 'Límite de niveles',
      AppLang.en: 'Limit reached',
      AppLang.de: 'Limit erreicht',
      AppLang.pt: 'Limite atingido',
      AppLang.fr: 'Limite atteint',
      AppLang.ru: 'Достигнут лимит',
    },
    'flattenMessage': {
      AppLang.es: 'Esta carpeta tiene hijos. Se moverán a la raíz.',
      AppLang.en: 'This folder has children. They will be moved to the root.',
      AppLang.de:
          'Dieser Ordner hat Unterordner. Sie werden ins Hauptverzeichnis verschoben.',
      AppLang.pt: 'Esta pasta tem subpastas. Elas serão movidas para a raiz.',
      AppLang.fr:
          'Ce dossier contient des sous-dossiers. Ils seront déplacés à la racine.',
      AppLang.ru:
          'В этой папке есть вложенные элементы. Они будут перемещены в корень.',
    },

    // Form
    'alertDiscard': {
      AppLang.es: 'Descartar cambios',
      AppLang.en: 'Discard changes',
      AppLang.de: 'Änderungen verwerfen',
      AppLang.pt: 'Descartar alterações',
      AppLang.fr: 'Ignorer les modifications',
      AppLang.ru: 'Отменить изменения',
    },
    'alertDiscardFormTitle': {
      AppLang.es: 'Falta el título. ¿Quieres descartarla?',
      AppLang.en: 'Missing title. Do you want to discard it?',
      AppLang.de: 'Titel fehlt. Möchtest du sie verwerfen?',
      AppLang.pt: 'Falta o título. Deseja descartá-la?',
      AppLang.fr: 'Titre manquant. Voulez-vous l’ignorer ?',
      AppLang.ru: 'Отсутствует заголовок. Отменить?',
    },
  };
}
