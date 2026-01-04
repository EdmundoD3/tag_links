import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/repository/notes_repository.dart';
import '../models/folder.dart';

class FoldersNotifier extends Notifier<List<Folder>> {
  FoldersNotifier(this.folderId);

  final String? folderId;
  late final NotesRepository _repo;

  @override
  List<Folder> build() {
    _repo = ref.read(notesRepositoryProvider);

    if (folderId == null) {
      return _repo.getFolders();
    }

    return _repo.getSubFolders(folderId!);
  }

  void addFolder(Folder folder) {
    _repo.saveFolder(folder);
    state = [...state, folder];
  }

  void deleteFolder(String id) {
    _repo.deleteFolder(id);
    state = folderId == null
        ? _repo.getFolders()
        : _repo.getSubFolders(folderId!);
  }
}

final foldersProvider =
    NotifierProvider.family<FoldersNotifier, List<Folder>, String?>(
  FoldersNotifier.new,
);
