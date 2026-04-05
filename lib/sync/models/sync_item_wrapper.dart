abstract class BaseSyncModel {
  final String id;        // El ID único de la nota/carpeta/tag
  final String fileId;    // El ID del bucket (vinculado a la tabla 'files')
  final int updatedAt;    // Mejor usar int directamente para evitar conversiones constantes
  final int? syncAt;      // Nullable: null significa "nunca subido"

  BaseSyncModel({
    required this.id,
    required this.fileId,
    required this.updatedAt,
    this.syncAt,
  });

  // Esto te permitirá saber si un objeto está "sucio" sin ir a la DB
  bool get isDirty => syncAt == null || (updatedAt - syncAt!) > 1000;
}

final itemsBaseColumns = '''
    fileId TEXT NOT NULL,
    updatedAt INTEGER NOT NULL,
    syncAt INTEGER,
    FOREIGN KEY (fileId) REFERENCES files(id) ON DELETE CASCADE
''';

// Agrega esto en tu onCreate de la base de datos para cada tabla:
// "CREATE INDEX idx_notes_fileId ON notes(fileId);"