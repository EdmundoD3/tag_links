import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/data/data_sources/tags_dao.dart';
import 'package:tag_links/models/tag.dart';
import 'package:tag_links/utils/paginated_utils.dart';

class TagsRepository {
  final TagsDao _tagsDao;

  TagsRepository({TagsDao? tagsDao}) : _tagsDao = tagsDao ?? TagsDao();

  Future<void> insert(Tag tag) {
    final tagToInsert = tag.ensureForInsert();
    return _tagsDao.insert(tagToInsert);
  }

  Future<void> update(Tag tag) {
    final tagToUpdate = tag.ensureForInsert();
    return _tagsDao.update(tagToUpdate);
  }

  Future<void> delete(String id) => _tagsDao.delete(id);

  Future<Tag?> getById(String id) => _tagsDao.getById(id);

  Future<List<Tag>> getAll({required PaginatedByUsage paginated}) =>
      _tagsDao.getAll(paginated: paginated);

  Future<List<Tag>> getByName(
    String name, {
    required PaginatedByUsage paginated,
  }) => _tagsDao.getByName(name, paginated: paginated);
}

final tagsRepositoryProvider = Provider<TagsRepository>((ref) {
  return TagsRepository();
});
