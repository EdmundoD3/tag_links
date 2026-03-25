import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class LocalIdManager {
  static const String _key = 'internal_device_uuid';
  final SharedPreferences _prefs;

  LocalIdManager(this._prefs);

  /// Obtiene el ID persistente. 
  /// Si no existe, lo genera y guarda al instante.
  String getOrCreateId() {
    String? existingId = _prefs.getString(_key);

    if (existingId == null) {
      existingId = const Uuid().v4();
      _prefs.setString(_key, existingId);
      debugPrint("🆔 Nuevo UUID generado: $existingId");
    }

    return existingId;
  }
}