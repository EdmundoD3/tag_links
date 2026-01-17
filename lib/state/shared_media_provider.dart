import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/note.dart';

final sharedNoteProvider =
    NotifierProvider<SharedNoteNotifier, Note?>(
  SharedNoteNotifier.new,
);


final hasPendingSharedNoteProvider = Provider<bool>((ref) {
  return ref.watch(sharedNoteProvider) != null;
});


class SharedNoteNotifier extends Notifier<Note?> {
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

