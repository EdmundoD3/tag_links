import 'package:tag_links/models/tag.dart';
import 'package:uuid/uuid.dart';

class Folder {
  final String id;
  final String? parentId;
  final String fileId;
  final String title;
  final List<Tag> tags;
  final String? description;
  final String? image;
  final String? color;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? syncAt;
  final bool isFavorite;

  Folder({
    required this.id,
    this.parentId,
    required this.fileId,
    required this.title,
    required this.tags,
    this.description,
    this.image,
    this.color,
    required this.createdAt,
    required this.updatedAt,
    this.syncAt,
    this.isFavorite = false,
  });

  factory Folder.empty({required bool hasId, required String fileId, String? parentId}) {
    final folder = Folder(
      id: hasId ? const Uuid().v4() : '',
      parentId: parentId,
      fileId: fileId,
      title: '',
      tags: [],
      description: null,
      image: null,
      color: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      syncAt: null,
      isFavorite: false,
    );
    return folder.ensureForInsert();
  }

  static Folder fromMap(Map<String, dynamic> map) {
    return Folder(
      id: map['id'],
      parentId: map['parentId'],
      fileId: map['fileId'],
      title: map['title'] ?? '',
      // Si 'tags' no viene en el map (como en el query local),
      // inicializamos lista vacía para que no explote.
      tags: (map['tags'] as List?)?.map((t) => Tag.fromMap(t)).toList() ?? [],
      description: map['description'],
      image: map['image'],
      color: map['color'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
      syncAt: map['syncAt'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(map['syncAt']),
      isFavorite: map['isFavorite'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'parentId': parentId,
      'fileId': fileId,
      'title': title,
      'description': description,
      'image': image,
      'color': color,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'syncAt': syncAt?.millisecondsSinceEpoch,
      'isFavorite': isFavorite ? 1 : 0,
    };
  }

  Folder copyWith({
    String? id,
    required String? parentId,
    String? title,
    List<Tag>? tags,
    String? description,
    String? image,
    String? color,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? syncAt,
    bool? isFavorite,
  }) {
    return Folder(
      id: id ?? this.id,
      parentId: parentId, //puede ser null asi que sin this o no podran ser folder de la raiz
      fileId: fileId,
      title: title ?? this.title,
      tags: tags ?? this.tags,
      description: description ?? this.description,
      image: image ?? this.image,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncAt: syncAt ?? this.syncAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Folder ensureForInsert() {
    return copyWith(
      id: id.isEmpty ? const Uuid().v4() : id,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      parentId: id != parentId ? parentId : null,
    );
  }
}

String folderTable = '''
          CREATE TABLE folders (
            id TEXT PRIMARY KEY,
            parentId TEXT,
            fileId TEXT NOT NULL,
            title TEXT NOT NULL,
            description TEXT,
            image TEXT,
            color TEXT,
            createdAt INTEGER NOT NULL,
            updatedAt INTEGER,
            syncAt INTEGER,
            isFavorite INTEGER NOT NULL DEFAULT 0 CHECK (isFavorite IN (0,1)),
            FOREIGN KEY (fileId) REFERENCES files(id) ON DELETE CASCADE,
            FOREIGN KEY (parentId) REFERENCES folders(id) ON DELETE CASCADE
          );
''';
