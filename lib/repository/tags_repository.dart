import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tag_links/data/data_sources/deleted_dao.dart';
import 'package:tag_links/data/data_sources/tags_dao.dart';
import 'package:tag_links/data/database.dart';
import 'package:tag_links/models/tag.dart';
import 'package:tag_links/sync/db/local_sync_queue_dao.dart';
import 'package:tag_links/sync/db/local_sync_queue_repository.dart';
import 'package:tag_links/sync/models/tags_file.dart';
import 'package:tag_links/utils/paginated_utils.dart';

class TagsRepository {
  final TagsDao _tagsDao;

  TagsRepository({
    required Database db,
    required DeletedDao deletedTagsDao,
    required LocalSyncQueueRepository syncRepo,
  }) : _tagsDao = TagsDao(db, deletedTagsDao, LocalSyncQueueDao(db));

  Future<Tag?> upsert(Tag tag) async {
    final tagToInsert = tag.ensureForInsert();
    return _tagsDao.insertIfNotExist(tagToInsert);
  }

  Future<void> update(Tag tag) async {
    final tagToUpdate = tag.ensureForInsert();
    return _tagsDao.update(tagToUpdate);
  }

  Future<void> delete(Tag tag) async {
    _tagsDao.delete(tag);
  }

  // ---------- get ----------
  Future<Tag?> getById(String id) => _tagsDao.getById(id);

  Future<List<Tag>> getAll({required PaginatedByUsage paginated}) =>
      _tagsDao.getAll(paginated: paginated);

  Future<List<Tag>> getByTitle(
    String title, {
    required PaginatedByUsage paginated,
  }) => _tagsDao.getByTitle(title, paginated: paginated);

  Future<Tag?> getByExactlyTitle(String title) => _tagsDao.getByExactlyTitle(title);

  // --- SYNC section ---
  Future<List<Tag>> getByFileId(String fileId) => _tagsDao.getByFileId(fileId);

  /// Genera el Wrapper de etiquetas listo para la sincronización.
  Future<TagsFile> getFileWrapper({
    required String fileId,
    String? driveFileId,
    required DateTime now,
  }) async {
    final items = await getByFileId(fileId);

    return TagsFile(
      id: fileId,
      fileId: driveFileId ?? '',
      tags: items,
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<void> upsertAll(List<Tag> tags) async {
    return _tagsDao.upsertAll(tags);
  }

  Future<void> serverDeleteByIds(List<String> ids) async {
    return _tagsDao.serverDeleteByIds(ids);
  }

  // Obtener los registros borrados para subirlos a la nube
  Future<List<DeletedData>> getDeletedBatch(String fileId) =>
      _tagsDao.getBatchByFileId(fileId);
}

final tagsRepositoryProvider = Provider<TagsRepository>((ref) {
  final db = ref.read(databaseProvider);
  final syncRepo = ref.read(localSyncQueueRepositoryProvider);
  return TagsRepository(
    db: db,
    deletedTagsDao: ref.read(deletedDaoProvider),
    syncRepo: syncRepo,
  );
});
