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
  final LocalSyncQueueRepository _syncRepo;

  TagsRepository({
    required Database db,
    required DeletedDao deletedTagsDao,
    required LocalSyncQueueRepository syncRepo,
  }) : _tagsDao = TagsDao(db, deletedTagsDao, LocalSyncQueueDao(db)),
       _syncRepo = syncRepo;

  Future<Tag?> upsert(Tag tag) async {
    final tagToInsert = tag.ensureForInsert();
    await _syncRepo.markAsDirty(tag.fileId);
    return _tagsDao.insertIfNotExist(tagToInsert);
  }

  Future<void> update(Tag tag) async {
    final tagToUpdate = tag.ensureForInsert();
    await _syncRepo.markAsDirty(tag.fileId);
    return _tagsDao.update(tagToUpdate);
  }

  Future<void> delete(Tag tag) async {
    await _syncRepo.markAsDirty(tag.fileId);
    // Si ya existía en Drive, registramos el ID para la próxima sincronización
    _tagsDao.delete(tag.id);
  }

  // ---------- get ----------
  Future<Tag?> getById(String id) => _tagsDao.getById(id);

  Future<List<Tag>> getAll({required PaginatedByUsage paginated}) =>
      _tagsDao.getAll(paginated: paginated);

  Future<List<Tag>> getByName(
    String name, {
    required PaginatedByUsage paginated,
  }) => _tagsDao.getByName(name, paginated: paginated);

  Future<Tag?> getByExactlyName(String name) => _tagsDao.getByExactlyName(name);

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

  Future<void> clearDeletedTags(List<String> ids) => _tagsDao.clearDeletedTags(ids);
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
