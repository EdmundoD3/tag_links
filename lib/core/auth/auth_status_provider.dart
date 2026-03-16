import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tag_links/core/auth/auth_types.dart';

class AuthStatusNotifier extends Notifier<AuthMode> {
  final _storage = _AuthStatusStorage();

  @override
  AuthMode build() {
    _relaod();
    // Aquí deberías cargar el estado desde SharedPreferences de forma síncrona
    // o inicializar y luego cargar.
    return AuthMode.initial;
  }

  void _relaod() {
    _storage.get().then((mode) {
      if (mode != null) {
        state = mode;
      }
    });
  }

  void setMode(AuthMode mode) {
    state = mode;
    _storage.save(mode);
  }

  void clean() {
    state = AuthMode.initial;
    _storage.clean();
  }

  void reauth() {
    state = AuthMode.reauth;
    _storage.save(AuthMode.reauth);
  }

  void logged() {
    state = AuthMode.logged;
    _storage.save(AuthMode.logged);
  }

  void guest() {
    state = AuthMode.guest;
    _storage.save(AuthMode.guest);
  }
}

class _AuthStatusStorage {
  final String _key = 'auth_mode_key';
  Future<void> save(AuthMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }

  Future<AuthMode?> get() async {
    final prefs = await SharedPreferences.getInstance();
    final modeName = prefs.getString(_key);
    if (modeName == null) return null;
    return AuthMode.values.firstWhere((m) => m.name == modeName);
  }

  Future<void> clean() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

final authStatusProvider = NotifierProvider<AuthStatusNotifier, AuthMode>(
  AuthStatusNotifier.new,
);
