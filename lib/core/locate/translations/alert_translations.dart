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
  },
  'alertDeleteNote': {
    AppLang.es: '¿Estás seguro de eliminar la nota?',
    AppLang.en: 'Are you sure you want to delete the note?',
    AppLang.de: 'Möchtest du die Notiz wirklich löschen?',
    AppLang.pt: 'Tem certeza de que deseja excluir a nota?',
  },
  'alertDeleteNoteSucces': {
    AppLang.es: 'Nota eliminada',
    AppLang.en: 'Note deleted',
    AppLang.de: 'Notiz gelöscht',
    AppLang.pt: 'Nota excluída',
  },
  'alertDeleteNoteError': {
    AppLang.es: 'Error al eliminar',
    AppLang.en: 'Error deleting note',
    AppLang.de: 'Fehler beim Löschen',
    AppLang.pt: 'Erro ao excluir a nota',
  },
  'alertMoveNoteTitle': {
    AppLang.es: 'Cambiar de carpeta',
    AppLang.en: 'Change folder',
    AppLang.de: 'Ordner ändern',
    AppLang.pt: 'Mudar de pasta',
  },
  'alertMoveNote': {
    AppLang.es: '¿Estás seguro de mover la nota?',
    AppLang.en: 'Are you sure you want to move the note?',
    AppLang.de: 'Möchtest du die Notiz verschieben?',
    AppLang.pt: 'Tem certeza de que deseja mover a nota?',
  },

  // Folders
  'alertDeleteFolderTitle': {
    AppLang.es: 'Eliminar carpeta',
    AppLang.en: 'Delete folder',
    AppLang.de: 'Ordner löschen',
    AppLang.pt: 'Excluir pasta',
  },
  'alertDeleteFolder': {
    AppLang.es: '¿Estás seguro de eliminar la carpeta?',
    AppLang.en: 'Are you sure you want to delete the folder?',
    AppLang.de: 'Möchtest du den Ordner wirklich löschen?',
    AppLang.pt: 'Tem certeza de que deseja excluir a pasta?',
  },
  'alertDeleteFolderSucces': {
    AppLang.es: 'Carpeta eliminada',
    AppLang.en: 'Folder deleted',
    AppLang.de: 'Ordner gelöscht',
    AppLang.pt: 'Pasta excluída',
  },
  'alertDeleteFolderError': {
    AppLang.es: 'Error al eliminar',
    AppLang.en: 'Error deleting folder',
    AppLang.de: 'Fehler beim Löschen',
    AppLang.pt: 'Erro ao excluir a pasta',
  },
  'alertMoveFolder': {
    AppLang.es: '¿Estás seguro de mover la carpeta?',
    AppLang.en: 'Are you sure you want to move the carpeta?',
    AppLang.de: 'Möchtest du den Ordner verschieben?',
    AppLang.pt: 'Tem certeza de que deseja mover a pasta?',
  },
  'alertMoveFolderTitle': {
    AppLang.es: 'Cambiar de carpeta',
    AppLang.en: 'Change folder',
    AppLang.de: 'Ordner ändern',
    AppLang.pt: 'Mudar de pasta',
  },
  'alertMovePendingFolder': {
    AppLang.es: 'Tienes una carpeta pendiente de mover',
    AppLang.en: 'You have a folder pending to move',
    AppLang.de: 'Du hast einen Ordner, der noch verschoben werden muss',
    AppLang.pt: 'Você tem uma pasta pendente para mover',
  },

  // Tags
  'alertDeleteTagTitle': {
    AppLang.es: 'Eliminar etiqueta',
    AppLang.en: 'Delete tag',
    AppLang.de: 'Tag löschen',
    AppLang.pt: 'Excluir etiqueta',
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
  },
  'alertDeleteTagSuccess': {
    AppLang.es: 'Etiqueta eliminada para siempre',
    AppLang.en: 'Tag deleted permanently',
    AppLang.de: 'Tag dauerhaft gelöscht',
    AppLang.pt: 'Etiqueta excluída permanentemente',
  },
  'alertDeleteTagError': {
    AppLang.es: 'Error al intentar borrar la etiqueta',
    AppLang.en: 'Error deleting tag',
    AppLang.de: 'Fehler beim Löschen des Tags',
    AppLang.pt: 'Erro ao excluir a etiqueta',
  },

  // Banners
  'bannerPendingNote': {
    AppLang.es: 'Tienes una nota pendiente de almacenar',
    AppLang.en: 'You have a note pending to store',
    AppLang.de: 'Du hast eine Notiz, die noch gespeichert werden muss',
    AppLang.pt: 'Você tem uma nota pendente para armazenar',
  },
  'bannerNotMove': {
    AppLang.es: 'No mover',
    AppLang.en: "Don't move",
    AppLang.de: 'Nicht verschieben',
    AppLang.pt: 'Não mover',
  },
  'discardAction': {
    AppLang.es: '¿Estás seguro de descartar la acción?',
    AppLang.en: 'Are you sure you want to discard the action?',
    AppLang.de: 'Möchtest du die Aktion verwerfen?',
    AppLang.pt: 'Tem certeza de que deseja descartar a ação?',
  },
  'alertMoveFolderErrorIsDeepFolder': {
    AppLang.es: 'No puedes almacenar carpetas aquí, elije otra carpeta',
    AppLang.en: 'You can\'t store folders here, choose another folder',
    AppLang.de: 'Hier können keine Ordner gespeichert werden, wähle einen anderen Ordner',
    AppLang.pt: 'Você não pode armazenar pastas aqui, escolha outra pasta',
  },
  'alertMoveFolderErrorIsSameFolder': {
    AppLang.es: 'No puedes mover una carpeta a sí misma',
    AppLang.en: 'You can\'t move a folder to itself',
    AppLang.de: 'Ein Ordner kann nicht in sich selbst verschoben werden',
    AppLang.pt: 'Você não pode mover uma pasta para ela mesma',
  },
  'limitReached': {
    AppLang.es: 'Límite de niveles',
    AppLang.en: 'Limit reached',
    AppLang.de: 'Limit erreicht',
    AppLang.pt: 'Limite atingido',
  },
  'flattenMessage': {
    AppLang.es: 'Esta carpeta tiene hijos. Se moverán a la raíz.',
    AppLang.en: 'This folder has children. They will be moved to the root.',
    AppLang.de: 'Dieser Ordner hat Unterordner. Sie werden ins Hauptverzeichnis verschoben.',
    AppLang.pt: 'Esta pasta tem subpastas. Elas serão movidas para a raiz.',
  },

  // Form
  'alertDiscard': {
    AppLang.es: 'Descatar cambios',
    AppLang.en: 'Discard changes',
    AppLang.de: 'Änderungen verwerfen',
    AppLang.pt: 'Descartar alterações',
  },
  'alertDiscardFormTitle': {
    AppLang.es: 'Falta el título. ¿Quieres descartarla?',
    AppLang.en: 'Missing title. Do you want to discard it?',
    AppLang.de: 'Titel fehlt. Möchtest du sie verwerfen?',
    AppLang.pt: 'Falta o título. Deseja descartá-la?',
  },
};
}