import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    final moved = note.copyWith(
      folderId: toFolderId,
      updatedAt: DateTime.now(),
    );

    // UI optimista
    ref.read(notesProvider(fromFolderId).notifier).removeNote(note.id);

    ref.read(notesProvider(toFolderId).notifier).addNote(moved);

    // persistencia
    await ref.read(notesRepositoryProvider).update(moved);

    // limpiar estado temporal
    ref.read(pendingNoteProvider.notifier).clear();
  }
}
