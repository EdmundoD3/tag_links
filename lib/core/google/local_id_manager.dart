import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tag_links/data/shared_prefs_provider.dart';
import 'package:uuid/uuid.dart';

final localIdManagerProvider = Provider<LocalIdManager>((ref) {
  final prefs = ref.read(sharedPrefsProvider);
  return LocalIdManager(prefs);
});


class LocalIdManager {
  static const String _deviceKey = 'internal_device_uuid';
  static const String _driveFileKey = 'cached_drive_file_id'; // <--- Nueva clave
  final SharedPreferences _prefs;

  LocalIdManager(this._prefs);

  /// IDENTIDAD DEL DISPOSITIVO
  /// Siempre debe existir. Si no está, se crea. 
  /// Es la "matrícula" de este teléfono.
  String getOrCreateDeviceId() {
    String? id = _prefs.getString(_deviceKey);
    if (id == null) {
      id = const Uuid().v4();
      _prefs.setString(_deviceKey, id);
    }
    return id;
  }

  /// PUNTERO AL ARCHIVO EN LA NUBE
  /// Esto es lo que evita el "pregunte y pregunte".
  String? getDriveFileId() => _prefs.getString(_driveFileKey);

  Future<void> saveDriveFileId(String id) async {
    await _prefs.setString(_driveFileKey, id);
  }

  Future<void> clearDriveFileId() async {
    await _prefs.remove(_driveFileKey);
  }
}