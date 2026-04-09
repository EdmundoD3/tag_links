class NoteJoinRow {
  // --- Datos de la Nota ---
  final String noteId;
  final String? folderId;
  final String fileId;
  final String title;
  final String? content;
  final String? color;
  final int createdAt;
  final int updatedAt;
  final bool isFavorite;

  // --- Datos del Tag (Estandarizado a Title) ---
  final String? tagId;
  final String? tagTitle; // ✅ Antes tagName
  final String? tagFileId;
  final bool? tagIsFavorite;
  final int? tagUpdatedAt;
  final int? tagUsageCount;

  // --- Datos del Link Preview ---
  final String? linkId;
  final String? linkUrl;
  final String? linkTitle;
  final String? linkDescription;
  final String? linkImage;
  final String? linkSiteName;

  NoteJoinRow.fromMap(Map<String, Object?> map)
      : // Mapeo de Nota
        noteId = map['note_id'] as String,
        folderId = map['note_folder_id'] as String?,
        fileId = map['note_fileId'] as String,
        title = map['note_title'] as String,
        content = map['note_content'] as String?,
        color = map['note_color'] as String?,
        createdAt = map['note_createdAt'] as int,
        updatedAt = map['note_updatedAt'] as int,
        isFavorite = map['note_isFavorite'] == 1,
        
        // Mapeo de Tag (Coincidiendo con t.title)
        tagId = map['tag_id'] as String?,
        tagTitle = map['tag_title'] as String?, // ✅ Antes tag_name
        tagFileId = map['tag_fileId'] as String?,
        tagIsFavorite = map['tag_isFavorite'] == null ? null : map['tag_isFavorite'] == 1,
        tagUpdatedAt = map['tag_updatedAt'] as int?,
        tagUsageCount = map['tag_usageCount'] as int?,

        // Mapeo de Link
        linkId = map['link_id'] as String?,
        linkUrl = map['link_url'] as String?,
        linkTitle = map['link_title'] as String?,
        linkDescription = map['link_description'] as String?,
        linkImage = map['link_image'] as String?,
        linkSiteName = map['link_siteName'] as String?;

  static const String selectQuery = '''
    SELECT
      n.id AS note_id,
      n.folderId AS note_folder_id,
      n.fileId AS note_fileId,
      n.title AS note_title,
      n.content AS note_content,
      n.color AS note_color,
      n.createdAt AS note_createdAt,
      n.updatedAt AS note_updatedAt,
      n.isFavorite AS note_isFavorite,

      t.id AS tag_id,
      t.title AS tag_title, -- ✅ Cambiado t.name por t.title
      t.fileId AS tag_fileId,
      t.isFavorite AS tag_isFavorite,
      t.updatedAt AS tag_updatedAt,
      t.usageCount AS tag_usageCount,

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