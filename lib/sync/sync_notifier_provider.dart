import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/google/auth_provider.dart';
import 'package:tag_links/sync/drive_sync_config_manager.dart';
import 'package:tag_links/core/google/local_id_manager.dart';
import 'package:tag_links/core/google/models/auth_exeptions.dart';
import 'package:tag_links/state/folders_provider.dart';
import 'package:tag_links/state/notes_provider.dart';
import 'package:tag_links/sync/exceptions/sync_exceptions.dart';
import 'package:tag_links/sync/last_sync_storage.dart';
import 'package:tag_links/sync/models/device_info.dart';
import 'package:tag_links/sync/sync_puller.dart';
import 'package:tag_links/sync/sync_pusher.dart';
import 'dart:async';

enum SyncStatus { idle, syncing, success, error }

class SyncState {
  final SyncStatus status;
  final String? lastError;
  final int lastSyncTimestamp;

  SyncState({
    this.status = SyncStatus.idle,
    this.lastError,
    this.lastSyncTimestamp = 0,
  });

  SyncState copyWith({
    SyncStatus? status,
    String? lastError,
    int? lastSyncTimestamp,
  }) {
    return SyncState(
      status: status ?? this.status,
      lastError: lastError,
      lastSyncTimestamp: lastSyncTimestamp ?? this.lastSyncTimestamp,
    );
  }
}

class SyncNotifier extends AsyncNotifier<SyncState> {
  SyncPuller? get _syncPuller => ref.read(syncPullerProvider);
  @override
  Future<SyncState> build() async {
    // USA ESTO: Lee el valor una sola vez sin suscribirte
    final storage = ref.read(lastSyncTimestampProvider.notifier);
    final lastTime = storage.state ?? 0;

    return SyncState(lastSyncTimestamp: lastTime);
  }

  final _forceDelay = const Duration(seconds: 25);

  Future<void> synchronize({
    Duration delay = const Duration(minutes: 4),
  }) async {
    final currentState = state.value;
    if (currentState?.status == SyncStatus.syncing) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final lastSync = currentState?.lastSyncTimestamp ?? 0;

    if (lastSync == 0 || (now - lastSync) >= delay.inMilliseconds) {
      await forceSynchronize();
    }
  }

  Future<void> forceSynchronize() async {
    // 1. Evitar múltiples ejecuciones
    if (state.value?.status == SyncStatus.syncing) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final lastSync = state.value?.lastSyncTimestamp ?? 0;

    // Cooldown para no saturar Drive
    if (lastSync != 0 && (now - lastSync) < _forceDelay.inMilliseconds) {
      debugPrint("ForceSync ignorado: Cooldown activo.");
      return;
    }

    try {
      // 2. Iniciar estado visual de carga
      state = AsyncData(state.value!.copyWith(status: SyncStatus.syncing));

      // 3. Ejecutar la lógica pesada
      await _realSyncLogic();

      // 4. Éxito: Cambiamos a success y actualizamos timestamp
      if (ref.mounted) {
        state = AsyncData(
          SyncState(
            status: SyncStatus.success,
            lastSyncTimestamp: DateTime.now().millisecondsSinceEpoch,
          ),
        );

        // 🎯 FEEDBACK INTERACTIVO: Volver a 'idle' tras 3 segundos
        // Esto hace que el icono de "check" verde vuelva a ser el de "sync" normal
        Future.delayed(const Duration(seconds: 3), () {
          if (ref.mounted && state.value?.status == SyncStatus.success) {
            state = AsyncData(state.value!.copyWith(status: SyncStatus.idle));
          }
        });
      }
    } catch (e) {
      debugPrint("Sync Error: $e");
      if (ref.mounted) {
        state = AsyncData(
          state.value!.copyWith(
            status: SyncStatus.error,
            lastError: _mapErrorToHumanMessage(e),
          ),
        );
      }
    }
  }

