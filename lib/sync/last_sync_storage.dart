import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/data/shared_prefs_provider.dart';

final lastSyncProvider = NotifierProvider<LastSyncNotifier, SyncMetadata>(
  LastSyncNotifier.new,
);

class SyncMetadata {
  final int? lastPulledAt;
  final String? lastLoggedEmail;

  SyncMetadata({this.lastPulledAt, this.lastLoggedEmail});
}

class LastSyncNotifier extends Notifier<SyncMetadata> {
  SyncStorage get _storage => ref.read(_syncStorageProvider);

  @override
  SyncMetadata build() {
    // Lectura síncrona inmediata al arrancar la app
    return SyncMetadata(
      lastPulledAt: _storage.getLastPulledAt(),
      lastLoggedEmail: _storage.getLastLoggedEmail(),
    );
  }

  // Shortcut para actualizar solo el correo si inicia sesión por primera vez
  void update({String? email, int? lastPulledAt}) {
    if (email != null) _storage.setLastLoggedEmail(email);
    if (lastPulledAt != null) _storage.setLastPulledAt(lastPulledAt);
    state = SyncMetadata(
      lastPulledAt: lastPulledAt ?? state.lastPulledAt,
      lastLoggedEmail: email ?? state.lastLoggedEmail,
    );
  }

  void clear() {
    _storage.clear();
    state = SyncMetadata(lastPulledAt: null, lastLoggedEmail: null);
  }
}

// =========================
// STORAGE EXTENDIDO
// =========================
class SyncStorage {
  static const _lastPulledKey = 'sync_last_pulled_at';
  static const _lastEmailKey = 'sync_last_logged_email';
  final SharedPreferences _prefs;

  SyncStorage(SharedPreferences prefs) : _prefs = prefs;

  int? getLastPulledAt() => _prefs.getInt(_lastPulledKey);
  void setLastPulledAt(int timestamp) =>
      _prefs.setInt(_lastPulledKey, timestamp);

  String? getLastLoggedEmail() => _prefs.getString(_lastEmailKey);

  void setLastLoggedEmail(String email) =>
      _prefs.setString(_lastEmailKey, email);

  void clear() {
    _prefs.remove(_lastPulledKey);
    _prefs.remove(_lastEmailKey);
  }
}

final _syncStorageProvider = Provider<SyncStorage>((ref) {
  return SyncStorage(ref.read(sharedPrefsProvider));
});
