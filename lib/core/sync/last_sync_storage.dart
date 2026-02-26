import 'package:shared_preferences/shared_preferences.dart';

class SyncStorage {
  //Última descarga exitosa
  static const _lastPulledKey = 'sync_last_pulled_at';
  //Última subida exitosa
  static const _lastPushedKey = 'sync_last_pushed_at';
  SyncStorage();

  // =========================
  // GETTERS
  // =========================

  Future<int?> getLastPulledAt() async {
    final instance = await SharedPreferences.getInstance(); 
    return instance.getInt(_lastPulledKey);
    }

  Future<int?> getLastPushedAt() async => (await SharedPreferences.getInstance()).getInt(_lastPushedKey);

  // =========================
  // SETTERS
  // =========================

  Future<void> setLastPulledAt(int timestamp) async {
    await (await SharedPreferences.getInstance()).setInt(_lastPulledKey, timestamp);
  }

  Future<void> setLastPushedAt(int timestamp) async {
    await (await SharedPreferences.getInstance()).setInt(_lastPushedKey, timestamp);
  }

  // =========================
  // RESET
  // =========================

  Future<void> clear() async {
    await (await SharedPreferences.getInstance()).remove(_lastPulledKey);
    await (await SharedPreferences.getInstance()).remove(_lastPushedKey);
  }
}