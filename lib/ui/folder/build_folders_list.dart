import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/locate/t_keys.dart';
import 'package:tag_links/models/folder.dart';
import 'package:tag_links/pages/home_page.dart';
import 'package:tag_links/state/folders_provider.dart';
import 'package:tag_links/state/pending_folder_provider.dart';
import 'package:tag_links/ui/alerts/confirm_dialog.dart';
import 'package:tag_links/ui/folder/folder_tile.dart';
import 'package:tag_links/ui/is_loading_indicators/shimmer_folder_list.dart';
import 'package:tag_links/ui/utils/empty_indicator.dart';
import 'package:tag_links/ui/utils/page_buil.dart';

class BuildFoldersList extends ConsumerWidget {
  final FoldersNotifier notifier;
  final AsyncValue<List<Folder>> foldersAsync;
  final ScrollController scrollController;
  final void Function(Folder id) onDeleteFolder;

  const BuildFoldersList({
    super.key,
    required this.foldersAsync,
    required this.scrollController,
    required this.notifier,
    required this.onDeleteFolder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return foldersAsync.when(
      data: (folders) {
        if (folders.isEmpty) {
          return EmptyIndicator(
            title: ref.tr(TKeys.ui.noFolders, fallback: 'No folders'),
          );
        }

        return ListView.builder(
          controller: scrollController,
          // Añadimos +1 al count si está cargando para mostrar el spinner al final
          itemCount: folders.length + (notifier.isLoadingMore ? 1 : 0),
          itemBuilder: (_, i) {
            // Si es el último índice y estamos cargando, mostramos el spinner
            if (i == folders.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            }

            final folder = folders[i];
            return FolderTile(
              key: ValueKey(
                folder.id,
              ), // Importante para que Flutter no se pierda al mover
              folder: folder,
              actionsItems: const [],
              goFolder: () => _goFolder(context, folder),
              onDeleteFolder: () => onDeleteFolder(folder),
              onMove: () async {
                final isConfirm = await ConfirmDialog.moveFolder(context, ref);
                if (isConfirm == true) {
                  ref.read(pendingFolderProvider.notifier).set(folder);
                }
              },
            );
          },
        );
      },
      loading: () => const ShimmerFoldersList(),
      error: (error, _) {
        debugPrint('Error: $error');
        return Center(child: Text('Error...'));
      },
    );
  }

  Future<void> _goFolder(BuildContext context, Folder folder) async {
    return goPage(
      context: context,
      page: HomePage(folder: folder),
    );
  }
}
