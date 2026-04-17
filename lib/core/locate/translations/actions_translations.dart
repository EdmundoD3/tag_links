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
    AppLang.pt: 'Salvar',
  },
  'close': {
    AppLang.es: 'Cerrar',
    AppLang.en: 'Close',
    AppLang.de: 'Schließen',
    AppLang.pt: 'Fechar',
  },
  'edit': {
    AppLang.es: 'Editar',
    AppLang.en: 'Edit',
    AppLang.de: 'Bearbeiten',
    AppLang.pt: 'Editar',
  },
  'copyText': {
    AppLang.es: 'Copiar',
    AppLang.en: 'Copy',
    AppLang.de: 'Kopieren',
    AppLang.pt: 'Copiar',
  },
  'copiedText': {
    AppLang.es: 'Texto copiado',
    AppLang.en: 'Text copied',
    AppLang.de: 'Text kopiert',
    AppLang.pt: 'Texto copiado',
  },
  'delete': {
    AppLang.es: 'Eliminar',
    AppLang.en: 'Delete',
    AppLang.de: 'Löschen',
    AppLang.pt: 'Excluir',
  },
  'accept': {
    AppLang.es: 'Aceptar',
    AppLang.en: 'Accept',
    AppLang.de: 'Akzeptieren',
    AppLang.pt: 'Aceitar',
  },
  'cancel': {
    AppLang.es: 'Cancelar',
    AppLang.en: 'Cancel',
    AppLang.de: 'Abbrechen',
    AppLang.pt: 'Cancelar',
  },
  'discard': {
    AppLang.es: 'Descartar',
    AppLang.en: 'Discard',
    AppLang.de: 'Verwerfen',
    AppLang.pt: 'Descartar',
  },
  'notNow': {
    AppLang.es: "Ahora no",
    AppLang.en: 'Not now',
    AppLang.de: 'Jetzt nicht',
    AppLang.pt: 'Agora não',
  },
  'store': {
    AppLang.es: 'Almacenar',
    AppLang.en: 'Store',
    AppLang.de: 'Speichern',
    AppLang.pt: 'Armazenar',
  },
  'editAndStore': {
    AppLang.es: 'Editar y almacenar',
    AppLang.en: 'Edit and store',
    AppLang.de: 'Bearbeiten und speichern',
    AppLang.pt: 'Editar e armazenar',
  },
  'moveDown': {
    AppLang.es: 'Mover',
    AppLang.en: 'Move',
    AppLang.de: 'Verschieben',
    AppLang.pt: 'Mover',
  },
  'openLink': {
    AppLang.es: 'Abrir enlace',
    AppLang.en: 'Open link',
    AppLang.de: 'Link öffnen',
    AppLang.pt: 'Abrir link',
  },
  'copyLink': {
    AppLang.es: 'Copiar enlace',
    AppLang.en: 'Copy link',
    AppLang.de: 'Link kopieren',
    AppLang.pt: 'Copiar link',
  },
};
}