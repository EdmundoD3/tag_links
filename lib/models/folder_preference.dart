class FolderPreference {
  final String folderId;
  final FolderDefaultView defaultView;

  const FolderPreference({required this.folderId, required this.defaultView});
  Map<String, dynamic> toMap() {
    return {'folderId': folderId, 'defaultView': defaultView.name};
  }

  factory FolderPreference.fromMap(Map<String, dynamic> map) {
    return FolderPreference(
      folderId: map['folderId'],
      defaultView: FolderDefaultView.values.firstWhere(
        (e) => e.name == map['defaultView'],
        orElse: () =>
            FolderDefaultView.folders, // Valor por defecto si algo falla
      ),
    );
  }
}

enum FolderDefaultView { folders, notes }
extension FolderDefaultViewX on FolderDefaultView {
  int get pageIndex {
    switch (this) {
      case FolderDefaultView.folders:
        return 0;
      case FolderDefaultView.notes:
        return 1;
    }
  }

  static FolderDefaultView fromPage(int page) {
    return page == 0
        ? FolderDefaultView.folders
        : FolderDefaultView.notes;
  }
}

const String folderPreferencesTable = """
CREATE TABLE folder_preferences (
  folderId TEXT PRIMARY KEY,
  defaultView TEXT NOT NULL,
  FOREIGN KEY (folderId) REFERENCES folders(id) ON DELETE CASCADE
);
""";
