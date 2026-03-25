import 'package:tag_links/core/google/drive_sync_config_manager.dart';
import 'package:tag_links/sync/db/local_sync_queue_dao.dart';

class SyncManager {
  final DriveSyncConfigManager _configManager;
  final LocalSyncQueueDao _queueDao;

  SyncManager(this._configManager, this._queueDao);

  /// Punto de entrada para la sincronización.
  /// 1. Obtiene/Inicializa la configuración remota.
  /// 2. Compara con la base de datos local para encontrar cambios pendientes.
  /// 3. Llena la cola de sincronización local.
  Future<void> sync() async {
    // 1. Obtener configuración del servidor
    final RemoteConfigData? configData = await _configManager.getRemoteConfig();
    if (configData == null) return;
    final config = configData.config;

    // 2. Identificar qué archivos remotos no tenemos o están desactualizados
    final pendingDownloads = await _queueDao.getPendingDownloads(config);

    // TODO: Implementar la lógica de subida de cambios locales (Upload)
    // TODO: Notificar al SyncService para que empiece a descargar los 'pendingDownloads'
  }
}