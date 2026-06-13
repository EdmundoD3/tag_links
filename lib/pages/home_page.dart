import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/ads/small_banner.dart';
import 'package:tag_links/core/debug/go_debug_page_buton.dart';
import 'package:tag_links/core/locate/t_keys.dart';
import 'package:tag_links/core/media_in_coming/pending_note_provider.dart';
import 'package:tag_links/models/folder.dart';
import 'package:tag_links/models/folder_preference.dart';
import 'package:tag_links/state/folder_preference_provider.dart';
import 'package:tag_links/sync/widgets/manual_sync_button.dart';
import 'package:tag_links/ui/app_bar/app_bar_folder.dart';
import 'package:tag_links/ui/button/bottom_switch_folder_note.dart';
import 'package:tag_links/ui/button/create_new_folder_button.dart';
import 'package:tag_links/ui/button/go_settings_button.dart';
import 'package:tag_links/ui/folder/banner_pending_folder.dart';
import 'package:tag_links/ui/folder/build_folders_section.dart';
import 'package:tag_links/ui/form/note_mini_form.dart';
import 'package:tag_links/ui/is_loading_indicators/scaffold_loading.dart';
import 'package:tag_links/ui/note/banner_pending_note.dart';
import 'package:tag_links/ui/note/build_notes_section.dart';
import 'package:tag_links/ui/note/create_new_note_btn.dart';
import 'package:tag_links/ui/search/root_search_section.dart';
import 'package:tag_links/utils/paginated_utils.dart';

class HomePage extends ConsumerWidget {
  final Folder? folder;
  final String? highlightNoteId;
  final PaginatedByDate? paginated;

  const HomePage({
    super.key,
    required this.folder,
    this.paginated,
    this.highlightNoteId,
  });

  bool get _isRoot => folder == null;
  bool get _isLimitFolder => folder?.parentId != null;

  AsyncNotifierProvider<FolderPreferenceNotifier, FolderDefaultView>
      get _foldersPreferenceProvider => folderPreferenceProvider(folder?.id);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferenceAsync = ref.watch(_foldersPreferenceProvider);
        final pendingNote = ref.watch(pendingNoteProvider);

    final theme = Theme.of(context);

    return preferenceAsync.when(
      loading: () => const ScaffoldLoading(),
      error: (err, _) {
        debugPrint('_HomePage.build Error: $err');
        return const Scaffold(body: Center(child: Text('Error: preferences')));
      },
      data: (preference) {
        final showFolders =
            preference == FolderDefaultView.folders && !_isLimitFolder;

        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: _appBar(ref: ref, showFolders: showFolders),
            body: SafeArea(
              child: Stack(
                children: [
                  Column(
                    children: [
                      if(pendingNote != null) BannerPendingNote(
                        key: const ValueKey('banner_note'),
                        pendingNote: pendingNote,
                        toFolderId: folder?.id,
                        onToggleView: () =>
                            _selectView(FolderDefaultView.notes, ref),
                      ),
                      BannerPendingFolder(
                        key: const ValueKey('banner_folder'),
                        toParent: folder,
                        onToggleView: () =>
                            _selectView(FolderDefaultView.folders, ref),
                      ),

                      if (_isRoot) const RootSearchSection(),

                      Expanded(
                        child: _isLimitFolder
                            ? NotesSection(
                                folderId: folder?.id,
                                highlightNoteId: highlightNoteId,
                              )
                            : HomeSwipeableBody(
                                folder: folder,
                                highlightNoteId: highlightNoteId,
                                preference: preference,
                              ),
                      ),
                    ],
                  ),

                  if (!showFolders)
                    Positioned(
                      bottom: 10,
                      right: 0,
                      left: 0,
                      child: NoteMiniForm(folderId: folder?.id),
                    ),
                ],
              ),
            ),
            bottomNavigationBar: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SmartBannerAd(key: Key('global_banner')),
                const SizedBox(height: 8),
                if (!_isLimitFolder)
                  BottomButtonBar(
                    defaultview: preference,
                    onSelect: (newPreference) =>
                        _selectView(newPreference, ref),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _appBar({
    required WidgetRef ref,
    required bool showFolders,
  }) {
    return AppBarPages(
      title: _isRoot
          ? ref.tr(TKeys.pages.appName, fallback: 'Tag Links')
          : folder!.title,
      actions: [
        if (kDebugMode) GoDebugPageButon(),
        if (_isRoot) const ManualSyncButton(),
        if (_isRoot) const GoSettingsButton(),
        _buildCreationButton(showFolders),
      ],
    );
  }

  /// 🔁 Cambiar vista (Guardando preferencia desde los botones)
  Future<void> _selectView(FolderDefaultView select, WidgetRef ref) async {
    await ref
        .read(_foldersPreferenceProvider.notifier)
        .updatePreference(select);
  }

  /// ➕ FAB dinámico
  Widget _buildCreationButton(bool showFolders) {
    return showFolders
        ? CreateNewFolderButton(parentFolderId: folder?.id)
        : CreateNewNoteButton(folderId: folder?.id);
  }
}

class HomeSwipeableBody extends ConsumerStatefulWidget {
  final Folder? folder;
  final String? highlightNoteId;
  final FolderDefaultView preference;

  const HomeSwipeableBody({
    super.key,
    required this.folder,
    required this.highlightNoteId,
    required this.preference,
  });

  @override
  ConsumerState<HomeSwipeableBody> createState() => _HomeSwipeableBodyState();
}

class _HomeSwipeableBodyState extends ConsumerState<HomeSwipeableBody> {
  late final PageController _pageController;
  // 🔑 Guardamos localmente el índice real de la página para desempatar eventos
  late int _localPageIndex;

  AsyncNotifierProvider<FolderPreferenceNotifier, FolderDefaultView>
      get _preferenceProvider => folderPreferenceProvider(widget.folder?.id);

  @override
  void initState() {
    super.initState();
    _localPageIndex = widget.preference.pageIndex;
    _pageController = PageController(initialPage: _localPageIndex);
  }

  @override
  void didUpdateWidget(HomeSwipeableBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 🛡️ Solo saltamos de página si la preferencia externa cambió 
    // Y no coincide con la página que el usuario ya está viendo localmente.
    if (oldWidget.preference != widget.preference &&
        widget.preference.pageIndex != _localPageIndex &&
        _pageController.hasClients) {
      
      _localPageIndex = widget.preference.pageIndex;
      
      // Usamos jumpToPage de forma segura tras el post-frame para evitar colisiones estéticas
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients) {
          _pageController.jumpToPage(_localPageIndex);
        }
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      onPageChanged: (index) async {
        // Actualizamos la posición local de inmediato
        _localPageIndex = index;
        
        final view = FolderDefaultViewX.fromPage(index);
        if (view == widget.preference) return;

        await ref
            .read(_preferenceProvider.notifier)
            .updatePreference(view);
      },
      children: [
        FoldersSection(parentId: widget.folder?.id),
        NotesSection(
          folderId: widget.folder?.id,
          highlightNoteId: widget.highlightNoteId,
        ),
      ],
    );
  }
}