  /// El "motor" de la sincronización. Aquí no manejamos estados de UI,
  /// solo la lógica de datos.
  Future<void> _realSyncLogic() async {
    // A. REPARACIÓN Y CLIENTE
    final isAuthReady = await ref
        .read(authProvider.notifier)
        .attemptSessionRepair();

    if (!isAuthReady) throw AuthSyncException();

    // 2. IMPORTANTE: El cliente HTTP debe ser el nuevo
    // Tu AuthNotifier al hacer _updateStateWithNewAuth crea un nuevo DriveApi
    // Asegúrate de que el resto de tus DAOs/Managers usen el driveApi del estado actual.
    final driveApi = ref.read(authProvider).driveApi;
    if (driveApi == null) throw AuthSyncException();

    await Future.delayed(const Duration(milliseconds: 100));

    final configManager = ref.read(syncConfigProvider);
    if (configManager == null) throw ConfigSyncException();

    // B. FASE 0: CONFIGURACIÓN REMOTA
    final remoteData = await configManager.getOrInitializeRemoteConfig();
    if (remoteData == null) throw NetworkSyncException();

    final idManager = ref.read(localIdManagerProvider);
    final storage = ref.read(lastSyncTimestampProvider.notifier);
    final lastPulled = state.value?.lastSyncTimestamp ?? 0;

    if (_syncPuller == null) return;

    // C. FASE 1: PULL (RECONCILIACIÓN -> BORRADOS -> DATOS)
    // Reconciliación (IDs de Drive)
    final archiveRes = await _syncPuller!.processRemoteArchive(
      remote: remoteData.config.archiveInfo,
    );
    if (!archiveRes.success) {
      throw DataSyncException("Fallo en reconciliación"); // 🎯
    }
    // Pull de Borrados
    final deleteRes = await _syncPuller!.processRemoteDeletes(
      remoteData.config.archiveInfo.deletes,
      lastPulled,
    );
    if (!deleteRes.success) throw DataSyncException("Error en borrados"); // 🎯

    // Pull de Datos
    final dataRes = await _syncPuller!.processRemoteData(
      remoteData.config.archiveInfo,
      lastPulled,
    );
if (!dataRes.success) throw DataSyncException("Error en descarga de datos"); // 🎯
    // D. ACTUALIZACIÓN DE UI (Invalida providers si hubo cambios)
    final totalPullChanges = deleteRes.merge(dataRes);
    if (totalPullChanges.anyChanges) {
      if (totalPullChanges.foldersChanged) ref.invalidate(foldersProvider);
      if (totalPullChanges.notesChanged) ref.invalidate(notesProvider);
      debugPrint("✨ UI invalidada: Cambios detectados.");
    }

    // E. FASE 2: PUSH (SUBIR CAMBIOS LOCALES)
    final pusher = ref.read(syncPusherProvider);
    if (pusher == null) throw AuthSyncException(); // Si es null es porque no hay DriveApi listo

    final updatedArchive = await pusher.pushLocalChanges(
    currentArchive: remoteData.config.archiveInfo,
  );

    // F. FASE 3: CIERRE (ACTUALIZAR CONFIG Y TIMESTAMP)
    final now = DateTime.now().millisecondsSinceEpoch;
    final finalConfig = remoteData.config
        .copyWith(archiveInfo: updatedArchive, lastGlobalUpdate: now)
        .upsertDevice(
          DeviceInfo.createCurrent(idManager.getOrCreateDeviceId()),
        );

    await configManager.updateRemoteConfig(remoteData.fileId, finalConfig);
    storage.updateTimestamp(now);
  }

  String _mapErrorToHumanMessage(Object e) {
    return switch (e) {
      NetworkSyncException() => "Revisa tu conexión",
      AuthSyncException() => "Inicia sesión de nuevo",
      DriveStorageException() => "Error de espacio en Drive",
      DataSyncException() => "Error al procesar archivos",
      ConfigSyncException() => "Error de configuración",
      _ => "Error inesperado",
    };
  }
}

final syncProvider = AsyncNotifierProvider<SyncNotifier, SyncState>(
  SyncNotifier.new,
);
