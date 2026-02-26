import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/models/folder.dart';
import 'package:tag_links/repository/folder_repository.dart';
import 'package:tag_links/state/folders_provider.dart';

final pendingFolderProvider =
    NotifierProvider<PendingFolderNotifier, Folder?>(
  PendingFolderNotifier.new,
);

class PendingFolderNotifier extends Notifier<Folder?> {
  @override
  Folder? build() => null;

  void set(Folder folder) => state = folder;
  void clear() => state = null;
}


final folderMoveProvider = Provider((ref) {
  return FolderMoveService(ref);
});

class FolderMoveService {
  final Ref ref;
  FolderMoveService(this.ref);

  Future<void> move({
    required Folder folder,
    required String? toParentId,
  }) async {
    final fromParentId = folder.parentId;

    final moved = folder.copyWith(
      parentId: toParentId,
      updatedAt: DateTime.now(),
    );

    ref
        .read(foldersProvider(fromParentId).notifier)
        .removeFolder(folder.id);

    ref
        .read(foldersProvider(toParentId).notifier)
        .updateFolder(moved);

    // limpiar estado temporal
    ref.read(pendingFolderProvider.notifier).clear();
  }
}
