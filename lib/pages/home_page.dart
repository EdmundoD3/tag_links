import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/ui/folder/folder_form_page.dart';
import 'package:tag_links/ui/folder/folder_tile.dart';
import '../state/folders_provider.dart';
import '../models/folder.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foldersAsyncValue = ref.watch(foldersProvider(null));

    return Scaffold(
      appBar: AppBar(title: const Text('Folders')),
      floatingActionButton: _createNewFolderBtn(context, ref), // Keep the FAB
      body: foldersAsyncValue.when(
        data: (folders) {
          final rootFolders = folders.where((f) => f.parentId == null).toList();
          return _buildFolderList(context, rootFolders);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
  Widget _buildFolderList(BuildContext context, List<Folder> rootFolders){
    return ListView(
        children: rootFolders.map((f) {
          return FolderTile(folder: f);
        }).toList(),
      );
  }

  Widget _createNewFolderBtn(BuildContext context, WidgetRef ref) {
    return FloatingActionButton(
        onPressed: () {
          _createNewFolder(context);
        },
        child: const Icon(Icons.add),
      );
  }
  Future<void> _createNewFolder(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FolderFormPage()),
    );
  }
}
