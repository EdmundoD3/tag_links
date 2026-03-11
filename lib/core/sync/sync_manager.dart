import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/api/api_services.dart';
import 'package:tag_links/core/auth/token_storage.dart';
import 'package:tag_links/core/encypt/encypter_services.dart';
import 'package:tag_links/core/sync/folder_raw_sync.dart';
import 'package:tag_links/core/sync/last_sync_storage.dart';
import 'package:tag_links/core/sync/note_raw_sync.dart';
import 'package:tag_links/data/data_sources/folder_preferences_dao.dart';
import 'package:tag_links/data/data_sources/folders_dao.dart';
import 'package:tag_links/data/data_sources/notes_dao.dart';
import 'package:tag_links/models/folder.dart';
import 'package:tag_links/models/note.dart';
import 'package:tag_links/repository/folder_repository.dart';
import 'package:tag_links/repository/notes_repository.dart';
import 'package:tag_links/service/conection_service.dart';

class SyncData<T> {
  final List<T> data;
  final int? lastDate;
  final bool hasMore;

  SyncData({required this.data, required this.lastDate, required this.hasMore});
  factory SyncData.empty() =>
      SyncData(data: [], lastDate: null, hasMore: false);
}

enum SyncManagerStatus {
  ok,
  notOk,
  alreadyRunning,
  notHasAccessToken,
  itsTooErarly,
  limitStorageReached,
  notConection,
  notConectionServer,
}

class _PerformSyncStatus {
  final SyncManagerStatus status;
  final bool? isPremium;

  _PerformSyncStatus({required this.status, required this.isPremium});
}

class SyncManager extends Notifier<SyncManagerStatus> {
  static bool _isSyncing = false;
  final _tokenStorage = TokenStorage();
  final _syncStorage = SyncStorage();
  final _encryptionService = EncryptionService();

  NotesRepository get _notesRepository => ref.watch(notesRepositoryProvider);
  FolderRepository get _foldersRepository => ref.watch(folderRepositoryProvider);
  final ConnectionService _connectionService = ConnectionService();

  @override
  SyncManagerStatus build() {
    return SyncManagerStatus.ok;
  }

  Future<SyncManagerStatus> sync(void Function(bool) onUpdateIsPremium) async {
    if (_isSyncing) return SyncManagerStatus.alreadyRunning;
    _isSyncing = true;
    try {
      if (!await _connectionService.hasPhysicalConnection()) {
        return SyncManagerStatus.notConection;
      }
      if (!await _connectionService.hasInternet()) {
        return SyncManagerStatus.notConectionServer;
      }

      final accessToken = await _tokenStorage.get();
      if (accessToken == null) return SyncManagerStatus.notHasAccessToken;
      final status = await _performSync(accessToken: accessToken);
      if (status.isPremium != null) onUpdateIsPremium.call(status.isPremium!);
      return status.status;
    } catch (e) {
      debugPrint('Sync Error: $e');
      return SyncManagerStatus.notOk;
    } finally {
      _isSyncing = false;
    }
  }

