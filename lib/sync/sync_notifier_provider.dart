import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/google/auth_provider.dart';
import 'package:tag_links/core/google/drive_sync_config_manager.dart';
import 'package:tag_links/core/google/local_id_manager.dart';
import 'package:tag_links/state/folders_provider.dart';
import 'package:tag_links/state/notes_provider.dart';
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

  final _forceDelay = const Duration(seconds: 30);

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
    if (state.value?.status == SyncStatus.syncing) return;
    // --- NUEVO: VERIFICACIÓN DE SESIÓN ---
    final authState = ref.read(authProvider); // Leemos tu AuthNotifier
    if (!authState.isAuthenticated) {
      debugPrint(
        "🚫 Sync abortado: El usuario no ha iniciado sesión en Drive.",
      );
      state = AsyncData(
        state.value!.copyWith(
          status: SyncStatus.error,
          lastError: "Inicia sesión para sincronizar con la nube",
        ),
      );
      return;
    }
    // Marcamos inicio inmediatamente
    final now = DateTime.now().millisecondsSinceEpoch;
    final lastSync = state.value?.lastSyncTimestamp ?? 0;

    // limite de forzado
    if (lastSync != 0 && (now - lastSync) < _forceDelay.inMilliseconds) {
      debugPrint("ForceSync ignorado: Cooldown activo.");
      return;
    }
    // 1. Iniciamos estado de carga
    state = AsyncData(state.value!.copyWith(status: SyncStatus.syncing));

    try {
      // Obtenemos dependencias bajo demanda
      final configManager = ref.read(syncConfigProvider);
      if (configManager == null) throw Exception("ConfigManager no disponible");

      final idManager = ref.read(localIdManagerProvider);
      final storage = ref.read(lastSyncTimestampProvider.notifier);

      // FASE 0: Config
      final remoteData = await configManager.getOrInitializeRemoteConfig();
      if (remoteData == null) return;
      final lastPulled = state.value?.lastSyncTimestamp ?? 0;

      // FASE 1: PULL (Usamos los REPOS directamente)

      if (_syncPuller == null) return;
      // FASE A: Reconciliación de Infraestructura
      final archiveRes = await _syncPuller!.processRemoteArchive(
        remote: remoteData.config.archiveInfo,
      );
      if (!archiveRes.success) return; // Detenemos si no pudimos mapear los IDs

      // FASE B: Pull de Datos (Borrados y Nuevos)
      final deleteRes = await _syncPuller!.processRemoteDeletes(
        remoteData.config.archiveInfo.deletes,
        lastPulled,
      );
      final dataRes = await _syncPuller!.processRemoteData(
        remoteData.config.archiveInfo,
        lastPulled,
      );

      // FASE C: Reacción de la UI
      final totalPullChanges = deleteRes.merge(dataRes);

      if (totalPullChanges.anyChanges) {
        if (totalPullChanges.foldersChanged) ref.invalidate(foldersProvider);
        if (totalPullChanges.notesChanged) ref.invalidate(notesProvider);
        debugPrint("✨ UI actualizada tras cambios remotos.");
      }
      // --------------------

      // FASE 2: PUSH
      final pusher = ref.read(syncPusherProvider);
      if (pusher == null) return;
      final updatedArchive = await pusher.pushLocalChanges(
        currentArchive: remoteData.config.archiveInfo,
      );

      // FASE 3: CIERRE
      final finalConfig = remoteData.config
          .copyWith(archiveInfo: updatedArchive, lastGlobalUpdate: now)
          .upsertDevice(
            DeviceInfo.createCurrent(idManager.getOrCreateDeviceId()),
          );

      await configManager.updateRemoteConfig(remoteData.fileId, finalConfig);
      storage.updateTimestamp(now);

      if (ref.mounted) {
        state = AsyncData(
          SyncState(status: SyncStatus.success, lastSyncTimestamp: now),
        );
      }
    } catch (e, stack) {
      debugPrint("Sync Error: $e");
      if (ref.mounted) {
        state = AsyncData(
          state.value!.copyWith(
            status: SyncStatus.error,
            lastError: e.toString(),
          ),
        );
      }
    }
  }
}

final syncProvider = AsyncNotifierProvider<SyncNotifier, SyncState>(
  SyncNotifier.new,
);
