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

  // 🎯 Lógica de decisión automática:
  // Si movemos una carpeta a dentro de otra (toParentId != null), 
  // automáticamente debemos aplanar sus hijos porque no permitimos nivel 3.
  final bool needsFlattening = toParentId != null;

  if (needsFlattening) {
    // 1. DB: Mueve la carpeta y rescata a los hijos (los sube a raíz o al padre anterior)
    await _repo.moveAndFlatten(folder, toParentId, toRoot: true);
    
    // 2. UI: Invalidadción de los hijos que quedaron huérfanos
    ref.invalidate(foldersProvider(null)); // Asumimos que caen en raíz
    ref.invalidate(foldersProvider(folder.id));
  } else {
    // Es un movimiento hacia la raíz, no hay riesgo de nivel 3
    final moved = folder.copyWith(
      parentId: toParentId,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    await _repo.upsert(moved);
  }

  // 3. UI: Actualizar la carpeta que se movió
  final updatedFolder = folder.copyWith(
    parentId: toParentId,
    updatedAt: DateTime.now().millisecondsSinceEpoch,
  );

  _updateUi(
    folder: folder, 
    fromParentId: fromParentId, 
    toParentId: toParentId, 
    updatedFolder: updatedFolder
  );

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