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
    'save': {AppLang.es: 'Guardar', AppLang.en: 'Save'},
    'close': {AppLang.es: 'Cerrar', AppLang.en: 'Close'},
    'edit': {AppLang.es: 'Editar', AppLang.en: 'Edit'},
    'copyText': {AppLang.es: 'Copiar', AppLang.en: 'Copy'},
    'copiedText': {AppLang.es: 'Texto copiado', AppLang.en: 'Text copied'},
    'delete': {AppLang.es: 'Eliminar', AppLang.en: 'Delete'},
    'accept': {AppLang.es: 'Aceptar', AppLang.en: 'Accept'},
    'cancel': {AppLang.es: 'Cancelar', AppLang.en: 'Cancel'},
    'discard': {AppLang.es: 'Descartar', AppLang.en: 'Discard'},
    'notNow':{AppLang.es: "Ahora no", AppLang.en: 'Not now'},
    'store': {AppLang.es: 'Almacenar', AppLang.en: 'Store'},
    'editAndStore': {AppLang.es: 'Editar y almacenar', AppLang.en: 'Edit and store'},
    'moveDown': {AppLang.es: 'Mover', AppLang.en: 'Move'},
    'openLink': {AppLang.es: 'Abrir enlace', AppLang.en: 'Open link'},
    'copyLink': {AppLang.es: 'Copiar enlace', AppLang.en: 'Copy link'},
  };
}