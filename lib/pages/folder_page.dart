import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/models/tag.dart';
import '../models/folder.dart';
import '../state/folders_notifier.dart';
import '../state/notes_notifier.dart';
import '../models/note.dart';
import '../models/link_preview.dart';

class FolderPage extends ConsumerWidget {
  final Folder folder;
  const FolderPage({super.key, required this.folder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subFolders = ref.watch(foldersProvider(folder.id));
    final folderNotes = ref.watch(notesProvider(folder.id));

    return Scaffold(
      appBar: AppBar(title: Text(folder.title)),
      floatingActionButton: _createFabMenu(ref),
      body: ListView(
        children: [
          if (subFolders.isNotEmpty)
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'Carpetas',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ...subFolders.map((f) => ListTile(
                leading: const Icon(Icons.folder),
                title: Text(f.title),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FolderPage(folder: f),
                    ),
                  );
                },
              )),
          if (folderNotes.isNotEmpty) const Divider(),
          ...folderNotes.map((note) => ListTile(
                title: Text(note.title),
                subtitle: note.link?.url.isNotEmpty == true
                    ? Text(note.link!.url)
                    : null,
                trailing: const Icon(Icons.link),
              )),
        ],
      ),
    );
  }

  Widget _createFabMenu(WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: 'addFolder',
          mini: true,
          onPressed: () => _createNewFolder(ref),
          child: const Icon(Icons.create_new_folder),
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          heroTag: 'addNote',
          onPressed: () => _createNewNote(ref),
          child: const Icon(Icons.note_add),
        ),
      ],
    );
  }

  void _createNewFolder(WidgetRef ref) {
    final folder = Folder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      parentId: this.folder.id,
      title: 'Nuevo Folder',
      tags: [Tag(id: "", name: "test")],
      createdAt: DateTime.now(),
    );

    ref.read(foldersProvider(this.folder.id).notifier).addFolder(folder);
  }

  void _createNewNote(WidgetRef ref) {
    final note = Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      folderId: folder.id,
      title: 'Nuevo link',
      link: LinkPreview(
        id: "",
        noteId: "",
        url: 'https://example.com',
        title: 'Example',
      ),
      tags: [Tag(id: "", name: "test")],
      createdAt: DateTime.now(),
    );

    ref.read(notesProvider(folder.id).notifier).addNote(note);
  }
}
