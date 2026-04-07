abstract class BaseSyncModel {
  final String id;        // El ID único de la nota/carpeta/tag
  final String fileId;    // El ID del bucket (vinculado a la tabla 'files')
  final int updatedAt;    // Mejor usar int directamente para evitar conversiones constantes

  BaseSyncModel({
    required this.id,
    required this.fileId,
    required this.updatedAt,
  });

}

/// fileId, updatedAt
final itemsBaseColumns = '''
    fileId TEXT NOT NULL,
    updatedAt INTEGER NOT NULL,
    FOREIGN KEY (fileId) REFERENCES files(id) ON DELETE CASCADE
''';