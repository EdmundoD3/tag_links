import 'dart:convert';

import 'package:tag_links/models/link_preview.dart';
import 'package:tag_links/models/note.dart';
import 'package:tag_links/models/tag.dart';

//el userId se lo asigna el servidor
class NoteRawPayload {
  final String id;
  final String payload;
  final String updatedAt;

  NoteRawPayload({
    required this.id,
    required this.payload,
    required this.updatedAt,
  });
  static NoteRawPayload fromNote(Note note, String key) {
    return NoteRawPayload(
      id: note.id,
      payload: _payload(note, key),
      updatedAt: note.createdAt.millisecondsSinceEpoch.toString(),
    );
  }
  static Note toNote(Map<String, dynamic> json) {
    final noteId =json['id'];
    return Note(
      id: noteId,
      folderId: json['folderId'],
      title: json['title'],
      content: json['content'],
      link: json['url'] != null ? LinkPreview.create(url: json['url'], noteId: noteId) : null,
      tags: json['tags'].map((t) => Tag(id: t['id'], name: t['name'])).toList(),
      color: json['color'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updatedAt']),
      isFavorite: json['isFavorite'],
    );
  }
}

String _payload(Note note, String key) {
  final Map<String, dynamic> raw = {
    'v': 1,
    'folderId': note.folderId,
    'title': note.title,
    'content': note.content,
    'url': note.link?.url,
    'tags': note.tags.map((t) => {'id': t.id, 'name': t.name}).toList(),
    'color': note.color,
    'createdAt': note.createdAt.millisecondsSinceEpoch,
    'updatedAt': note.updatedAt.millisecondsSinceEpoch,
    'isFavorite': note.isFavorite,
  };
  final json = jsonEncode(raw);
final encrypted = encripter(json, key);

  return encrypted;
}

String encripter(String textToEncrypt, String key) {
  //logica de encriptado
  return textToEncrypt;
}
