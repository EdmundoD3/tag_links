import 'package:tag_links/sync/models/file_base.dart';

class DeleteFile extends FileBase {
  final List<DeleteItem> tags;
  final List<DeleteItem> notes;
  final List<DeleteItem> folders;

  DeleteFile({
    required super.id,
    required super.fileId,
    required this.tags,
    required this.notes,
    required this.folders,
    required super.createdAt,
    required super.updatedAt,
  });

  factory DeleteFile.fromMap(Map<String, dynamic> map) {
    return DeleteFile(
      id: map['id'],
      fileId: map['fileId'],

      tags: (map['tags'] as List? ?? [])
          .map((e) => DeleteItem.fromMap(e))
          .toList(),
      notes: (map['notes'] as List? ?? [])
          .map((e) => DeleteItem.fromMap(e))
          .toList(),
      folders: (map['folders'] as List? ?? [])
          .map((e) => DeleteItem.fromMap(e))
          .toList(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['createdAt'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        map['updatedAt'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  Map<String, dynamic> toMap() => {
    "id": id,
    "fileId": fileId,
    "tags": tags.map((e) => e.toMap()).toList(),
    "notes": notes.map((e) => e.toMap()).toList(),
    "folders": folders.map((e) => e.toMap()).toList(),
    "createdAt": createdAt.millisecondsSinceEpoch,
    "updatedAt": updatedAt.millisecondsSinceEpoch,
  };

  /// Filtra los elementos que tengan más de 'days' de antigüedad.
  /// Útil para la limpieza mensual que planeas.
  DeleteFile purgeOldRecords({int days = 30}) {
    final threshold = DateTime.now()
        .subtract(Duration(days: days))
        .millisecondsSinceEpoch;

    return DeleteFile(
      id: id,
      fileId: fileId,
      tags: tags.where((e) => e.deletedAt > threshold).toList(),
      notes: notes.where((e) => e.deletedAt > threshold).toList(),
      folders: folders.where((e) => e.deletedAt > threshold).toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  DeleteFile filterForDelete({required int lastPulledAt}) {
    return DeleteFile(
      id: id,
      fileId: fileId,
      tags: tags.where((e) => e.deletedAt > lastPulledAt).toList(),
      notes: notes.where((e) => e.deletedAt > lastPulledAt).toList(),
      folders: folders.where((e) => e.deletedAt > lastPulledAt).toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Verifica si el manifiesto está totalmente vacío para saber si
  /// podemos borrar el archivo de Drive.
  bool get isEmpty => tags.isEmpty && notes.isEmpty && folders.isEmpty;
}

class DeleteItem {
  final String id;
  final int deletedAt;

  DeleteItem({required this.id, required this.deletedAt});

  factory DeleteItem.fromMap(Map<String, dynamic> map) {
    return DeleteItem(id: map['id'] ?? '', deletedAt: map['deletedAt'] ?? 0);
  }

  Map<String, dynamic> toMap() => {"id": id, "deletedAt": deletedAt};
}
