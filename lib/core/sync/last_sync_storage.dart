import 'package:shared_preferences/shared_preferences.dart';

class SyncStorage {
  //Última descarga exitosa
  static const _lastPulledKey = 'sync_last_pulled_at';
  SyncStorage();

  // =========================
  // GETTERS
  // =========================

  Future<int?> getLastPulledAt() async {
    final instance = await SharedPreferences.getInstance(); 
    return instance.getInt(_lastPulledKey);
    }

  // =========================
  // SETTERS
  // =========================

  Future<void> setLastPulledAt(int timestamp) async {
    await (await SharedPreferences.getInstance()).setInt(_lastPulledKey, timestamp);
  }

  // =========================
  // RESET
  // =========================

  Future<void> clear() async {
    await (await SharedPreferences.getInstance()).remove(_lastPulledKey);
  }
}