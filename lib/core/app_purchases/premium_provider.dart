import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:tag_links/core/app_purchases/in_app_purchase_manager.dart';
import 'package:tag_links/core/app_purchases/premium_local_data_source_provider.dart';
import 'package:tag_links/sync/drive_sync_config_manager.dart';

/// Provider que expone simplemente si el usuario es Premium o no.
final premiumStatusProvider = NotifierProvider<PremiumNotifier, bool>(
  PremiumNotifier.new,
);

class PremiumNotifier extends Notifier<bool> {
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  final _purchaseManager = InAppPurchaseManager();

  @override
  bool build() {
    final localDataSource = ref.watch(premiumLocalDataSourceProvider);
    final configManager = ref.watch(syncConfigProvider);

    // 1. Carga inicial desde SharedPreferences (rápida)
    final bool localState = localDataSource.getIsPremium();

    // 2. Iniciamos validación de In-App Purchases (Fondo)
    _initInAppPurchases(localDataSource, configManager);

    // 3. NUEVO: Validación de Drive al iniciar (Inbound)
    // Si configManager no es nulo, significa que ya tenemos la sesión de Drive
    if (configManager != null) {
      _checkDrivePremiumStatus(localDataSource, configManager);
    }

    ref.onDispose(() => _subscription?.cancel());

    return localState;
  }

  /// NUEVO: Comprueba si Drive tiene un estado premium superior al local
  Future<void> _checkDrivePremiumStatus(
    PremiumLocalDataSource localData,
    DriveSyncConfigManager configManager,
  ) async {
    try {
      // Obtenemos la config remota (esto ya lo tienes implementado)
      final remoteData = await configManager.getOrInitializeRemoteConfig();
      if (remoteData == null) return;

      final remoteConfig = remoteData.config;
      final now = DateTime.now().millisecondsSinceEpoch;

      // Verificamos si en Drive el premium está activo
      final bool isDrivePremium = remoteConfig.premiumUntil > now;

      // Si Drive dice que es premium pero localmente no lo sabemos,
      // actualizamos el estado local.
      if (isDrivePremium && state == false) {
        state = true;
        await localData.setIsPremium(true);
        debugPrint("☁️ -> 📱 Estado Premium recuperado desde Drive.");
      } 
      // Caso contrario: Si local es premium pero Drive dice que ya expiró,
      // aquí podrías decidir si ser estricto o esperar a que Google Play hable.
    } catch (e) {
      debugPrint("❌ Error verificando Premium en Drive: $e");
    }
  }

  void _initInAppPurchases(
    PremiumLocalDataSource localData,
    DriveSyncConfigManager? configManager,
  ) async {
    final bool available = await InAppPurchase.instance.isAvailable().timeout(
      const Duration(seconds: 5),
      onTimeout: () => false,
    );

    if (!available) return;
    // IMPORTANTE: Cancelar si ya existía una suscripción previa
    // para evitar fugas de memoria o procesos duplicados.
    await _subscription?.cancel();
    
    _subscription = InAppPurchase.instance.purchaseStream.listen((
      purchases,
    ) async {
      final premiumInfo = await _purchaseManager.processPurchaseUpdates(
        purchases,
      );

      if (premiumInfo != null) {
        final bool isNowPremium = premiumInfo.hasActivePremium;

        // Si el estado cambió respecto al local, actualizamos todo
        if (state != isNowPremium) {
          state = isNowPremium;
          await localData.setIsPremium(isNowPremium);
        }

        // Sincronización con la nube (solo si hay sesión)
        if (configManager != null) {
          _syncPremiumToDrive(configManager, premiumInfo);
        }
      }
    });
  }

  /// Función interna para subir la info a Drive sin bloquear la UI
  Future<void> _syncPremiumToDrive(
    DriveSyncConfigManager configManager,
    PremiumInfo info,
  ) async {
    try {
      final remoteData = await configManager.getOrInitializeRemoteConfig();

      if (remoteData != null) {
        final current = remoteData.config;

        // --- VALIDACIÓN DE CAMBIOS MEJORADA ---
        bool isNewPurchase = current.purchaseToken != info.purchaseToken;

        // También subimos si el estado Premium local es diferente al de Drive
        // Esto cubre el caso donde local es 'false' y Drive aún decía 'true'
        bool statusChanged = current.isPremium != info.isPremium;

        // Solo actualizamos la fecha si es mayor (renovación)
        // O si el estatus ha cambiado (expiración/cancelación)
        bool isDateUpdated = info.expirationDate > current.premiumUntil;

        if (!isNewPurchase && !isDateUpdated && !statusChanged) {
          debugPrint("ℹ️ Drive ya está al día. Omitiendo subida.");
          return;
        }
        // --------------------------------------

        final newConfig = current.copyWith(
          premiumUntil: info.expirationDate,
          purchaseToken: info.purchaseToken,
          productId: info.productId,
          lastGlobalUpdate: DateTime.now().millisecondsSinceEpoch,
        );

        await configManager.updateRemoteConfig(remoteData.fileId, newConfig);
        debugPrint(
          "☁️ Estatus Premium actualizado en Drive: ${info.isPremium ? 'Activo' : 'Inactivo'}",
        );
      }
    } catch (e) {
      debugPrint("❌ Error en la sincronización de Drive: $e");
    }
  }
}
