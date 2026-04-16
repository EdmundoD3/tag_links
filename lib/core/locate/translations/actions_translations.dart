// lib/core/locate/modules/actions_translate.dart
import '../app_lang.dart';

class TranslatesActions {
  const TranslatesActions();

  final String save = 'save';
  final String close = 'close';
  final String edit = 'edit';
  final String copy = 'copyText';
  final String copiedSuccess = 'copiedText';
  final String delete = 'delete';
  final String accept = 'accept';
  final String cancel = 'cancel';
  final String discard = 'discard';
  final String notNow = 'notNow';
  final String store = 'store';
  final String editAndStore = 'editAndStore';
  final String move = 'moveDown';
  final String openLink = 'openLink';
  final String copyLink = 'copyLink';

  static const Map<String, Map<AppLang, String>> translations = {
    'save': {
      AppLang.es: 'Guardar',
      AppLang.en: 'Save',
      AppLang.de: 'Speichern',
    },
    'close': {
      AppLang.es: 'Cerrar',
      AppLang.en: 'Close',
      AppLang.de: 'Schließen',
    },
    'edit': {
      AppLang.es: 'Editar',
      AppLang.en: 'Edit',
      AppLang.de: 'Bearbeiten',
    },
    'copyText': {
      AppLang.es: 'Copiar',
      AppLang.en: 'Copy',
      AppLang.de: 'Kopieren',
    },
    'copiedText': {
      AppLang.es: 'Texto copiado',
      AppLang.en: 'Text copied',
      AppLang.de: 'Text kopiert',
    },
    'delete': {
      AppLang.es: 'Eliminar',
      AppLang.en: 'Delete',
      AppLang.de: 'Löschen',
    },
    'accept': {
      AppLang.es: 'Aceptar',
      AppLang.en: 'Accept',
      AppLang.de: 'Akzeptieren',
    },
    'cancel': {
      AppLang.es: 'Cancelar',
      AppLang.en: 'Cancel',
      AppLang.de: 'Abbrechen',
    },
    'discard': {
      AppLang.es: 'Descartar',
      AppLang.en: 'Discard',
      AppLang.de: 'Verwerfen',
    },
    'notNow': {
      AppLang.es: "Ahora no",
      AppLang.en: 'Not now',
      AppLang.de: 'Jetzt nicht',
    },
    'store': {
      AppLang.es: 'Almacenar',
      AppLang.en: 'Store',
      AppLang.de: 'Speichern',
    },
    'editAndStore': {
      AppLang.es: 'Editar y almacenar',
      AppLang.en: 'Edit and store',
      AppLang.de: 'Bearbeiten und speichern',
    },
    'moveDown': {
      AppLang.es: 'Mover',
      AppLang.en: 'Move',
      AppLang.de: 'Verschieben',
    },
    'openLink': {
      AppLang.es: 'Abrir enlace',
      AppLang.en: 'Open link',
      AppLang.de: 'Link öffnen',
    },
    'copyLink': {
      AppLang.es: 'Copiar enlace',
      AppLang.en: 'Copy link',
      AppLang.de: 'Link kopieren',
    },
  };
}