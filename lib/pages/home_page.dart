import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:tag_links/ui/page_widgets/page_scaffold.dart';
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

  @override
  Widget build(BuildContext context) {
    final preferenceAsync = ref.watch(_foldersPreferenceProvider);

    return preferenceAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(body: Center(child: Text('Error: $err'))),
      data: (preference) {
        final showFolders = preference == FolderDefaultView.folders;

        return PageScaffold(
          appBar: _appBar(showFolders, preference),
          floatingActionButton: _floatingActionButton(showFolders),
          bottomButtonBar: BottomButtonBar(
            defaultview: preference,
            onSelect: (newPreference) => _selectView(newPreference),
          ),
          body: _body(showFolders: showFolders),
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

  List<Widget> _body({required bool showFolders}) {
    return [
      BannerPendingNote(
        toFolderId: widget.folder?.id,
        onToggleView: () => _selectView(FolderDefaultView.notes),
      ),
      BannerPendingFolder(
        toParentId: widget.folder?.id,
        onToggleView: () => _selectView(FolderDefaultView.folders),
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
    ];
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
        ? CreateNewFolderButton(
            isRoot: false,
            parentFolderId: widget.folder?.id,
          )
        : CreateNewNoteButton(folderId: widget.folder?.id);
  }
}