class Tag {
  final String id;
  final String name;

  Tag({
    required this.id,
    required this.name,
  });
}

String tagTable = '''
          CREATE TABLE tags (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL UNIQUE
          );
''';