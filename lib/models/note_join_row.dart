
class NoteJoinRow {
  final String noteId;
  final String? folderId;
  final String title;
  final String? content;
  final String? color;
  final int createdAt;
  final int updatedAt;
  final int? syncAt;
  final bool isFavorite;

  final String? tagId;
  final String? tagName;

  final String? linkId;
  final String? linkUrl;
  final String? linkTitle;
  final String? linkDescription;
  final String? linkImage;
  final String? linkSiteName;

  NoteJoinRow.fromMap(Map<String, Object?> map)
    : noteId = map['note_id'] as String,
      folderId = map['folder_id'] as String?,
      title = map['title'] as String,
      content = map['content'] as String?,
      color = map['color'] as String?,
      createdAt = map['createdAt'] as int,
      updatedAt = map['updatedAt'] as int,
      syncAt = map['syncAt'] as int?,
      isFavorite = map['isFavorite'] == 1,
      tagId = map['tag_id'] as String?,
      tagName = map['tag_name'] as String?,
      linkId = map['link_id'] as String?,
      linkUrl = map['link_url'] as String?,
      linkTitle = map['link_title'] as String?,
      linkDescription = map['link_description'] as String?,
      linkImage = map['link_image'] as String?,
      linkSiteName = map['link_siteName'] as String?;

  static const String selectQuery = '''
    SELECT
      n.id AS note_id,
      n.folderId AS folder_id,
      n.title,
      n.content,
      n.color,
      n.createdAt,
      n.updatedAt,
      n.syncAt,
      n.isFavorite,

      t.id AS tag_id,
      t.name AS tag_name,

      lp.id AS link_id,
      lp.url AS link_url,
      lp.title AS link_title,
      lp.description AS link_description,
      lp.image AS link_image,
      lp.siteName AS link_siteName
    FROM notes n
    LEFT JOIN note_tags nt ON nt.noteId = n.id
    LEFT JOIN tags t ON t.id = nt.tagId
    LEFT JOIN link_previews lp ON lp.noteId = n.id
  ''';
}
