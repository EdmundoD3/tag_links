import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/models/note.dart';
import 'package:tag_links/state/notes_provider.dart';
import 'package:tag_links/ui/note/build_notes_list.dart';

class NotesSection extends ConsumerStatefulWidget {
  final String? folderId;
  final String? highlightNoteId;

  const NotesSection({super.key, required this.folderId, this.highlightNoteId});

  @override
  ConsumerState<NotesSection> createState() => _NotesSectionState();
}

class _NotesSectionState extends ConsumerState<NotesSection> {
  final ScrollController _scrollController = ScrollController();
  bool _didScrollToHighlight = false;

  AsyncNotifierProvider<NotesNotifier, List<Note>> get _notesProvider =>
      notesProvider(widget.folderId);

  final Map<String, GlobalKey> _itemKeys = {};

  @override
  Widget build(BuildContext context) {
    // Determinamos la fuente de datos una sola vez
    final sourceProvider = widget.folderId != null
        ? _notesProvider
        : notesViewProvider;

    // Escuchamos la fuente correcta para el scroll
    ref.listen<AsyncValue<List<Note>>>(sourceProvider, (prev, next) {
      if (widget.highlightNoteId != null) {
        _scrollToHighlightedNote(next);
      }
    });

    final notes = ref.watch(sourceProvider);
    final notifier = ref.read(_notesProvider.notifier);
    return BuildNotesList(
      notesAsync: notes,
      scrollController: _scrollController,
      isLoadingMore: notifier.isLoadingMore,
      onDeleteNote: (note) => notifier.deleteNote(note),
      getKey: _getKey,
    );
  }

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ---------- scroll -----------
  void _onScroll() {
    final position = _scrollController.position;
    final notesNotifier = ref.read(_notesProvider.notifier);

    if (position.pixels >= position.maxScrollExtent - 200 &&
        notesNotifier.hasMore &&
        !notesNotifier.isLoadingMore) {
      notesNotifier.loadMore();
    }
  }

  void _scrollToHighlightedNote(AsyncValue<List<Note>> notesAsync) {
    if (_didScrollToHighlight) return;

    notesAsync.whenData((notes) {
      final index = notes.indexWhere((n) => n.id == widget.highlightNoteId);

      // 1. Verificar si la nota existe en la lista actual
      if (index == -1) {
        debugPrint(
          '🔍 Scroll: Nota ${widget.highlightNoteId} no encontrada aún. Cargando más...',
        );
        final notifier = ref.read(_notesProvider.notifier);

        if (notifier.hasMore && !notifier.isLoadingMore) {
          notifier.loadMore();
        }
        return;
      }

      final note = notes[index];
      final key = _itemKeys[note.id];

      // 2. Verificar si tenemos la GlobalKey y si tiene contexto
      if (key == null) {
        debugPrint(
          '⚠️ Scroll: No se encontró la GlobalKey para la nota ${note.id}',
        );
        return;
      }

      if (key.currentContext == null) {
        debugPrint(
          '⏳ Scroll: Key encontrada pero el Contexto aún es null (esperando renderizado)',
        );
        return;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        final ctx = key.currentContext;
        if (ctx == null) return;

        // 3. Confirmación de inicio de movimiento
        debugPrint(
          '🚀 Scroll: ¡Iniciando scroll hacia la nota: ${note.title} (Index: $index)!',
        );

        _didScrollToHighlight = true;

        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: 0.1, // 0.0 es arriba del todo, 1.0 es abajo. 0.1 la deja un pelín bajada del borde.
        );
      });
    });
  }

  GlobalKey _getKey(String id) {
    return _itemKeys.putIfAbsent(id, () => GlobalKey());
  }
}
