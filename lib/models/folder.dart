import 'package:tag_links/models/tag.dart';
import 'package:uuid/uuid.dart';

class Folder {
  final String id;
  final String? parentId;
  final String title;
  final List<Tag> tags;
  final String? description;
  final String? image;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isFavorite;

  Folder({
    required this.id,
    this.parentId,
    required this.title,
    required this.tags,
    this.description,
    this.image,
    required this.createdAt,
    this.updatedAt,
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
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : null,
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
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
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
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
  }) {
    return Folder(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      title: title ?? this.title,
      tags: tags ?? this.tags,
      description: description ?? this.description,
      image: image ?? this.image,
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
}

String folderTable = '''
          CREATE TABLE folders(
            id TEXT PRIMARY KEY,
            parentId TEXT,
            title TEXT NOT NULL,
            description TEXT,
            image TEXT,
            createdAt INTEGER NOT NULL,
            updatedAt INTEGER,
            isFavorite INTEGER NOT NULL DEFAULT 0 CHECK (isFavorite IN (0,1)),
            FOREIGN KEY (parentId) REFERENCES folders(id) ON DELETE CASCADE
          );
''';
