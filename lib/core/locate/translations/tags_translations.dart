// lib/core/locate/modules/tags_translate.dart
import '../app_lang.dart';

class TranslatesTags {
  const TranslatesTags();

  final String title = 'tagsTitle';
  final String nameField = 'tagName';
  final String create = 'createTag';
  final String delete = 'deleteTag';
  final String edit = 'editTag';
  final String label = 'tags';

  static const Map<String, Map<AppLang, String>> translations = {
    'tagsTitle': {
      AppLang.es: 'Etiquetas',
      AppLang.en: 'Tags',
      AppLang.de: 'Tags',
      AppLang.pt: 'Tags',
      AppLang.fr: 'Tags',
    },
    'tagName': {
      AppLang.es: 'Nombre del tag',
      AppLang.en: 'Tag name',
      AppLang.de: 'Tag-Name',
      AppLang.pt: 'Nome da tag',
      AppLang.fr: 'Nom du tag',
    },
    'createTag': {
      AppLang.es: 'Nuevo tag',
      AppLang.en: 'New tag',
      AppLang.de: 'Neuer Tag',
      AppLang.pt: 'Nova tag',
      AppLang.fr: 'Nouveau tag',
    },
    'deleteTag': {
      AppLang.es: 'Eliminar tag',
      AppLang.en: 'Delete tag',
      AppLang.de: 'Tag löschen',
      AppLang.pt: 'Excluir tag',
      AppLang.fr: 'Supprimer le tag',
    },
    'editTag': {
      AppLang.es: 'Editar tag',
      AppLang.en: 'Edit tag',
      AppLang.de: 'Tag bearbeiten',
      AppLang.pt: 'Editar tag',
      AppLang.fr: 'Modifier le tag',
    },
    'tags': {
      AppLang.es: 'Etiquetas',
      AppLang.en: 'Tags',
      AppLang.de: 'Tags',
      AppLang.pt: 'Tags',
      AppLang.fr: 'Tags',
    },
  };
}
