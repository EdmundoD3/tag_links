import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/models/folder.dart';
import 'package:tag_links/ui/folder/folder_form_page.dart';
import 'package:tag_links/pages/folder_page.dart';

class FolderTile extends ConsumerWidget {
  final Folder folder;

  const FolderTile({super.key, required this.folder});

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
    Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => FolderPage(folder: folder)),
      );
      return;
  }
}