  Future<_PerformSyncStatus> _performSync({required String accessToken}) async {
    int? lastPulledAt = await _syncStorage.getLastPulledAt();
    int? lastPushedAt = await _syncStorage.getLastPushedAt();

    String currentLastId = "";

    bool hasMoreLocal = true;
    bool hasMoreRemote = true;
    int safetyCounter = 0;
    bool? isPremium;
    while ((hasMoreLocal || hasMoreRemote) && safetyCounter < 50) {
      safetyCounter++;
      // 1. Obtener datos locales (Notas y Carpetas)
      final notesBatch = hasMoreLocal
          ? await _notesRepository.getForSync(lastPushedAt)
          : SyncData<NoteRawSync>.empty();

      final foldersBatch = hasMoreLocal
          ? await _foldersRepository.getForSync(lastPushedAt)
          : SyncData<FolderRawSync>.empty();

      // 2. Sincronización Bidireccional
      final response = await ApiServices.sync(
        accessToken: accessToken,
        notes: notesBatch.data,
        folders: foldersBatch.data,
        lastPulledAt: lastPulledAt,
        lastId: currentLastId,
      );

      if (!response.isOk) {
        isPremium = response.data?.isPremium;
        switch (response.status) {
          case SyncApiStatus.limitStorageReached:
            return _PerformSyncStatus(
              status: SyncManagerStatus.limitStorageReached,
              isPremium: isPremium,
            );
          case SyncApiStatus.unauthorized:
            return _PerformSyncStatus(
              status: SyncManagerStatus.notHasAccessToken,
              isPremium: isPremium,
            );
          case SyncApiStatus.failed:
          default:
            return _PerformSyncStatus(
              status: SyncManagerStatus.notOk,
              isPremium: isPremium,
            );
        }
      }
      final syncRes = response.data!.sync;

      // 3. Procesar PUSH (Subida) exitoso
      if (syncRes.save.ok) {
        // Marcamos como sincronizados los borrados locales para que no se envíen más
        // Suponiendo que tienes un método clearDeleted en tus repositorios
        final deletedIds = notesBatch.data
            .where((e) => e.deletedAt != null)
            .map((e) => e.id)
            .toList();
        if (deletedIds.isNotEmpty) {
          await _notesRepository.deleteByIds(deletedIds);
        }

        // Actualizar cursor de subida
        final maxLocalDate = [
          notesBatch.lastDate ?? 0,
          foldersBatch.lastDate ?? 0,
        ].reduce((a, b) => a > b ? a : b);

        if (maxLocalDate > 0) {
          lastPushedAt = maxLocalDate;
          await _syncStorage.setLastPushedAt(maxLocalDate);
        }
        hasMoreLocal = notesBatch.hasMore || foldersBatch.hasMore;
      } else {
        hasMoreLocal = false; // Detener subida si hay error de cuota
      }

      // 4. Procesar PULL (Bajada)
      final pull = syncRes.pull;
      if (pull.ok) {
        final pullData = pull.data!;

        await _processRemoteData(pullData);

        lastPulledAt = pull.cursor;
        hasMoreRemote = pull.hasMore;

        if (pullData.notes.isNotEmpty) {
          currentLastId = pullData.notes.last.id;
        }

        if (lastPulledAt != null) {
          await _syncStorage.setLastPulledAt(lastPulledAt);
        }
      } else {
        hasMoreRemote = false;
      }
      isPremium = response.data?.isPremium;
    }

    return _PerformSyncStatus(
      status: SyncManagerStatus.ok,
      isPremium: isPremium,
    );
  }

  Future<void> _processRemoteData(PullData pullData) async {
    final keyBytes = await _encryptionService.getRawKeyBytes();

    // El Isolate hace el trabajo pesado
    final result = await compute(
      _backgroundProcess,
      _ProcessDataArgs(pullData.notes, pullData.folders, keyBytes),
    );

    // Borrados remotos
    final deletedNoteIds = pullData.notes
        .where((n) => n.deletedAt != null)
        .map((n) => n.id)
        .toList();
    final deletedFolderIds = pullData.folders
        .where((f) => f.deletedAt != null)
        .map((f) => f.id)
        .toList();

    // Guardado masivo
    if (result.notes.isNotEmpty) await _notesRepository.upsertAll(result.notes);

    if (result.folders.isNotEmpty) {
      await _foldersRepository.upsertAll(result.folders);
    }

    if (deletedNoteIds.isNotEmpty) {
      await _notesRepository.deleteByIds(deletedNoteIds);
    }
    if (deletedFolderIds.isNotEmpty) {
      await _foldersRepository.deleteByIds(deletedFolderIds);
    }
  }

  static Future<_DecryptedDataResult> _backgroundProcess(
    _ProcessDataArgs args,
  ) async {
    // Aquí no hay acceso al estado de la app, solo a los args
    final notes = <Note>[];
    final folders = <Folder>[];

    // Instanciamos un servicio temporal con la llave que recibimos
    final tempService = EncryptionService.fromBytes(args.keyBytes);

    for (final raw in args.notesRaw) {
      if (raw.deletedAt == null) {
        // Usamos el método que ya tienes pero inyectando el servicio
        final decrypted = await tempService.decrypt(raw.payload);
        notes.add(Note.fromDecryptedJson(raw.id, decrypted));
      }
    }

    for (final raw in args.foldersRaw) {
      if (raw.deletedAt == null) {
        final decrypted = await tempService.decrypt(raw.payload);
        folders.add(Folder.fromDecryptedJson(raw.id, decrypted));
      }
    }

    return _DecryptedDataResult(notes, folders);
  }
}

// ==========================================
// AUXILIARES FUERA DE LA CLASE (Para Isolate)
// ==========================================

class _DecryptedDataResult {
  final List<Note> notes;
  final List<Folder> folders;
  _DecryptedDataResult(this.notes, this.folders);
}

class _ProcessDataArgs {
  final List<NoteRawSync> notesRaw;
  final List<FolderRawSync> foldersRaw;
  final List<int> keyBytes;

  _ProcessDataArgs(this.notesRaw, this.foldersRaw, this.keyBytes);
}
