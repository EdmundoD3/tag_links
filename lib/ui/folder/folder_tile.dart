import 'package:flutter/material.dart';
import 'package:tag_links/models/folder.dart';
import 'package:tag_links/ui/folder/folder_form_page.dart';
import 'package:tag_links/pages/folder_page.dart';

class FolderTile extends StatelessWidget {
  final Folder folder;
  const FolderTile({super.key, required this.folder});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.folder),
      title: Text(folder.title),
      trailing: IconButton(
        icon: const Icon(Icons.edit),
        onPressed: () {
          _editFolder(context, folder);
        },
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => FolderPage(folder: folder)),
        );
      },
    );
  }
  Future<void> _editFolder(BuildContext context, Folder folder) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FolderFormPage(folder: folder, parentFolderId: folder.parentId)),
    );
  }
}
