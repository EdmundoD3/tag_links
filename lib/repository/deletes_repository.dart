import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/data/data_sources/deleted_dao.dart';
import 'package:tag_links/data/database.dart';
import 'package:tag_links/sync/models/delete_file.dart';
import 'package:tag_links/sync/models/local_sync_queue.dart';

class DeletesRepository {
  final DeletedDao _deletedDao;

  DeletesRepository({required DeletedDao deletedDao})
    : _deletedDao = deletedDao;

  /// Centraliza la creación del Wrapper de borrados filtrando por el bucket (meta.id).
  Future<DeleteFile> getDeleteFileWrapper(LocalSyncQueue meta) async {
    // 1. Consultamos la tabla única pasando el tipo correspondiente
    // Esto es mucho más limpio que el Future.wait de 3 DAOs
    final nDel = await _deletedDao.getBatchByFileIdAndType(
      meta.id,
      DeletedType.note,
    );
    final fDel = await _deletedDao.getBatchByFileIdAndType(
      meta.id,
      DeletedType.folder,
    );
    final tDel = await _deletedDao.getBatchByFileIdAndType(
      meta.id,
      DeletedType.tag,
    );

    // 2. Construimos el DeleteFile listo para subir a Drive
    return DeleteFile(
      id: meta.id,
      fileId: meta.driveFileId ?? '',
      notes: nDel
          .map((e) => DeleteItem(id: e.id, deletedAt: e.deletedAt))
          .toList(),
      folders: fDel
          .map((e) => DeleteItem(id: e.id, deletedAt: e.deletedAt))
          .toList(),
      tags: tDel
          .map((e) => DeleteItem(id: e.id, deletedAt: e.deletedAt))
          .toList(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Future<void> cleanOldDeletes({int days = 15}) async => _deletedDao.cleanOldDeletes(days: days);


  /// Mantenemos extractDirtyIds para los upserts de los otros repositorios
  /// pero ahora todos apuntan al mismo DAO pasando el String del tipo
  Future<Set<String>> extractDirtyIds(List<String> ids, TypeQueue type) async {
    if (ids.isEmpty) return {};

    // Mapeamos el Enum a los strings que usa la tabla 'deletes'
    final DeletedType typeStr = switch (type) {
      TypeQueue.notes => DeletedType.note,
      TypeQueue.folders => DeletedType.folder,
      TypeQueue.tags => DeletedType.tag,
      TypeQueue.deletes => throw UnimplementedError(),
    };

    return _deletedDao.extractDirtyIdsByType(ids,type: typeStr);
  }
  Future<void> upsertAllFromRemote(DeleteFile remoteFile) {
    return _deletedDao.upsertAllFromRemote(remoteFile);
  }
}

// Cambié el nombre a deletesRepositoryProvider para que sea claro
final deletesRepositoryProvider = Provider<DeletesRepository>((ref) {
  final db = ref.watch(
    databaseProvider,
  ); // Usamos watch por si la DB se reinicia
  return DeletesRepository(deletedDao: DeletedDao(db));
});
