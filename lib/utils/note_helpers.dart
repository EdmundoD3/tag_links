import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/models/note.dart';
import 'package:tag_links/pages/folder_page.dart';
import 'package:tag_links/repository/folder_repository.dart';
import 'package:tag_links/repository/notes_repository.dart';
import 'package:tag_links/utils/paginated_utils.dart';

class NoteHelpers {
    static Future<void> goFolder(BuildContext context, WidgetRef ref,Note note) async {
    final repoFolder = ref.read(folderRepositoryProvider);
    final repoNotes = ref.read(notesRepositoryProvider);

    final paginated = await repoNotes.getPageForNoteId(
      note,
      paginated: const PaginatedByDate(),
    );
    final folder = await repoFolder.getById(note.folderId);

    if (folder == null) return;

    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FolderPage(
          folder: folder,
          highlightNoteId: note.id,
          paginated: paginated,
        ),
      ),
    );
    return;
  }
}