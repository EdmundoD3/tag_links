import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/models/folder.dart';
import 'package:tag_links/ui/folder/folder_form_page.dart';
import 'package:tag_links/pages/folder_page.dart';

class FolderTile extends ConsumerWidget {
  final Folder folder;

  const FolderTile({super.key, required this.folder});

  // @override
  // Widget build(BuildContext context, WidgetRef ref) {
  //   return ListTile(
  //     leading: const Icon(Icons.folder),
  //     title: Text(folder.title),
  //     trailing: IconButton(
  //       icon: const Icon(Icons.edit),
  //       onPressed: () => _editFolder(context),
  //     ),
  //     onTap: () => _goFolder(context, ref),
  //   );
  // }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 3, // La sombra que le da profundidad
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ), // Margen exterior
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ), // Bordes redondeados
      child: ListTile(
        leading: Icon(
          Icons.folder,
          color: Colors.deepPurple[400],
        ), // Un toque de color
        title: Text(
          folder.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => _editFolder(context),
        ),
        onTap: () => _goFolder(context, ref),
      ),
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
