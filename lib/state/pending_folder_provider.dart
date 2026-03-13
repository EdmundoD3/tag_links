import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/models/folder.dart';
import 'package:tag_links/repository/folder_repository.dart';
import 'package:tag_links/state/folders_provider.dart';

final pendingFolderProvider =
    NotifierProvider<PendingFolderNotifier, Folder?>(
  PendingFolderNotifier.new,
);

// Este provider nos dirá qué carpetas son "prohibidas" para el movimiento actual
final forbiddenDestinationsProvider = FutureProvider<Set<String>>((ref) async {
  final pendingFolder = ref.watch(pendingFolderProvider);
  if (pendingFolder == null) return {};

  final repo = ref.watch(folderRepositoryProvider);
  return await repo.getAllDescendantIds(pendingFolder.id);
});

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

    // 1. Creamos el objeto con el nuevo destino
    final moved = folder.copyWith(
      parentId: toParentId,
      updatedAt: DateTime.now(),
    );

    // 2. PERSISTENCIA Y ACTUALIZACIÓN DEL DESTINO
    // Llamamos a updateFolder del notifier de la carpeta DESTINO.
    // Esto ejecutará el await _repo.update(folder) que agregamos al Notifier.
    await ref.read(foldersProvider(toParentId).notifier).updateFolder(moved);

    // 3. ACTUALIZACIÓN DEL ORIGEN
    // Si la carpeta se movió a un padre distinto, la quitamos de la lista vieja.
    if (fromParentId != toParentId) {
      ref.read(foldersProvider(fromParentId).notifier).removeFolder(folder.id);
    }

    // 4. Limpiar estado temporal
    ref.read(pendingFolderProvider.notifier).clear();
  }
}