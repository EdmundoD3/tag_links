import 'package:tag_links/sync/models/archive_info.dart';
import 'package:tag_links/sync/models/device_info.dart';

class ConfigInfo {
  final int lastGlobalUpdate;
  final List<DeviceInfo> devices;
  final ArchiveInfo archiveInfo;
  final int version;
  final int premiumUntil; // Timestamp en ms. 0 si nunca ha comprado.
  final String? purchaseToken; // Token de la última compra válida
  final String? productId; // 'premium_monthly' o 'premium_yearly'
  ConfigInfo({
    required this.lastGlobalUpdate,
    required this.devices,
    required this.archiveInfo,
    required this.version,
    this.premiumUntil = 0,
    this.purchaseToken,
    this.productId,
  });

  /// Verifica si el usuario tiene una suscripción activa
  bool get isPremium => premiumUntil > DateTime.now().millisecondsSinceEpoch;

  /// Determina si un ID de dispositivo específico ya está registrado
  bool hasDevice(String id) => devices.any((d) => d.id == id);

  /// Agrega o actualiza un dispositivo en la lista de forma inmutable
  ConfigInfo upsertDevice(DeviceInfo thisDevice) {
    final List<DeviceInfo> updatedDevices = List.from(devices);
    final int index = updatedDevices.indexWhere((d) => d.id == thisDevice.id);

    if (index != -1) {
      updatedDevices[index] = thisDevice;
    } else {
      updatedDevices.add(thisDevice);
    }

    return copyWith(
      devices: updatedDevices,
      // Actualizamos el timestamp global cada vez que un dispositivo se reporta
      lastGlobalUpdate: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Detecta si hay otros dispositivos que se sincronizaron recientemente.
  /// Útil para decidir si la app debe pollear cambios más seguido.
  bool getHasFastSyncro(
    String myId, {
    Duration delay = const Duration(minutes: 10),
  }) {
    if (devices.length <= 1) return false;

    final threshold = DateTime.now().subtract(delay).millisecondsSinceEpoch;

    return devices.any(
      (device) => device.id != myId && device.lastSync > threshold,
    );
  }

  static ConfigInfo fromMap(Map<String, dynamic> map) {
    return ConfigInfo(
      lastGlobalUpdate: map['last_global_update'] ?? 0,
      version: map['version'] ?? 1,
      premiumUntil: map['premium_until'] ?? 0,
      productId: map['product_id'],
      purchaseToken: map['purchase_token'],
      devices: (map['devices'] as List? ?? [])
          .map((d) => DeviceInfo.fromMap(d as Map<String, dynamic>))
          .whereType<DeviceInfo>()
          .toList(),
      // Manejo seguro de ArchiveInfo
      archiveInfo: map["archive_info"] != null
          ? ArchiveInfo.fromMap(map["archive_info"])
          : ArchiveInfo(tags: [], folders: [], notes: [], deletes: []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "last_global_update": lastGlobalUpdate,
      "version": version,
      "product_id": productId,
      "purchase_token": purchaseToken,
      "premium_until": premiumUntil,
      "devices": devices.map((d) => d.toMap()).toList(),
      "archive_info": archiveInfo.toMap(),
    };
  }

  ConfigInfo copyWith({
    int? lastGlobalUpdate,
    String? purchaseToken,
    String? productId,
    List<DeviceInfo>? devices,
    ArchiveInfo? archiveInfo,
    int? premiumUntil,
  }) {
    return ConfigInfo(
      lastGlobalUpdate: lastGlobalUpdate ?? this.lastGlobalUpdate,
      devices: devices ?? this.devices,
      purchaseToken: purchaseToken ?? this.purchaseToken,
      productId: productId ?? this.productId,
      archiveInfo: archiveInfo ?? this.archiveInfo,
      version: version,
      premiumUntil: premiumUntil ?? this.premiumUntil,
    );
  }
}
