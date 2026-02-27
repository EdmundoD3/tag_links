import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/sync/sync_notifier.dart';
import 'package:tag_links/repository/notes_repository.dart';
import 'package:tag_links/state/notes_provider.dart';
import '../models/note.dart';

final pendingNoteProvider = NotifierProvider<PendingNoteNotifier, Note?>(
  PendingNoteNotifier.new,
);

final hasPendingNoteProvider = Provider<bool>((ref) {
  return ref.watch(pendingNoteProvider) != null;
});

class PendingNoteNotifier extends Notifier<Note?> {
  @override
  Note? build() => null;

  /// Establece la nota compartida (share / intent)
  void set(Note note) {
    state = note;
  }

  /// Limpia la nota temporal
  void clear() {
    state = null;
  }
}

final noteMoveProvider = Provider((ref) {
  return NoteMoveService(ref);
});

class NoteMoveService {
  final Ref ref;
  NoteMoveService(this.ref);

  Future<void> move({required Note note, required String? toFolderId}) async {
    final fromFolderId = note.folderId;

    // 1. Crear el objeto con el cambio de carpeta
    final moved = note.copyWith(
      folderId: toFolderId,
      updatedAt: DateTime.now(),
    );

    // 2. Persistencia real en la DB primero
    // Usamos el repositorio directamente para asegurar que el cambio esté en disco
    await ref.read(notesRepositoryProvider).update(moved);

    // 3. Actualización de la UI (Optimista)
    // Quitamos de la lista vieja
    ref.read(notesProvider(fromFolderId).notifier).removeNote(note.id);

    // Añadimos a la lista nueva. 
    // OJO: Usa un método que actualice el estado sin volver a llamar al repo.create
    ref.read(notesProvider(toFolderId).notifier).updateNoteState(moved);

    // 4. Limpiar estado temporal
    ref.read(pendingNoteProvider.notifier).clear();
    
    // 5. Notificar al sistema de sincronización
    unawaited(ref.read(syncNotifierProvider.notifier).performSync());
  }
}