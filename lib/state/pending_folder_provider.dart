import 'dart:async';
import 'package:flutter/foundation.dart'; // Para debugPrint
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/models/folder.dart';
import 'package:tag_links/repository/folder_repository.dart';
import 'package:tag_links/state/folders_provider.dart';

// --- VALIDACIÓN ---

class FolderValidation {
  final Set<String> forbiddenIds;
  final bool hasChildren;

  FolderValidation({required this.forbiddenIds, required this.hasChildren});
}

final folderValidationProvider = FutureProvider.autoDispose.family<FolderValidation, String>((ref, folderId) async {
  debugPrint("🔍 Iniciando validación para: $folderId");
  final repo = ref.watch(folderRepositoryProvider);
  
  try {
    // Si esto tarda más de 2 segundos, algo está mal en el SQL
    final results = await Future.wait([
      repo.getAllDescendantIds(folderId),
      repo.hasChildren(folderId),
    ]).timeout(const Duration(seconds: 2));

    debugPrint("✨ Validación completada con éxito");
    return FolderValidation(
      forbiddenIds: results[0] as Set<String>,
      hasChildren: results[1] as bool,
    );
  } catch (e, stack) {
    debugPrint("🚨 ERROR CRÍTICO EN PROVIDER: $e");
    debugPrint(stack.toString());
    rethrow;
  }
});

// --- ESTADO DE CARPETA PENDIENTE ---

final pendingFolderProvider = NotifierProvider<PendingFolderNotifier, Folder?>(
  PendingFolderNotifier.new,
);

class PendingFolderNotifier extends Notifier<Folder?> {
  @override
  Folder? build() => null;

  void set(Folder folder) => state = folder;
  void clear() => state = null;
}

// --- SERVICIO DE MOVIMIENTO ---

final folderMoveProvider = Provider((ref) => FolderMoveService(ref));

class FolderMoveService {
  final Ref ref;
  FolderMoveService(this.ref);

  FolderRepository get _repo => ref.read(folderRepositoryProvider);

  Future<void> move({
    required Folder folder,
    required String? toParentId,
  }) async {
    final fromParentId = folder.parentId;

    final moved = folder.copyWith(
      parentId: toParentId,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    await _repo.upsert(moved);

    _updateUi(
      folder: folder, 
      fromParentId: fromParentId, 
      toParentId: toParentId, 
      updatedFolder: moved
    );

    _cleanup();
  }

  Future<void> moveAndFlatten({
    required Folder folder,
    required String? toParentId,
    bool toRoot = true,
  }) async {
    final fromParentId = folder.parentId;
    final childrenParentId = toRoot ? null : fromParentId;

    // 1. DB: Operación atómica (Recuerda que aquí rescatamos hijos antes de mover)
    await _repo.moveAndFlatten(folder, toParentId, toRoot: toRoot);

    // 2. UI: Actualizar la carpeta principal
    final moved = folder.copyWith(
      parentId: toParentId, 
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    
    _updateUi(
      folder: folder, 
      fromParentId: fromParentId, 
      toParentId: toParentId, 
      updatedFolder: moved
    );

    // 3. UI: Invalidadción estratégica
    // Invalidamos el destino donde cayeron los hijos (Raíz o antiguo padre)
    ref.invalidate(foldersProvider(childrenParentId));
    // Invalidamos la carpeta que se movió porque ahora está vacía
    ref.invalidate(foldersProvider(folder.id));

    _cleanup();
  }

  void _updateUi({
    required Folder folder,
    required String? fromParentId,
    required String? toParentId,
    required Folder updatedFolder,
  }) {
    // Solo actualizamos el notifier si el provider está "vivo" (evita errores de creación/destrucción)
    if (ref.exists(foldersProvider(fromParentId))) {
      ref.read(foldersProvider(fromParentId).notifier).removeFolder(folder.id);
    }

    if (ref.exists(foldersProvider(toParentId))) {
      ref.read(foldersProvider(toParentId).notifier).updateFolder(updatedFolder);
    } else {
      // Si el destino no está cargado, invalidamos para que cargue fresco al entrar
      ref.invalidate(foldersProvider(toParentId));
    }
  }

  void _cleanup() {
    ref.read(pendingFolderProvider.notifier).clear();
  }
}