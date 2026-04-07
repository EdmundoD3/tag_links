import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/repository/notes_repository.dart';
import 'package:tag_links/state/notes_provider.dart';
import '../models/note.dart';

final pendingNoteProvider = NotifierProvider<PendingNoteNotifier, TypeNoteMove?>(
  PendingNoteNotifier.new,
);

final hasPendingNoteProvider = Provider<bool>((ref) {
  return ref.watch(pendingNoteProvider) != null;
});

class PendingNoteNotifier extends Notifier<TypeNoteMove?> {

  @override
  TypeNoteMove? build() => null;

  /// Establece la nota compartida (share / intent)
  void set(Note note, TypeMove type) {
    state = TypeNoteMove(note: note, type: type);
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
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    if (fromFolderId == toFolderId) return;

    // 2. Persistencia real en la DB primero
    // Usamos el repositorio directamente para asegurar que el cambio esté en disco
    await ref.watch(notesRepositoryProvider).update(moved);

    // 3. Actualización de la UI (Optimista)
    // Quitamos de la lista vieja
    ref.read(notesProvider(fromFolderId).notifier).removeNote(note.id);

    // Añadimos a la lista nueva. 
    // OJO: Usa un método que actualice el estado sin volver a llamar al repo.create
    ref.read(notesProvider(toFolderId).notifier).updateNoteState(moved);

    // 4. Limpiar estado temporal
    ref.read(pendingNoteProvider.notifier).clear();
    
  }
  Future<void> save({required Note note, required String? toFolderId}) async {
    final newNote = note.copyWith(
      folderId: toFolderId,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    // 2. Persistencia real en la DB primero
    // Usamos el repositorio directamente para asegurar que el cambio esté en disco
    await ref.watch(notesRepositoryProvider).create(newNote);

    // Añadimos a la lista nueva. 
    // OJO: Usa un método que actualice el estado sin volver a llamar al repo.create
    ref.read(notesProvider(toFolderId).notifier).updateNoteState(newNote);

    // 4. Limpiar estado temporal
    ref.read(pendingNoteProvider.notifier).clear();
    
  }
}

class TypeNoteMove {
  final Note note;
  final TypeMove type;
  const TypeNoteMove({required this.note, required this.type});
}

enum TypeMove {
  newNote,move
}