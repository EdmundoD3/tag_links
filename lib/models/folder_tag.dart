class FolderTag {
  final String folderId;
  final String tagId;

  FolderTag({
    required this.folderId,
    required this.tagId,
  });
}

String folderTagTable = '''
          CREATE TABLE folder_tags(
            folderId TEXT NOT NULL,
            tagId TEXT NOT NULL,
            PRIMARY KEY (folderId, tagId),
            FOREIGN KEY (folderId) REFERENCES folders(id) ON DELETE CASCADE,
            FOREIGN KEY (tagId) REFERENCES tags(id) ON DELETE CASCADE
          );
''';