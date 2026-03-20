import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/ads/small_banner.dart';
import 'package:tag_links/core/debug/go_debug_page_buton.dart';
import 'package:tag_links/core/locate/app_lang.dart';
import 'package:tag_links/models/folder.dart';
import 'package:tag_links/models/folder_preference.dart';
import 'package:tag_links/state/folder_preference_provider.dart';
import 'package:tag_links/ui/app_bar/app_bar_folder.dart';
import 'package:tag_links/ui/button/bottom_switch_folder_note.dart';
import 'package:tag_links/ui/button/create_new_folder_button.dart';
import 'package:tag_links/ui/button/go_settings_button.dart';
import 'package:tag_links/ui/folder/banner_pending_folder.dart';
import 'package:tag_links/ui/folder/build_folders_section.dart';
import 'package:tag_links/ui/note/banner_pending_note.dart';
import 'package:tag_links/ui/note/build_notes_section.dart';
import 'package:tag_links/ui/note/create_new_note_btn.dart';
import 'package:tag_links/ui/search/root_search_section.dart';
import 'package:tag_links/utils/paginated_utils.dart';

class HomePage extends ConsumerStatefulWidget {
  final Folder? folder;
  final String? highlightNoteId;

  final PaginatedByDate? paginated;

  const HomePage({
    super.key,
    required this.folder,
    this.paginated,
    this.highlightNoteId,
  });

  @override
  ConsumerState<HomePage> createState() => _FolderPageState();
}

class _FolderPageState extends ConsumerState<HomePage> {
  AsyncNotifierProvider<FolderPreferenceNotifier, FolderDefaultView>
  get _foldersPreferenceProvider => folderPreferenceProvider(widget.folder?.id);

  bool get _isRoot => widget.folder == null;
  bool get _isLimitFolder => widget.folder?.parentId != null;

  @override
  Widget build(BuildContext context) {
    debugPrint("-------------- Entro al home ----------------");
    final preferenceAsync = ref.watch(_foldersPreferenceProvider);
    final theme = Theme.of(context);
    return preferenceAsync.when(
      loading: () => const Scaffold(
        backgroundColor: Colors.purple,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(body: Center(child: Text('Error: $err'))),
      data: (preference) {
        final showFolders = _isLimitFolder
            ? false
            : preference == FolderDefaultView.folders;
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: _appBar(showFolders, preference),
          floatingActionButton: _floatingActionButton(showFolders),
          //--------------------- body ---------------------
          body: SafeArea(
            child: Column(
              children: [
                BannerPendingNote(
                  key: const ValueKey('banner_note'),
                  toFolderId: widget.folder?.id,
                  onToggleView: () => _selectView(
                    FolderDefaultView.notes,
                  ), // Cambia a notas al guardar
                ),
                BannerPendingFolder(
                  key: const ValueKey('banner_folder'),
                  toParent: widget.folder,
                  onToggleView:
                      () => _selectView(
                    FolderDefaultView.folders,
                  ), // Cambia a
                ),
                if (_isRoot) const RootSearchSection(),
                Expanded(
                  child: showFolders
                      ? FoldersSection(parentId: widget.folder?.id)
                      : NotesSection(
                          folderId: widget.folder?.id,
                          highlightNoteId: widget.highlightNoteId,
                        ),
                ),
              ],
            ),
          ),
          // --------------------- footer ---------------------
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SmartBannerAd(key: Key('global_banner')),
              const SizedBox(height: 8),
              if (!_isLimitFolder)
                BottomButtonBar(
                  defaultview: preference,
                  onSelect: (newPreference) => _selectView(newPreference),
                ),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _appBar(bool showFolders, FolderDefaultView preference) {
    if (_isRoot) {
      return AppBarPages(
        title: t(ref, "appName", fallback: 'Tag Links'),
        actions: [if (kDebugMode) GoDebugPageButon(), GoSettingsButton()],
      );
    }
    return AppBarPages(title: widget.folder!.title);
  }

  /// 🔁 Cambiar vista y guardar preferencia
  Future<void> _selectView(FolderDefaultView select) async {
    return await ref
        .read(_foldersPreferenceProvider.notifier)
        .updatePreference(select);
  }

  /// ➕ FAB dinámico
  Widget _floatingActionButton(bool showFolders) {
    return showFolders
        ? CreateNewFolderButton(parentFolderId: widget.folder?.id)
        : CreateNewNoteButton(folderId: widget.folder?.id);
  }
}
