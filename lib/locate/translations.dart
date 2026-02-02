import 'package:tag_links/locate/app_lang.dart';

final Map<String, Map<AppLang, String>> translations = {
  //homePage
  'appName': {AppLang.es: 'Tag Links', AppLang.en: 'Tag Links'},
  'pendingNotesTitle': {
    AppLang.es: 'Elige una carpeta donde almacenar la nota',
    AppLang.en: 'Choose a folder where to store the note',
  },
  'pendingNotesConfirmTitle': {
    AppLang.es: 'No almacenar la nota',
    AppLang.en: 'Don\'t store the note',
  },
  'pendingNotesConfirMessage': {
    AppLang.es: '¿Estás seguro de descartar la nota?',
    AppLang.en: 'Are you sure you want to discard the note?',
  },
  //folderPage

  //formFolder
  'formFolderTitle': {
    AppLang.es: 'Nombre de la carpeta',
    AppLang.en: 'Folder name',
  },
  'formFolderTitleRequired': {
    AppLang.es: 'El título es obligatorio',
    AppLang.en: 'The title is required',
  },
  'formFolderDescription': {
    AppLang.es: 'Descripción',
    AppLang.en: 'Description',
  },

  //helpers Note
  'fabAddNote': {AppLang.es: 'Agregar nota', AppLang.en: 'Add note'},
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
  'copiedText': {AppLang.es: 'Texto copiado', AppLang.en: 'Text copied'},
  'copyLink': {AppLang.es: 'Copiar enlace', AppLang.en: 'Copy link'},
  'notOpenLink': {
    AppLang.es: 'No se encontró una app para abrir este enlace',
    AppLang.en: 'No app found to open this link',
  },
  'errorOpenLink': {
    AppLang.es: 'URL no válida o mal formada',
    AppLang.en: 'Invalid URL or malformed',
  },
  'emptyNotes': {AppLang.es: 'No hay notas', AppLang.en: 'No notes'},
  'goToFolder': {AppLang.es: 'Ir a la carpeta', AppLang.en: 'Go to folder'},

  //helpers Folder
  'fabAddFolder': {AppLang.es: 'Agregar carpeta', AppLang.en: 'Add folder'},
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
  'alertMovePendingFolder': {
    AppLang.es: 'Tienes una carpeta pendiente de mover',
    AppLang.en: 'You have a folder pending to move',
  },

  'noFolders': {
    AppLang.es: 'No hay carpetas',
    AppLang.en: 'No folders',
  },
  //tags
  'tagsTitle': {AppLang.es: 'Etiquetas', AppLang.en: 'Tags'},
  'tagName': {AppLang.es: 'Nombre del tag', AppLang.en: 'Tag name'},
  'createTag': {AppLang.es: 'Crear nuevo tag', AppLang.en: 'Create new tag'},
  'deleteTag': {AppLang.es: 'Eliminar tag', AppLang.en: 'Delete tag'},
  'editTag': {AppLang.es: 'Editar tag', AppLang.en: 'Edit tag'},

  //settings
  'settingsTitle': {AppLang.es: 'Configuración', AppLang.en: 'Settings'},
  'supportProject': {
    AppLang.es: 'Apoya el proyecto',
    AppLang.en: 'Support the project',
  },
  //helpers
  'title': {AppLang.es: 'Título', AppLang.en: 'Title'},
  'titleRequired': {
    AppLang.es: 'El título es obligatorio',
    AppLang.en: 'The title is required',
  },
  'content': {AppLang.es: 'Contenido', AppLang.en: 'Content'},
  'tags': {AppLang.es: 'Etiquetas', AppLang.en: 'Tags'},
  'openLink': {AppLang.es: 'Abrir enlace', AppLang.en: 'Open link'},
  'save': {AppLang.es: 'Guardar', AppLang.en: 'Save'},
  'close': {AppLang.es: 'Cerrar', AppLang.en: 'Close'},
  'edit': {AppLang.es: 'Editar', AppLang.en: 'Edit'},
  'copyText': {AppLang.es: 'Copiar', AppLang.en: 'Copy'},
  'delete': {AppLang.es: 'Eliminar', AppLang.en: 'Delete'},
  'cancel': {AppLang.es: 'Cancelar', AppLang.en: 'Cancel'},
  'discard':{
    AppLang.es: 'Descartar',
    AppLang.en: 'Discard',
  },
  'store':{
    AppLang.es: 'Almacenar',
    AppLang.en: 'Store',
  },
  'editAndStore': {
    AppLang.es: 'Editar y almacenar',
    AppLang.en: 'Edit and store',
  },
  
  'markAsFavorite': {
    AppLang.es: 'Marcar como favorito',
    AppLang.en: 'Mark as favorite',
  },
  'searchHintText': {AppLang.es: 'Buscar...', AppLang.en: 'Search...'},
  'alertMoveToFolder': {
    AppLang.es: 'Cambiar de carpeta',
    AppLang.en: 'Change folder',
  },
  //banners
  'bannerPendingNote': {
    AppLang.es: 'Tienes una nota pendiente de almacenar',
    AppLang.en: 'You have a note pending to store',
  },
  'bannerNotMove': {
    AppLang.es: 'No mover',
    AppLang.en: 'Don\'t move',
  },
  'discardAction':{
    AppLang.es: '¿Estás seguro de descartar la acción?',
    AppLang.en: 'Are you sure you want to discard the action?',
  }
};
