class DeleteItem {
  final String id;
  final int deletedAt;

  DeleteItem({required this.id, required this.deletedAt});

  factory DeleteItem.fromMap(Map<String, dynamic> map) {
    return DeleteItem(
      id: map['id'] ?? '',
      deletedAt: map['deletedAt'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
    "id": id,
    "deletedAt": deletedAt,
  };
}

class DeleteManifest {
  final List<DeleteItem> tags;
  final List<DeleteItem> notes;
  final List<DeleteItem> folders;

  DeleteManifest({
    required this.tags,
    required this.notes,
    required this.folders,
  });

  factory DeleteManifest.fromMap(Map<String, dynamic> map) {
    return DeleteManifest(
      tags: (map['tags'] as List? ?? []).map((e) => DeleteItem.fromMap(e)).toList(),
      notes: (map['notes'] as List? ?? []).map((e) => DeleteItem.fromMap(e)).toList(),
      folders: (map['folders'] as List? ?? []).map((e) => DeleteItem.fromMap(e)).toList(),
    );
  }

  Map<String, dynamic> toMap() => {
    "tags": tags.map((e) => e.toMap()).toList(),
    "notes": notes.map((e) => e.toMap()).toList(),
    "folders": folders.map((e) => e.toMap()).toList(),
  };

  /// Filtra los elementos que tengan más de 'days' de antigüedad.
  /// Útil para la limpieza mensual que planeas.
  DeleteManifest purgeOldRecords({int days = 30}) {
    final threshold = DateTime.now()
        .subtract(Duration(days: days))
        .millisecondsSinceEpoch;

    return DeleteManifest(
      tags: tags.where((e) => e.deletedAt > threshold).toList(),
      notes: notes.where((e) => e.deletedAt > threshold).toList(),
      folders: folders.where((e) => e.deletedAt > threshold).toList(),
    );
  }

  /// Verifica si el manifiesto está totalmente vacío para saber si 
  /// podemos borrar el archivo de Drive.
  bool get isEmpty => tags.isEmpty && notes.isEmpty && folders.isEmpty;
}