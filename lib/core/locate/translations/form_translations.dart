import '../app_lang.dart';

class TranslatesForms {
  const TranslatesForms();

  // --- Carpetas (Folders) ---
  final String folderName = 'formFolderTitle';
  final String folderNameRequired = 'formFolderTitleRequired';
  final String folderDescription = 'formFolderDescription';
  final String moveToFolder = 'moveToFolder';
  final String newFolder = 'newFolder';
  final String editFolder = 'editFolder';

  // --- Notas (Notes) ---
  final String newNote = 'newNote';
  final String fastNote = 'fastNote';
  final String hiddenFastNote = 'hiddenFastNote';
  final String content = 'content';
  final String title = 'title';

  static const Map<String, Map<AppLang, String>> translations = {
    // Folder Form
    'formFolderTitle': {
      AppLang.es: 'Nombre de la carpeta',
      AppLang.en: 'Folder name',
      AppLang.de: 'Ordnername',
      AppLang.pt: 'Nome da pasta',
      AppLang.fr: 'Nom du dossier',
      AppLang.ru: 'Название папки',
      AppLang.ja: 'フォルダ名',
      AppLang.zh: '文件夹名称',
    },
    'formFolderTitleRequired': {
      AppLang.es: 'El título es obligatorio',
      AppLang.en: 'The title is required',
      AppLang.de: 'Titel ist erforderlich',
      AppLang.pt: 'O título é obrigatório',
      AppLang.fr: 'Le titre est obligatoire',
      AppLang.ru: 'Название обязательно',
      AppLang.ja: 'タイトルは必須です',
      AppLang.zh: '标题不能为空',
    },
    'formFolderDescription': {
      AppLang.es: 'Descripción',
      AppLang.en: 'Description',
      AppLang.de: 'Beschreibung',
      AppLang.pt: 'Descrição',
      AppLang.fr: 'Description',
      AppLang.ru: 'Описание',
      AppLang.ja: '説明',
      AppLang.zh: '描述',
    },
    'moveToFolder': {
      AppLang.es: 'Mover',
      AppLang.en: 'Move',
      AppLang.de: 'Verschieben',
      AppLang.pt: 'Mover',
      AppLang.fr: 'Déplacer',
      AppLang.ru: 'Переместить',
      AppLang.ja: '移動',
      AppLang.zh: '移动',
    },
    'newFolder': {
      AppLang.es: 'Nueva carpeta',
      AppLang.en: 'New folder',
      AppLang.de: 'Neuer Ordner',
      AppLang.pt: 'Nova pasta',
      AppLang.fr: 'Nouveau dossier',
      AppLang.ru: 'Новая папка',
      AppLang.ja: '新しいフォルダ',
      AppLang.zh: '新建文件夹',
    },
    'editFolder': {
      AppLang.es: 'Editar carpeta',
      AppLang.en: 'Edit folder',
      AppLang.de: 'Ordner bearbeiten',
      AppLang.pt: 'Editar pasta',
      AppLang.fr: 'Modifier le dossier',
      AppLang.ru: 'Редактировать папку',
      AppLang.ja: 'フォルダを編集',
      AppLang.zh: '编辑文件夹',
    },

    // Note Form
    'newNote': {
      AppLang.es: 'Nueva nota',
      AppLang.en: 'New note',
      AppLang.de: 'Neue Notiz',
      AppLang.pt: 'Nova nota',
      AppLang.fr: 'Nouvelle note',
      AppLang.ru: 'Новая заметка',
      AppLang.ja: '新しいノート',
      AppLang.zh: '新建笔记',
    },
    'fastNote': {
      AppLang.es: 'Nota rápida',
      AppLang.en: 'Fast note',
      AppLang.de: 'Schnelle Notiz',
      AppLang.pt: 'Nota rápida',
      AppLang.fr: 'Note rapide',
      AppLang.ru: 'Быстрая заметка',
      AppLang.ja: 'クイックノート',
      AppLang.zh: '快速笔记',
    },
    'hiddenFastNote': {
      AppLang.es: 'Ocultar',
      AppLang.en: 'Hide',
      AppLang.de: 'Ausblenden',
      AppLang.pt: 'Ocultar',
      AppLang.fr: 'Masquer',
      AppLang.ru: 'Скрыть',
      AppLang.ja: '非表示',
      AppLang.zh: '隐藏',
    },
    'content': {
      AppLang.es: 'Contenido',
      AppLang.en: 'Content',
      AppLang.de: 'Inhalt',
      AppLang.pt: 'Conteúdo',
      AppLang.fr: 'Contenu',
      AppLang.ru: 'Содержимое',
      AppLang.ja: '内容',
      AppLang.zh: '内容',
    },
    'title': {
      AppLang.es: 'Título',
      AppLang.en: 'Title',
      AppLang.de: 'Titel',
      AppLang.pt: 'Título',
      AppLang.fr: 'Titre',
      AppLang.ru: 'Заголовок',
      AppLang.ja: 'タイトル',
      AppLang.zh: '标题',
    },
  };
}
