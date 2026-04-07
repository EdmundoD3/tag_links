import '../app_lang.dart';

class TranslatesAlerts {
  const TranslatesAlerts();

  // --- Notas ---
  final String deleteNoteTitle =
      'alertDeleteNoteTitle'; // Mantengo el ID del mapa igual si quieres, pero la propiedad es corta
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
    },
    'alertDeleteNote': {
      AppLang.es: '¿Estás seguro de eliminar la nota?',
      AppLang.en: 'Are you sure you want to delete the note?',
    },
    'alertDeleteNoteSucces': {
      AppLang.es: 'Nota eliminada',
      AppLang.en: 'Note deleted',
    },
    'alertDeleteNoteError': {
      AppLang.es: 'Error al eliminar',
      AppLang.en: 'Error deleting note',
    },
    'alertMoveNoteTitle': {
      AppLang.es: 'Cambiar de carpeta',
      AppLang.en: 'Change folder',
    },
    'alertMoveNote': {
      AppLang.es: '¿Estás seguro de mover la nota?',
      AppLang.en: 'Are you sure you want to move the note?',
    },

    // Folders
    'alertDeleteFolderTitle': {
      AppLang.es: 'Eliminar carpeta',
      AppLang.en: 'Delete folder',
    },
    'alertDeleteFolder': {
      AppLang.es: '¿Estás seguro de eliminar la carpeta?',
      AppLang.en: 'Are you sure you want to delete the folder?',
    },
    'alertDeleteFolderSucces': {
      AppLang.es: 'Carpeta eliminada',
      AppLang.en: 'Folder deleted',
    },
    'alertDeleteFolderError': {
      AppLang.es: 'Error al eliminar',
      AppLang.en: 'Error deleting folder',
    },
    'alertMoveFolder': {
      AppLang.es: '¿Estás seguro de mover la carpeta?',
      AppLang.en: 'Are you sure you want to move the carpeta?',
    },
    'alertMoveFolderTitle': {
      AppLang.es: 'Cambiar de carpeta',
      AppLang.en: 'Change folder',
    },
    'alertMovePendingFolder': {
      AppLang.es: 'Tienes una carpeta pendiente de mover',
      AppLang.en: 'You have a folder pending to move',
    },

    // Tags 
    'alertDeleteTagTitle': {
      AppLang.es: 'Eliminar etiqueta',
      AppLang.en: 'Delete tag',
    },
    'alertDeleteTagPermanent': {
      AppLang.es: '¿Estás seguro de eliminar permanentemente esta etiqueta? Se quitará de todas las notas.',
      AppLang.en: 'Are you sure you want to permanently delete this tag? It will be removed from all notes.',
    },
    'alertDeleteTagSuccess': {
      AppLang.es: 'Etiqueta eliminada para siempre',
      AppLang.en: 'Tag deleted permanently',
    },
    'alertDeleteTagError': {
      AppLang.es: 'Error al intentar borrar la etiqueta',
      AppLang.en: 'Error deleting tag',
    },

    // Banners
    'bannerPendingNote': {
      AppLang.es: 'Tienes una nota pendiente de almacenar',
      AppLang.en: 'You have a note pending to store',
    },
    'bannerNotMove': {AppLang.es: 'No mover', AppLang.en: "Don't move"},
    'discardAction': {
      AppLang.es: '¿Estás seguro de descartar la acción?',
      AppLang.en: 'Are you sure you want to discard the action?',
    },
    'alertMoveFolderErrorIsDeepFolder': {
      AppLang.es: 'No puedes almacenar carpetas aquí, elije otra carpeta',
      AppLang.en: 'You can\'t store folders here, choose another folder',
    },
    'alertMoveFolderErrorIsSameFolder': {
      AppLang.es: 'No puedes mover una carpeta a sí misma',
      AppLang.en: 'You can\'t move a folder to itself',
    },
    'limitReached': {
      AppLang.es: 'Límite de niveles',
      AppLang.en: 'Limit reached',
    },
    'flattenMessage': {
      AppLang.es: 'Esta carpeta tiene hijos. Se moverán a la raíz.',
      AppLang.en: 'This folder has children. They will be moved to the root.',
    },

    //Form
    'alertDiscard': {
      AppLang.es: 'Descatar cambios',
      AppLang.en: 'Discard changes',
    },
    'alertDiscardFormTitle': {
      AppLang.es: 'Falta el título. ¿Quieres descartarla?',
      AppLang.en: 'Missing title. Do you want to discard it?',
    },


  };
}
