import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/google/auth_provider.dart';
import 'package:tag_links/state/tags_provider.dart';
import 'package:tag_links/sync/drive_sync_config_manager.dart';
import 'package:tag_links/core/google/local_id_manager.dart';
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
    final storage = ref.read(lastSyncProvider.notifier);
    final lastTime = storage.state.lastPulledAt ?? 0;

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
        final SyncState newState =
            state.value?.copyWith(
              status: SyncStatus.error,
              lastError: _mapErrorToHumanMessage(e),
            ) ??
            SyncState(
              status: SyncStatus.error,
              lastError: _mapErrorToHumanMessage(e),
            );
        state = AsyncData(newState);
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

    final driveApi = ref.read(authProvider).driveApi;
    if (driveApi == null) throw AuthSyncException();

    await Future.delayed(const Duration(milliseconds: 100));

    final configManager = ref.read(syncConfigProvider);
    if (configManager == null) throw ConfigSyncException();

    // B. FASE 0: CONFIGURACIÓN REMOTA (Limpio y directo)
    // Si esto falla con 401, sube solo. Si devuelve null, es error de red.
    final remoteData = await configManager.getOrInitializeRemoteConfig();
    if (remoteData == null) throw NetworkSyncException();

    // A partir de aquí, remoteData ya no es nulo y es seguro usarlo
    final idManager = ref.read(localIdManagerProvider);
    final storage = ref.read(lastSyncProvider.notifier);
    final lastPulled = state.value?.lastSyncTimestamp ?? 0;

    if (_syncPuller == null) return;

    // C. FASE 1: PULL
    final archiveRes = await _syncPuller!.processRemoteArchive(
      remote: remoteData.config.archiveInfo,
    );
    if (!archiveRes.success) throw DataSyncException("Fallo en reconciliación");

    final deleteRes = await _syncPuller!.processRemoteDeletes(
      remoteData.config.archiveInfo.deletes,
      lastPulled,
    );
    if (!deleteRes.success) throw DataSyncException("Error en borrados");

    final dataRes = await _syncPuller!.processRemoteData(
      remoteData.config.archiveInfo,
      lastPulled,
    );
    if (!dataRes.success) throw DataSyncException("Error en descarga de datos");

    // D. ACTUALIZACIÓN DE UI
    final totalPullChanges = deleteRes.merge(dataRes);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!ref.mounted) return;

      if (totalPullChanges.foldersChanged) {
        ref.invalidate(foldersProvider);
      }

      if (totalPullChanges.notesChanged) {
        ref.invalidate(notesProvider);
      }

      if (totalPullChanges.tagsChanged) {
        ref.invalidate(tagsProvider);
      }
    });

    // E. FASE 2: PUSH
    final pusher = ref.read(syncPusherProvider);
    if (pusher == null) throw AuthSyncException();

    final updatedArchive = await pusher.pushLocalChanges(
      currentArchive: remoteData.config.archiveInfo,
    );

    // F. FASE 3: CIERRE
    final now = DateTime.now().millisecondsSinceEpoch;
    final finalConfig = remoteData.config
        .copyWith(archiveInfo: updatedArchive, lastGlobalUpdate: now)
        .upsertDevice(
          DeviceInfo.createCurrent(idManager.getOrCreateDeviceId()),
        );

    await configManager.updateRemoteConfig(remoteData.fileId, finalConfig);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!ref.mounted) return;
      storage.update(lastPulledAt: now);
    });
  }

  String _mapErrorToHumanMessage(Object e) {
    // Log para depuración
    debugPrint("Mapping error: $e");

    if (e.toString().contains('401')) {
      return "AUTH_401"; // Código interno para el botón
    }

    return switch (e) {
      NetworkSyncException() => "Revisa tu conexión",
      AuthSyncException() => "Inicia sesión de nuevo",
      _ => "Error inesperado",
    };
  }
}

final syncProvider = AsyncNotifierProvider<SyncNotifier, SyncState>(
  SyncNotifier.new,
);
