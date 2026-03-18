import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/models/folder_preference.dart';
import 'package:tag_links/repository/folder_repository.dart';
import 'package:tag_links/utils/debouncer.dart';

final folderPreferenceProvider =
    AsyncNotifierProvider.family<
      FolderPreferenceNotifier,
      FolderDefaultView,
      String?
    >(FolderPreferenceNotifier.new);


// --------  folderId == null significa que estamos en root  -----------
class FolderPreferenceNotifier extends AsyncNotifier<FolderDefaultView> {
  final String? folderId;
  FolderPreferenceNotifier(this.folderId);

  final _debouncer = Debouncer(milliseconds: 700);

  FolderRepository get _repo => ref.watch(folderRepositoryProvider);
  bool get _isRoot => folderId == null;

  @override
  Future<FolderDefaultView> build() async {
    ref.onDispose(_debouncer.dispose);

    if(_isRoot) return FolderDefaultView.folders;

    return _repo.getPreference(folderId!);
  }

  Future<void> updatePreference(FolderDefaultView value) async {
    if (state.value == value) return;

    // Actualizamos la UI inmediatamente (Optimistic)
    state = AsyncData(value);

    if(_isRoot) return;

    _debouncer.run(() async {
      // Usamos state.value para asegurarnos de guardar lo que la UI está mostrando actualmente
      final valueToSave = state.value;
      if (valueToSave != null) {
        await _repo.savePreference(folderId!, valueToSave);
      }
    });
  }
}
