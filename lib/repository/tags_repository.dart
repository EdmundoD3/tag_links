import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tag_links/data/data_sources/deleted_dao.dart';
import 'package:tag_links/data/data_sources/tags_dao.dart';
import 'package:tag_links/data/database.dart';
import 'package:tag_links/models/tag.dart';
import 'package:tag_links/utils/paginated_utils.dart';

class TagsRepository {
  final TagsDao _tagsDao;
  final DeletedTagsDao _deletedDao;

  TagsRepository({required Database db, required DeletedTagsDao deletedTagsDao})
    : _tagsDao = TagsDao(db),
      _deletedDao = deletedTagsDao;

  Future<Tag?> upsert(Tag tag) async {
    final tagToInsert = tag.ensureForInsert();
    return _tagsDao.insertIfNotExist(tagToInsert);
  }

  Future<void> update(Tag tag) {
    final tagToUpdate = tag.ensureForInsert();
    return _tagsDao.update(tagToUpdate);
  }

  Future<void> delete(String id) => _tagsDao.delete(id);
  Future<void> deleteTag(Tag tag) async {
    // Si nunca se sincronizó, borrado físico directo sin dejar rastro
    if (tag.syncAt == null) {
      return _tagsDao.delete(tag.id);
    }

    // Si ya existía en Drive, registramos el ID para la próxima sincronización
    await _deletedDao.saveId(tag.id);

    // Borrado físico local (Triggers y Cascade se encargan del resto)
    return _tagsDao.delete(tag.id);
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

  Future<void> upsertAll(List<Tag> tags) => _tagsDao.upsertAll(tags);

  Future<List<Tag>> getPendingSync() => _tagsDao.getPendingSync();

  Future<void> updateSyncAt(List<String> ids, int syncAt, String fileId) => 
      _tagsDao.updateSyncAt(ids: ids, syncAt: syncAt, fileId: fileId);

  Future<void> deleteByIds(List<String> ids) => _tagsDao.serverDeleteByIds(ids);

  Future<List<DeletedData>> getDeletedBatch({int limit = 500}) => 
      _deletedDao.getBatch(limit: limit);

  Future<void> clearDeletedTags(List<String> ids) => _deletedDao.deleteIds(ids);
}

final tagsRepositoryProvider = Provider<TagsRepository>((ref) {
  final db = ref.read(databaseProvider);
  return TagsRepository(
    db: db,
    deletedTagsDao: DeletedTagsDao(db: db),
  );
});
