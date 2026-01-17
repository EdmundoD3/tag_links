class FolderPreference {
  final String folderId;
  final FolderDefaultView defaultView;

  const FolderPreference({
    required this.folderId,
    required this.defaultView,
  });
  Map<String, dynamic> toMap() {
    return {
      'folderId': folderId,
      'defaultView': defaultView.name,
    };
  }
  factory FolderPreference.fromMap(Map<String, dynamic> map) {
    return FolderPreference(
      folderId: map['folderId'],
      defaultView: FolderDefaultView.values.firstWhere(
        (e) => e.name == map['defaultView'],
      ),
    );
  }
}

enum FolderDefaultView {
  folders,
  notes,
}

const String folderPreferencesTable = """
CREATE TABLE folder_preferences (
  folderId TEXT PRIMARY KEY,
  defaultView TEXT NOT NULL,
  FOREIGN KEY (folderId) REFERENCES folders(id) ON DELETE CASCADE
);
""";
