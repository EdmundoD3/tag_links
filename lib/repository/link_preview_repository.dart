import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/data/data_sources/link_preview_dao.dart';
import 'package:tag_links/models/link_preview.dart';

class LinkPreviewRepository {
  final LinkPreviewDao _dao;
  LinkPreviewRepository(this._dao);

  Future<void> replace(LinkPreview link) async {
    if (!link.hasMetadata) return;
    await _dao.replace(noteId: link.noteId, link: link);
  }
}

final linkPreviewRepositoryProvider = Provider<LinkPreviewRepository>((ref) {
  return LinkPreviewRepository(LinkPreviewDao());
});
