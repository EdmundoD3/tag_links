import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/data/shared_prefs_provider.dart';

final lastSyncTimestampProvider = NotifierProvider<LastSyncNotifier, int?>(
  LastSyncNotifier.new,
);

// El Notifier que mantiene el estado en memoria y sincroniza con el storage
class LastSyncNotifier extends Notifier<int?> {
  SyncStorage get _storage => ref.watch(_syncStorageProvider);

  @override
  int? build() {
    _init();
    return null;
  }

  Future<void> _init() async {
    state = await getLastPulledAt();
  }

  Future<void> updateTimestamp(int timestamp) async {
    await _storage.setLastPulledAt(timestamp);
    state = timestamp; // Esto notifica a todos los que hacen ref.watch
  }
  Future<int?> getLastPulledAt() async {
    return state;
  }

  Future<void> clear() async {
    await _storage.clear();
    state = null;
  }
}

final _syncStorageProvider = Provider<SyncStorage>((ref) {
  return SyncStorage(ref.watch(sharedPrefsProvider));
});

class SyncStorage {
  //Última descarga exitosa
  static const _lastPulledKey = 'sync_last_pulled_at';
  final SharedPreferences _prefs;
  SyncStorage(SharedPreferences prefs) : _prefs = prefs;

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
