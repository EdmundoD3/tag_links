import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/models/folder.dart';
import 'package:tag_links/state/folders_provider.dart';
import 'package:tag_links/ui/folder/folder_tile.dart';
import 'package:tag_links/ui/utils/empty_indicator.dart';

class BuildFoldersList extends StatelessWidget {
  final FoldersNotifier notifier;
  final AsyncValue<List<Folder>> foldersAsync;
  final ScrollController scrollController;

  const BuildFoldersList({
    super.key,
    required this.foldersAsync,
    required this.scrollController,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: foldersAsync.when(
        data: (folders) {
          if (folders.isEmpty) {
            return EmptyIndicator(title: 'No hay carpetas');
          }

          return Stack(
            children: [
              ListView.builder(
                controller: scrollController,
                itemCount: folders.length,
                itemBuilder: (_, i) => FolderTile(folder: folders[i]),
              ),

              if (notifier.isLoadingMore) _loadingMoreIndicator(),
            ],
          );
        },
        loading: () => _loading(),
        error: (error, _) => _error(error.toString()),
      ),
    );
  }

  Widget _loading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _error(String error) {
    return Center(child: Text('Error: $error'));
  }

  Widget _loadingMoreIndicator() {
    return const Positioned(
      top: 8,
      left: 0,
      right: 0,
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}
