import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/models/folder.dart';
import 'package:tag_links/models/note.dart';
import 'package:tag_links/repository/folder_repository.dart';
import 'package:tag_links/ui/folder/folder_form_page.dart';
import 'package:tag_links/pages/folder_page.dart';
import 'package:tag_links/utils/paginated_utils.dart';

class FolderTile extends ConsumerWidget {
  final Folder folder;
  final Note? highlightNote;

  const FolderTile({super.key, required this.folder, this.highlightNote});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.folder),
      title: Text(folder.title),
      trailing: IconButton(
        icon: const Icon(Icons.edit),
        onPressed: () => _editFolder(context),
      ),
      onTap: () => _goFolder(context, ref),
    );
  }

  Future<void> _editFolder(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FolderFormPage(folder: folder)),
    );
  }

  Future<void> _goFolder(BuildContext context, WidgetRef ref) async {
    if (highlightNote == null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => FolderPage(folder: folder)),
      );
      return;
    }

    final repo = ref.read(folderRepositoryProvider);

    final paginated = await repo.getPageForNoteId(
      highlightNote!,
      paginated: const PaginatedByDate(),
    );
    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FolderPage(
          folder: folder,
          highlightNote: highlightNote,
          paginated: paginated,
        ),
      ),
    );
    return;
  }
}
