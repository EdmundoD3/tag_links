import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/ui/folder/folder_form_page.dart';
import 'package:tag_links/ui/note/note_form_page.dart';
import 'package:tag_links/ui/folder/folder_tile.dart';
import 'package:tag_links/ui/note/note_tile.dart';
import '../models/folder.dart';
import '../state/folders_provider.dart';
import '../state/notes_provider.dart';
import '../models/note.dart';

class FolderPage extends ConsumerWidget {
  final Folder folder;
  const FolderPage({super.key, required this.folder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subFolders = ref.watch(foldersProvider(folder.id));
    final folderNotes = ref.watch(notesProvider(folder.id));

    return Scaffold(
      appBar: AppBar(title: Text(folder.title)),
      floatingActionButton: _createFabMenu(context, ref),
      body: ListView(
        children: [
          ..._foldersList(context, subFolders),
          ..._notesList(context, folderNotes),
        ],
      ),
    );
  }

  List<Widget> _foldersList(
    BuildContext context,
    AsyncValue<List<Folder>> subFolders,
  ) {
    return subFolders.when(
      data: (folders) {
        if (folders.isEmpty) return [];
        return [
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              'Carpetas',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ...folders.map((f) => FolderTile(folder: folder)),
        ];
      },
      loading: () => [const Center(child: CircularProgressIndicator())],
      error: (err, stack) => [Center(child: Text('Error: $err'))],
    );
  }

  List<Widget> _notesList(
    BuildContext context,
    AsyncValue<List<Note>> folderNotes,
  ) {
    return folderNotes.when(
      data: (notes) {
        if (notes.isEmpty) return [];
        return [
          const Divider(),
          ...notes.map(
            (note) => NoteTile(note: note),
            )
        ];
      },
      loading: () => [const Center(child: CircularProgressIndicator())],
      error: (err, stack) => [Center(child: Text('Error: $err'))],
    );
  }

  Widget _createFabMenu(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: 'addFolder',
          mini: true,
          onPressed: () => _createNewFolder(context, folder.id),
          child: const Icon(Icons.create_new_folder),
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          heroTag: 'addNote',
          onPressed: () => _createNewNote(context),
          child: const Icon(Icons.note_add),
        ),
      ],
    );
  }

  Future<void> _createNewFolder(BuildContext context, String parentFolderId) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FolderFormPage(parentFolderId: parentFolderId),
      ),
    );
  }

  Future<void> _createNewNote(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NoteFormPage(folderId: folder.id)),
    );
  }
}
