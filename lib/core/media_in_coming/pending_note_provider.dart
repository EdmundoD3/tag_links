import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/models/note.dart';
import 'package:tag_links/repository/notes_repository.dart';
import 'package:tag_links/service/link_preview_service.dart';
import 'package:tag_links/state/notes_provider.dart';

final pendingNoteProvider =
    NotifierProvider<PendingNoteNotifier, TypeNoteMove?>(
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
    if (type == TypeMove.newNote) _enrichNewNote(note, type);
  }

  Future<void> _enrichNewNote(Note note, TypeMove type) async {
    // 1. Validaciones iniciales
    if (note.link == null || note.link!.hasThumbnail) return;
    if (type != TypeMove.newNote || note.title != 'New Note') return;

    try {
      // 2. Scraping con timeout
      final enrichedLink = await LinkPreviewService.prepareForSave(
        note.link,
      ).timeout(const Duration(seconds: 5), onTimeout: () => null);

      if (enrichedLink == null) return;

      // 3. Verificación de seguridad: ¿Sigue el usuario en este flujo?
      // Si el usuario ya guardó o cerró, el state será null. No queremos resucitarlo.
      if (state == null) return;

      // 4. Procesar el título de forma segura
      String newTitle = enrichedLink.title ?? note.title;
      if (newTitle.length > 32) {
        newTitle = "${newTitle.substring(0, 32)}...";
      }

      // 5. Actualizar estado
      final updatedNote = note.copyWith(title: newTitle, link: enrichedLink);

      state = TypeNoteMove(note: updatedNote, type: type);
    } catch (e) {
      debugPrint("PendingNoteNotifier._enrichNewNote Error: $e");
    }
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

enum TypeMove { newNote, move }
