import 'dart:convert';

import 'package:tag_links/core/sync/encripter.dart';
import 'package:tag_links/models/link_preview.dart';
import 'package:tag_links/models/note.dart';
import 'package:tag_links/models/tag.dart';

// El userId lo asigna el servidor
class NoteRawSync {
  final String id;
  final String payload;
  final int? deletedAt;

  NoteRawSync({
    required this.id,
    required this.payload,
    required this.deletedAt,
  });

  static NoteRawSync fromNote(
    Note note,
    String key,
    int? deletedAt,
  ) {
    return NoteRawSync(
      id: note.id,
      payload: _buildPayload(note, key),
      deletedAt: deletedAt,
    );
  }

  /// SOLO usar cuando ya tienes datos desencriptados
  static Note toNoteFromPayload({
    required String id,
    required String encryptedPayload,
    required String key,
  }) {
    final decrypted = decripter(encryptedPayload, key);

    final Map<String, dynamic> json =
        jsonDecode(decrypted) as Map<String, dynamic>;

    final List<dynamic> tagsRaw =
        (json['tags'] as List<dynamic>?) ?? [];

    return Note(
      id: id,
      folderId: json['folderId'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      link: json['url'] != null
          ? LinkPreview.create(
              url: json['url'] as String,
              noteId: id,
            )
          : null,
      tags: tagsRaw
          .map((t) => Tag(
                id: t['id'] as String,
                name: t['name'] as String,
              ))
          .toList(),
      color: json['color'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        json['createdAt'] as int,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        (json['updatedAt'] ?? json['createdAt']) as int,
      ),
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }
}

String _buildPayload(Note note, String key) {
  final raw = <String, dynamic>{
    'v': 1,
    'folderId': note.folderId,
    'title': note.title,
    'content': note.content,
    'url': note.link?.url,
    'tags': note.tags
        .map((t) => {
              'id': t.id,
              'name': t.name,
            })
        .toList(),
    'color': note.color,
    'createdAt': note.createdAt.millisecondsSinceEpoch,
    'updatedAt': (note.updatedAt ?? note.createdAt)
        .millisecondsSinceEpoch,
    'isFavorite': note.isFavorite,
  };

  final json = jsonEncode(raw);
  return encripter(json, key);
}
