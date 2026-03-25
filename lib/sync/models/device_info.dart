
import 'dart:io';

class DeviceInfo {
  final String id;
  final String system;
  final String model;
  final int lastSync;

  DeviceInfo({
    required this.id,
    required this.system,
    required this.model,
    required this.lastSync,
  });

  // Factory para persistencia
  static DeviceInfo? fromMap(Map<String, dynamic> map) {
    if (map['id'] == null || map['system'] == null || map['model'] == null) {
      return null;
    }
    return DeviceInfo(
      id: map['id'],
      system: map['system'],
      model: map['model'],
      lastSync: map['last_sync'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
    "id": id,
    "system": system,
    "model": model,
    "last_sync": lastSync,
  };

  /// Método estático para generar la representación del dispositivo actual
  /// Nota: El ID debe persistirse localmente (SharedPreferences) para no generar
  /// un nuevo UUID cada vez que se abra la app.
  static DeviceInfo createCurrent(String persistentId) {
    return DeviceInfo(
      id: persistentId,
      system: Platform.operatingSystem,
      model: Platform.localHostname,
      lastSync: DateTime.now().millisecondsSinceEpoch,
    );
  }
}

