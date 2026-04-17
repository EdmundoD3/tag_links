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
      AppLang.fr: 'Enregistrer',
      AppLang.ru: 'Сохранить',
      AppLang.ja: '保存',
    },
    'close': {
      AppLang.es: 'Cerrar',
      AppLang.en: 'Close',
      AppLang.de: 'Schließen',
      AppLang.pt: 'Fechar',
      AppLang.fr: 'Fermer',
      AppLang.ru: 'Закрыть',
      AppLang.ja: '閉じる',
    },
    'edit': {
      AppLang.es: 'Editar',
      AppLang.en: 'Edit',
      AppLang.de: 'Bearbeiten',
      AppLang.pt: 'Editar',
      AppLang.fr: 'Modifier',
      AppLang.ru: 'Редактировать',
      AppLang.ja: '編集',
    },
    'copyText': {
      AppLang.es: 'Copiar',
      AppLang.en: 'Copy',
      AppLang.de: 'Kopieren',
      AppLang.pt: 'Copiar',
      AppLang.fr: 'Copier',
      AppLang.ru: 'Копировать',
      AppLang.ja: 'コピー',
    },
    'copiedText': {
      AppLang.es: 'Texto copiado',
      AppLang.en: 'Text copied',
      AppLang.de: 'Text kopiert',
      AppLang.pt: 'Texto copiado',
      AppLang.fr: 'Texte copié',
      AppLang.ru: 'Текст скопирован',
      AppLang.ja: 'コピーしました',
    },
    'delete': {
      AppLang.es: 'Eliminar',
      AppLang.en: 'Delete',
      AppLang.de: 'Löschen',
      AppLang.pt: 'Excluir',
      AppLang.fr: 'Supprimer',
      AppLang.ru: 'Удалить',
      AppLang.ja: '削除',
    },
    'accept': {
      AppLang.es: 'Aceptar',
      AppLang.en: 'Accept',
      AppLang.de: 'Akzeptieren',
      AppLang.pt: 'Aceitar',
      AppLang.fr: 'Accepter',
      AppLang.ru: 'Принять',
      AppLang.ja: '同意',
    },
    'cancel': {
      AppLang.es: 'Cancelar',
      AppLang.en: 'Cancel',
      AppLang.de: 'Abbrechen',
      AppLang.pt: 'Cancelar',
      AppLang.fr: 'Annuler',
      AppLang.ru: 'Отмена',
      AppLang.ja: 'キャンセル',
    },
    'discard': {
      AppLang.es: 'Descartar',
      AppLang.en: 'Discard',
      AppLang.de: 'Verwerfen',
      AppLang.pt: 'Descartar',
      AppLang.fr: 'Ignorer',
      AppLang.ru: 'Отменить',
      AppLang.ja: '破棄',
    },
    'notNow': {
      AppLang.es: "Ahora no",
      AppLang.en: 'Not now',
      AppLang.de: 'Jetzt nicht',
      AppLang.pt: 'Agora não',
      AppLang.fr: 'Pas maintenant',
      AppLang.ru: 'Не сейчас',
      AppLang.ja: '今はしない',
    },
    'store': {
      AppLang.es: 'Almacenar',
      AppLang.en: 'Store',
      AppLang.de: 'Speichern',
      AppLang.pt: 'Armazenar',
      AppLang.fr: 'Stocker',
      AppLang.ru: 'Сохранить',
      AppLang.ja: '保存',
    },
    'editAndStore': {
      AppLang.es: 'Editar y almacenar',
      AppLang.en: 'Edit and store',
      AppLang.de: 'Bearbeiten und speichern',
      AppLang.pt: 'Editar e armazenar',
      AppLang.fr: 'Modifier et enregistrer',
      AppLang.ru: 'Редактировать и сохранить',
      AppLang.ja: '編集して保存',
    },
    'moveDown': {
      AppLang.es: 'Mover',
      AppLang.en: 'Move',
      AppLang.de: 'Verschieben',
      AppLang.pt: 'Mover',
      AppLang.fr: 'Déplacer',
      AppLang.ru: 'Переместить',
      AppLang.ja: '移動',
    },
    'openLink': {
      AppLang.es: 'Abrir enlace',
      AppLang.en: 'Open link',
      AppLang.de: 'Link öffnen',
      AppLang.pt: 'Abrir link',
      AppLang.fr: 'Ouvrir le lien',
      AppLang.ru: 'Открыть ссылку',
      AppLang.ja: 'リンクを開く',
    },
    'copyLink': {
      AppLang.es: 'Copiar enlace',
      AppLang.en: 'Copy link',
      AppLang.de: 'Link kopieren',
      AppLang.pt: 'Copiar link',
      AppLang.fr: 'Copier le lien',
      AppLang.ru: 'Копировать ссылку',
      AppLang.ja: 'リンクをコピー',
    },
  };
}
