import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/data/shared_prefs_provider.dart';

final lastSyncTimestampProvider = NotifierProvider<LastSyncNotifier, int?>(
  LastSyncNotifier.new,
);

// El Notifier que mantiene el estado en memoria y sincroniza con el storage
class LastSyncNotifier extends Notifier<int?> {
  SyncStorage get _storage => ref.read(_syncStorageProvider);

@override
  int? build() {
    // 2. LEER DIRECTAMENTE: Sin _init(), sin async.
    // Accedemos a los SharedPreferences que ya están en el provider.
    return _storage.getLastPulledAt();
  }

  void updateTimestamp(int timestamp)  {
     _storage.setLastPulledAt(timestamp);
    state = timestamp; // Esto notifica a todos los que hacen ref.watch
  }
  int? getLastPulledAt()  {
    return state;
  }

  void clear()  {
     _storage.clear();
    state = null;
  }
}

final _syncStorageProvider = Provider<SyncStorage>((ref) {
  return SyncStorage(ref.read(sharedPrefsProvider));
});

class SyncStorage {
  //Última descarga exitosa
  static const _lastPulledKey = 'sync_last_pulled_at';
  final SharedPreferences _prefs;
  SyncStorage(SharedPreferences prefs) : _prefs = prefs;

  // =========================
  // GETTERS
  // =========================

  int? getLastPulledAt() {
    return _prefs.getInt(_lastPulledKey);
  }

  // =========================
  // SETTERS
  // =========================

  void setLastPulledAt(int timestamp) {
     _prefs.setInt(_lastPulledKey, timestamp);
  }

  // =========================
  // RESET
  // =========================

  void clear() {
     _prefs.remove(_lastPulledKey);
  }
}
