class NoteTag {
  final String noteId;
  final String tagId;

  NoteTag({
    required this.noteId,
    required this.tagId,
  });
}
String noteTagTable = '''
          CREATE TABLE note_tags(
            noteId TEXT NOT NULL,
            tagId TEXT NOT NULL,
            PRIMARY KEY (noteId, tagId),
            FOREIGN KEY (noteId) REFERENCES notes(id) ON DELETE CASCADE,
            FOREIGN KEY (tagId) REFERENCES tags(id) ON DELETE CASCADE
          );
''';