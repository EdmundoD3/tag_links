import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/ads/ads_disable_provider.dart';
import 'package:tag_links/core/app_purchases/premium_provider.dart';
import 'package:tag_links/core/auth/auth_status_provider.dart';
import 'package:tag_links/core/sync/sync_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tag_links/core/sync/sync_types.dart';

// El estado ahora es simplemente un enum para saber el RESULTADO del último intento
enum SyncResultStatus { ok, error, reloging, limitStorageReached, nothing }

class SyncNotifier extends AsyncNotifier<SyncResultStatus> {
  final _delayManager = _DelayManager();
  final _syncManager = SyncManager();

  @override
  Future<SyncResultStatus> build() async {
    // Retornamos el estado inicial.
    // Si quieres que sincronice apenas abra la app, el trigger lo hará la UI o un splash.
    return SyncResultStatus.nothing;
  }

  Future<void> performSync({bool force = false}) async {
    // 1. Si ya está cargando, ignorar
    if (state.isLoading) return;
    final authMode = ref.read(authStatusProvider);
    // se necesita reloguear y este si importa notificar
    if(authMode == AuthMode.reauth) {
      state = const AsyncData(SyncResultStatus.reloging);
      return;
    }
    if (authMode != AuthMode.logged) return; //no se syncronizara ni necesita notificar

    // 2. Verificar delay (a menos que sea un "force sync" manual)
    if (!force) {
      final canSync = await _delayManager.canSync();
      if (!canSync) return;
    }

    state = const AsyncLoading();

    // 3. Ejecutar sincronización
    final result = await _syncManager.sync(
      (isPremium) => ref.read(premiumNotifierProvider.notifier).state = isPremium,
    );

    if (result == SyncManagerStatus.ok) {
      state = const AsyncData(SyncResultStatus.ok);

      // 4. Calcular próximo delay basado en el tipo de usuario
      int minutes = 240; // 4 horas por defecto

      final isPremium = ref.read(premiumNotifierProvider);
      final adsActivas = ref.read(isAdsActiveProvider);

      if (isPremium) {
        minutes = 5; // Usuarios de pago: 5 min
      } else if (!adsActivas) {
        // Si NO hay ads activas es porque vio un video (AdsDisabledNotifier)
        minutes = 30; // Usuario "recompensado": 30 min
      }

      await _delayManager.saveNextSync(minutes: minutes);
      return;
    } 
    if (result == SyncManagerStatus.notHasAccessToken) {
      //almacenamos para poder pedirle al usuario que reloguee
      ref.read(authStatusProvider.notifier).reauth();
      state = const AsyncData(SyncResultStatus.reloging);
      return;
    }
    if (result == SyncManagerStatus.limitStorageReached) {
      //almacenamos para poder pedirle al usuario que reloguee
      state = const AsyncData(SyncResultStatus.limitStorageReached);
      return;
    }
      state = const AsyncData(SyncResultStatus.error);
  }
}

final syncNotifierProvider =
    AsyncNotifierProvider<SyncNotifier, SyncResultStatus>(SyncNotifier.new);

// --- Lógica de Delay (Simplificada) ---

class _DelayManager {
  final String _key = 'sync_delay';

  Future<bool> canSync() async {
    final prefs = await SharedPreferences.getInstance();
    final nextSync = prefs.getInt(_key) ?? 0;
    return DateTime.now().millisecondsSinceEpoch >= nextSync;
  }

  Future<void> saveNextSync({int minutes = 0}) async {
    final prefs = await SharedPreferences.getInstance();
    final nextTimestamp = DateTime.now()
        .add(Duration(minutes: minutes))
        .millisecondsSinceEpoch;
    await prefs.setInt(_key, nextTimestamp);
  }
}
