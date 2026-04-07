import 'package:tag_links/core/locate/app_lang.dart';

final Map<String, Map<AppLang, String>> alertTranslations = {
  //notes
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
  // folders
  'createFolder': {AppLang.es: 'Crear carpeta', AppLang.en: 'Create folder'},

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
  'alertMoveFolderTitle':{
    AppLang.es: 'Cambiar carpeta',
    AppLang.en: 'Move folder'
  },
  'alertMovePendingFolder': {
    AppLang.es: 'Tienes una carpeta pendiente de mover',
    AppLang.en: 'You have a folder pending to move',
  },
  'alertMoveFolderErrorIsSameFolder': {
    AppLang.es: 'Error al mover carpeta. Es la misma carpeta.',
    AppLang.en: 'Error moving folder. It\'s the same folder.',
  },
  'alertMoveFolderErrorIsDeepFolder':{
    AppLang.es: 'No puedes almacenar carpetas aquí, elije otra carpeta.',
    AppLang.en: 'You cannot store folders here, please choose another folder.',
  },
  //banners
  'bannerPendingNote': {
    AppLang.es: 'Tienes una nota pendiente de almacenar',
    AppLang.en: 'You have a note pending to store',
  },
  'bannerNotMove': {AppLang.es: 'No mover', AppLang.en: 'Don\'t move'},
  'discardAction': {
    AppLang.es: '¿Estás seguro de descartar la acción?',
    AppLang.en: 'Are you sure you want to discard the action?',
  },
  //Form
  'alertDiscardFormTitle':{
    AppLang.es: 'Descartar cambios',
    AppLang.en: 'Discard changes',
  },
  'alertDiscardFormTitle':{
    AppLang.es: 'Falta el título. ¿Quieres descartarla?',
    AppLang.en: 'The title is missing. Do you want to discard it?',
  },
  'limitReached':{
    AppLang.es: 'Límite de niveles',
    AppLang.en: 'Level limit',
  },
  'flattenMessage':{
    AppLang.es: 'Esta carpeta tiene otras carpetas. Se moverán al inicio.',
    AppLang.en: 'This folder contains other folders. They will be moved to the beginning.',
  },
};
