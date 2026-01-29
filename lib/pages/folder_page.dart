import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/models/folder.dart';
import 'package:tag_links/models/folder_preference.dart';
import 'package:tag_links/models/note.dart';
import 'package:tag_links/repository/folder_repository.dart';
import 'package:tag_links/state/folders_provider.dart';
import 'package:tag_links/state/notes_provider.dart';
import 'package:tag_links/ui/app_bar/app_bar_folder.dart';
import 'package:tag_links/ui/button/create_new_folder_button.dart';
import 'package:tag_links/ui/button/floating_button_base.dart';
import 'package:tag_links/ui/button/switch_folder_note.dart';
import 'package:tag_links/ui/folder/banner_pending_folder.dart';
import 'package:tag_links/ui/folder/build_folders_list.dart';
import 'package:tag_links/ui/note/banner_pending_note.dart';
import 'package:tag_links/ui/note/build_notes_list.dart';
import 'package:tag_links/ui/note/note_form_page.dart';
import 'package:tag_links/utils/paginated_utils.dart';

class FolderPage extends ConsumerStatefulWidget {
  final Folder folder;
  final String? highlightNoteId;

  final PaginatedByDate? paginated;

  const FolderPage({
    super.key,
    required this.folder,
    this.paginated, this.highlightNoteId,
  });

  @override
  ConsumerState<FolderPage> createState() => _FolderPageState();
}

class _FolderPageState extends ConsumerState<FolderPage> {
  final ScrollController _scrollController = ScrollController();
  bool _didScrollToHighlight = false;

  AsyncNotifierProvider<NotesNotifier, List<Note>> get _notesProvider =>
      notesProvider(widget.folder.id);
  AsyncNotifierProvider<FoldersNotifier, List<Folder>> get _folderProvider => foldersProvider(widget.folder.id);
  FutureProvider<FolderDefaultView> get _foldersPreferenceProvider => folderPreferenceProvider(widget.folder.id);

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      final position = _scrollController.position;
      final notifier = ref.read(_notesProvider.notifier);

      if (position.pixels >= position.maxScrollExtent - 200 &&
          notifier.hasMore &&
          !notifier.isLoadingMore) {
        notifier.loadMore();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final subFolders = ref.watch(_folderProvider);
    final notes = ref.watch(_notesProvider);
    final preferenceAsync = ref.watch(
      _foldersPreferenceProvider
    );

    return preferenceAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(body: Center(child: Text('Error: $err'))),
      data: (preference) {
        final showFolders = preference == FolderDefaultView.folders;

        if (!showFolders && widget.highlightNoteId != null) {
          _scrollToHighlightedNote(notes);
        }

        return Scaffold(
          appBar: _appBar(context, ref, showFolders, preference),
          floatingActionButton: _buildFab(context, showFolders),
          body: Column(
            children: [
              BannerPendingNote(toFolderId: widget.folder.id),
              BannerPendingFolder(toParentId: widget.folder.id),
              if (showFolders) _foldersList(subFolders) else _buildNotes(notes),
            ],
          ),
        );
      },
    );
  }

  /// 🎯 Scroll a la nota resaltada (solo una vez)
  void _scrollToHighlightedNote(AsyncValue<List<Note>> notesAsync) {
  if (_didScrollToHighlight) return;

  notesAsync.whenData((notes) {
    final index = notes.indexWhere((n) => n.id == widget.highlightNoteId);

    if (index == -1) {
      _didScrollToHighlight = true; // 👈 clave
      return;
    }

    _didScrollToHighlight = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _scrollController.animateTo(
        index * 72.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  });
}


  PreferredSizeWidget _appBar(
    BuildContext context,
    WidgetRef ref,
    bool showFolders,
    FolderDefaultView preference,
  ) {
    return appBar(
      title: widget.folder.title,
      actions: [
        SwitchFolderNote(
          isFolder: showFolders,
          onTap: () => _toggleView(ref, preference),
          size: 25,
        ),
        Padding(padding: EdgeInsetsGeometry.directional(end: 4)),
      ],
    );
  }

  /// 🔁 Cambiar vista y guardar preferencia
  Future<void> _toggleView(WidgetRef ref, FolderDefaultView current) async {
    final repo = ref.read(folderRepositoryProvider);
    final newView = current == FolderDefaultView.folders
        ? FolderDefaultView.notes
        : FolderDefaultView.folders;

    await repo.savePreference(widget.folder.id, newView);
    ref.invalidate(_foldersPreferenceProvider);
  }

  /// 📂 Lista de carpetas
  Widget _foldersList(AsyncValue<List<Folder>> subFolders) {
    final notifier = ref.read(_folderProvider.notifier);
    return BuildFoldersList(
      foldersAsync: subFolders,
      scrollController: _scrollController,
      notifier: notifier,
    );
  }

  Widget _buildNotes(AsyncValue<List<Note>> notesAsync) {
    final notifier = ref.watch(_notesProvider.notifier);
    return BuildNotesList(
      notesAsync: notesAsync,
      scrollController: _scrollController,
      isLoadingMore: notifier.isLoadingMore,
      onDeleteNote: (id) => notifier.deleteNote(id),
    );
  }

  /// ➕ FAB dinámico
  Widget _buildFab(BuildContext context, bool showFolders) {
    return showFolders
        ? CreateNewFolderButton(isRoot: false, parentFolderId: widget.folder.id)
        : _fabAddNote(context);
  }

  Widget _fabAddNote(BuildContext context) {
    return FloatingButonBase(
      heroTag: 'addNote',
      icon: Icons.note_add,
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NoteFormPage(folderId: widget.folder.id),
        ),
      ),
    );
  }
}
