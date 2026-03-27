import 'package:tag_links/sync/models/archive_info.dart';
import 'package:tag_links/sync/models/device_info.dart';

class ConfigInfo {
  final int lastGlobalUpdate;
  final List<DeviceInfo> devices;
  final ArchiveInfo archiveInfo;
  final int version;
  final int premiumUntil;
  final String? purchaseToken;
  final String? productId;

  ConfigInfo({
    required this.lastGlobalUpdate,
    required this.devices,
    required this.archiveInfo,
    required this.version,
    this.premiumUntil = 0,
    this.purchaseToken,
    this.productId,
  });

  bool get isPremium => premiumUntil > DateTime.now().millisecondsSinceEpoch;

  bool hasDevice(String id) => devices.any((d) => d.id == id);

  ConfigInfo upsertDevice(DeviceInfo thisDevice) {
    // Usamos el operador de cascada y toList() para asegurar inmutabilidad limpia
    final updatedDevices = List<DeviceInfo>.from(devices);
    final index = updatedDevices.indexWhere((d) => d.id == thisDevice.id);

    if (index != -1) {
      updatedDevices[index] = thisDevice;
    } else {
      updatedDevices.add(thisDevice);
    }

    return copyWith(
      devices: updatedDevices,
      lastGlobalUpdate: DateTime.now().millisecondsSinceEpoch,
    );
  }

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
      // Usamos 'as int?' o 'toInt()' para evitar errores si JSON lo lee como double
      lastGlobalUpdate: (map['last_global_update'] as num? ?? 0).toInt(),
      version: (map['version'] as num? ?? 1).toInt(),
      premiumUntil: (map['premium_until'] as num? ?? 0).toInt(),
      productId: map['product_id'] as String?,
      purchaseToken: map['purchase_token'] as String?,
      devices: (map['devices'] as List? ?? [])
          .map((d) => DeviceInfo.fromMap(Map<String, dynamic>.from(d as Map)))
          .whereType<DeviceInfo>()
          .toList(),
      archiveInfo: ArchiveInfo.fromMap(
        map["archive_info"] != null 
            ? Map<String, dynamic>.from(map["archive_info"] as Map) 
            : null,
      ),
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
    int? version, // Añadido para que no sea estático
    int? premiumUntil,
  }) {
    return ConfigInfo(
      lastGlobalUpdate: lastGlobalUpdate ?? this.lastGlobalUpdate,
      devices: devices ?? this.devices,
      // Se agregó la lógica para permitir setear null en los campos opcionales
      purchaseToken: purchaseToken ?? this.purchaseToken,
      productId: productId ?? this.productId,
      archiveInfo: archiveInfo ?? this.archiveInfo,
      version: version ?? this.version,
      premiumUntil: premiumUntil ?? this.premiumUntil,
    );
  }
}