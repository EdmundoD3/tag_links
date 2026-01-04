import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/folders_notifier.dart';
import '../models/folder.dart';
import 'folder_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final folders = ref.watch(foldersProvider(null));
    final rootFolders = folders.where((f) => f.parentId == null).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Folders')),
      floatingActionButton: _createNewFolderBtn(context, ref),
      body: _l(context, rootFolders),
    );
  }
  Widget _l(BuildContext context, List<Folder> rootFolders){
    return ListView(
        children: rootFolders.map((f) {
          return ListTile(
            title: Text(f.title),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => FolderPage(folder: f)),
              );
            },
          );
        }).toList(),
      );
  }

  Widget _createNewFolderBtn(BuildContext context, WidgetRef ref) {
    return FloatingActionButton(
        onPressed: () {
          final folder = Folder(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: 'Nuevo Folder',
            tags: const [],
            createdAt: DateTime.now(),
          );
          ref.read(foldersProvider(null).notifier).addFolder(folder);
        },
        child: const Icon(Icons.add),
      );
  }
}
