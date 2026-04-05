import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tag_links/data/data_sources/deleted_dao.dart';
import 'package:tag_links/data/data_sources/tags_dao.dart';
import 'package:tag_links/data/database.dart';
import 'package:tag_links/models/tag.dart';
import 'package:tag_links/sync/db/local_sync_queue_repository.dart';
import 'package:tag_links/utils/paginated_utils.dart';

class TagsRepository {
  final TagsDao _tagsDao;
  final DeletedTagsDao _deletedDao;
  final LocalSyncQueueRepository _syncRepo;

  TagsRepository({
    required Database db,
    required DeletedTagsDao deletedTagsDao,
    required LocalSyncQueueRepository syncRepo,
  }) : _tagsDao = TagsDao(db),
       _deletedDao = deletedTagsDao,
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
    await _deletedDao.saveId(tag.id);
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

  Future<void> upsertAll(List<Tag> tags) async {
    final dirtysIds = await _deletedDao.extractDirtyIds(
      tags.map((e) => e.id).toList(),
    );
    final cleanTags = tags.where((e) => !dirtysIds.contains(e.id)).toList();

    return _tagsDao.upsertAll(cleanTags);
  }

  Future<void> serverDeleteByIds(List<String> ids) async {
    await _deletedDao.deleteIds(ids);
    return _tagsDao.serverDeleteByIds(ids);
  }

  Future<List<DeletedData>> getDeletedBatch({int limit = 500}) =>
      _deletedDao.getBatch(limit: limit);

  Future<void> clearDeletedTags(List<String> ids) => _deletedDao.deleteIds(ids);
}

final tagsRepositoryProvider = Provider<TagsRepository>((ref) {
  final db = ref.read(databaseProvider);
  return TagsRepository(
    db: db,
    deletedTagsDao: DeletedTagsDao(db: db),
    syncRepo: ref.read(localSyncQueueRepositoryProvider),
  );
});
