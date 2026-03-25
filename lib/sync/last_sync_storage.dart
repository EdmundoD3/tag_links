import 'package:shared_preferences/shared_preferences.dart';

class SyncStorage {
  //Última descarga exitosa
  static const _lastPulledKey = 'sync_last_pulled_at';
  final SharedPreferences _prefs;
  SyncStorage(SharedPreferences prefs): _prefs = prefs;

  // =========================
  // GETTERS
  // =========================

  Future<int?> getLastPulledAt() async {
    return _prefs.getInt(_lastPulledKey);
    }

  // =========================
  // SETTERS
  // =========================

  Future<void> setLastPulledAt(int timestamp) async {
    await _prefs.setInt(_lastPulledKey, timestamp);
  }

  // =========================
  // RESET
  // =========================

  Future<void> clear() async {
    await _prefs.remove(_lastPulledKey);
  }
}