import 'dart:convert';

import 'package:tag_links/models/tag.dart';
import 'package:uuid/uuid.dart';

class Folder {
  final String id;
  final String? parentId;
  final String title;
  final List<Tag> tags;
  final String? description;
  final String? image;
  final String? color;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFavorite;

  Folder({
    required this.id,
    this.parentId,
    required this.title,
    required this.tags,
    this.description,
    this.image,
    this.color,
    required this.createdAt,
    required this.updatedAt,
    this.isFavorite = false,
  });

  factory Folder.empty(){
    final folder = Folder(
      id: '',
      parentId: '',
      title: '',
      tags: [],
      description: '',
      image: '',
      color: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isFavorite: false,
    );
    return folder.ensureForInsert();
  }

    static Folder fromMap(Map<String, dynamic> map) {
    return Folder(
      id: map['id'],
      parentId: map['parentId'],
      title: map['title'],
      tags: map['tags'],
      description: map['description'],
      image: map['image'],
      color: map['color'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
      isFavorite: map['isFavorite'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'parentId': parentId,
      'title': title,
      'description': description,
      'image': image,
      'color': color,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'isFavorite': isFavorite ? 1 : 0,
    };
  }

  Folder copyWith({
    String? id,
    String? parentId,
    String? title,
    List<Tag>? tags,
    String? description,
    String? image,
    String? color,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
  }) {
    return Folder(
      id: id ?? this.id,
      parentId: parentId, //puede ser null asi que sin this o no podran ser folder de la raiz
      title: title ?? this.title,
      tags: tags ?? this.tags,
      description: description ?? this.description,
      image: image ?? this.image,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
  Folder ensureForInsert() {
    return copyWith(
      id: id.isEmpty ? const Uuid().v4() : id,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
  static Folder fromDecryptedJson(String id, String decryptedPayload) {
    final Map<String, dynamic> json = jsonDecode(decryptedPayload);
    final List<dynamic> tagsRaw = json['tags'] ?? [];

    return Folder(
      id: id,
      parentId: json['parentId'] as String?, // Por si implementas subcarpetas
      title: json['title'] as String,
      description: json['description'] as String?,
      image: json['image'] as String?,
      color: json['color'] as String?,
      tags: tagsRaw
          .map((t) => Tag(id: t['id'] as String, name: t['name'] as String))
          .toList(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        (json['updatedAt'] ?? json['createdAt']) as int,
      ),
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }
}

String folderTable = '''
          CREATE TABLE folders(
            id TEXT PRIMARY KEY,
            parentId TEXT,
            title TEXT NOT NULL,
            description TEXT,
            image TEXT,
            color TEXT,
            createdAt INTEGER NOT NULL,
            updatedAt INTEGER,
            isFavorite INTEGER NOT NULL DEFAULT 0 CHECK (isFavorite IN (0,1)),
            FOREIGN KEY (parentId) REFERENCES folders(id) ON DELETE CASCADE
          );
''';
