import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/debug/go_debug_page_buton.dart';
import 'package:tag_links/core/locate/app_lang.dart';
import 'package:tag_links/models/folder_preference.dart';
import 'package:tag_links/models/note.dart';
import 'package:tag_links/models/tag.dart';
import 'package:tag_links/state/is_folder_provider.dart';
import 'package:tag_links/state/notes_provider.dart';
import 'package:tag_links/state/search_query_provider.dart';
import 'package:tag_links/state/pending_note_provider.dart';
import 'package:tag_links/state/tags_provider.dart';
import 'package:tag_links/ui/alerts/confirm_dialog.dart';
import 'package:tag_links/ui/app_bar/app_bar_folder.dart';
import 'package:tag_links/ui/banners/banner_pending.dart';
import 'package:tag_links/ui/button/bottom_switch_folder_note.dart';
import 'package:tag_links/ui/button/create_new_folder_button.dart';
import 'package:tag_links/ui/button/go_settings_button.dart';
import 'package:tag_links/ui/button/switch_favorite.dart';
import 'package:tag_links/ui/button/switch_folder_note.dart';
import 'package:tag_links/ui/folder/banner_pending_folder.dart';
import 'package:tag_links/ui/folder/build_folders_list.dart';
import 'package:tag_links/ui/note/build_notes_list.dart';
import 'package:tag_links/ui/page_widgets/page_scaffold.dart';
import 'package:tag_links/ui/search/search_bar.dart';
import 'package:tag_links/ui/tags/tag_selected_container.dart';
import 'package:tag_links/utils/note_helpers.dart';
import '../state/folders_provider.dart';
import '../models/folder.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels <=
          _scrollController.position.minScrollExtent + 120) {
        final isFolder = ref.read(isFolderProvider);

        if (isFolder) {
          ref.read(foldersProvider(null).notifier).loadMore();
        } else {
          ref.read(notesProvider(null).notifier).loadMore();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasPendingNotes = ref.watch(hasPendingNoteProvider);
    final foldersAsync = ref.watch(foldersViewProvider);
    final bool isFolder = ref.watch(isFolderProvider);

    //en este caso como valor inicial o sea cuando no hay parametros de busqueda que empieze con las notas favoritas
    final notesAsync = ref.watch(notesViewProvider);
    return PageScaffold(
      appBar: _appBar(ref, isFolder),
      floatingActionButton: CreateNewFolderButton(
        isRoot: true,
        parentFolderId: null,
      ),
      bottomButtonBar: BottomButtonBar(
        defaultview: isFolder
            ? FolderDefaultView.folders
            : FolderDefaultView.notes,
        onSelect: (newPreference) {
          final isFolder = newPreference == FolderDefaultView.folders;
            ref.read(isFolderProvider.notifier).set(isFolder);
            ref.invalidate(foldersProvider(null));
            ref.invalidate(notesProvider(null));
          },
      ),
      body: _body(ref, isFolder, hasPendingNotes, foldersAsync, notesAsync),
    );
  }

  PreferredSizeWidget _appBar(WidgetRef ref, bool isFolder) {
    return AppBarPages(
      title: t(ref, "appName", fallback: 'Tag Links'),
      actions: [
        if (kDebugMode) GoDebugPageButon(),
        GoSettingsButton(),
      ],
    );
  }

  List<Widget> _body(
    WidgetRef ref,
    bool isFolder,
    bool hasPendingNotes,
    AsyncValue<List<Folder>> foldersAsync,
    AsyncValue<List<Note>> notesAsync,
  ) {
    return [
      if (hasPendingNotes) _bannerHasPendingNotes(context, ref),
      //si se almacena siempre sera folder
      BannerPendingFolder(
        toParentId: null,
        onToggleView: () => ref.read(isFolderProvider.notifier).set(true),
      ),
      const SizedBox(height: 16),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: _searchBar(ref, isFolder),
      ),
      const SizedBox(height: 16), // Reducido de 32 para ganar espacio
      _selectedIncludeTags(ref),
      // 🚀 EXTREMADAMENTE IMPORTANTE:
      // Envolvemos el Expanded en un Flexible o aseguramos que el
      // ListView/GridView interno tenga una altura definida.
      Expanded(
        child: Container(
          // Un color transparente ayuda a debuguear áreas de renderizado
          color: Colors.transparent,
          child: isFolder
              ? _buildFolders(foldersAsync)
              : _buildNotes(notesAsync),
        ),
      ),
    ];
  }

  Widget _buildFolders(AsyncValue<List<Folder>> foldersAsync) {
    final notifier = ref.read(foldersProvider(null).notifier);
    return BuildFoldersList(
      foldersAsync: foldersAsync,
      scrollController: _scrollController,
      notifier: notifier,
      onDeleteFolder: (id) => ConfirmDialog.deleteFolder(
        context,
        ref,
        () => notifier.deleteFolder(id),
      ),
    );
  }

  /// 📝 Lista de notas
  Widget _buildNotes(AsyncValue<List<Note>> notesAsync) {
    final notifier = ref.read(notesProvider(null).notifier);
    return BuildNotesList(
      notesAsync: notesAsync,
      scrollController: _scrollController,
      goFolder: (Note note) => NoteHelpers.goFolder(context, ref, note),
      isLoadingMore: notifier.isLoadingMore,
      onDeleteNote: (id) => ConfirmDialog.deleteNote(
        context,
        ref,
        () async => notifier.deleteNote(id),
      ),
    );
  }

  Widget _searchBar(WidgetRef ref, bool isFolder) {
    return SearchListBar(
      iconLeftBtn: SwitchFavorite(
        isFavorite: ref.read(searchQueryProvider).isFavorite,
        onChanged: () {
          ref.read(searchQueryProvider.notifier).toggleFavorite();
        },
      ),
      onChangeText: (String text) => _onChangeText(ref, text),
      onTagSelected: (Tag tag) {
        ref.read(searchQueryProvider.notifier).addTag(tag);
      },
      queryText: ref.watch(searchQueryProvider).text,
      tagsSuggestion: ref.watch(tagsProvider),
    );
  }

  Widget _selectedIncludeTags(WidgetRef ref) {
    return TagsSelectedContainer(
      tags: ref.watch(searchQueryProvider).includeTags,
      onDeleted: (Tag tag) {
        ref.read(searchQueryProvider.notifier).removeTag(tag);
      },
      isCreateTag: false,
    );
  }

  //las notas no pueden estar en la carpeta raiz, por eso aqui solo se permite descartar la nota
  Widget _bannerHasPendingNotes(BuildContext context, WidgetRef ref) {
    return BannerPending(
      title: t(
        ref,
        'pendingNotesTitle',
        fallback: 'Elige una carpeta donde almacenar la nota',
      ),
      actions: [
        BannerOptionsTile(
          onTap: () async {
            final confirm = await showConfirmDialog(
              context,
              title: t(ref, 'bannerNotMove', fallback: 'No mover'),
              message: t(
                ref,
                'discardAction',
                fallback: '¿Estás seguro de descartar la acción?',
              ),
              ref: ref,
            );

            if (confirm == true) {
              ref.read(pendingNoteProvider.notifier).clear();
            }
          },
          title: t(ref, 'discard', fallback: 'Descartar'),
        ),
      ],
    );
  }

  void _onChangeText(WidgetRef ref, String text) {
    ref.read(searchQueryProvider.notifier).setText(text);
    ref.read(tagSearchTextProvider.notifier).state = text;

    // 🔁 fuerza rebuild limpio
    ref.invalidate(foldersProvider(null));
    ref.invalidate(notesProvider(null));
  }
}
