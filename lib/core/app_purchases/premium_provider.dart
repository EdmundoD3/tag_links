import 'dart:async';

import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tag_links/core/app_purchases/listen_to_purchase_update.dart';
import 'package:tag_links/core/app_purchases/suscription_cache.dart';

final premiumNotifierProvider = NotifierProvider<PremiumNotifier, bool>(
  PremiumNotifier.new,
);

class PremiumNotifier extends Notifier<bool> {
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  InAppPurchaseManager? _inAppPurchaseManager;

  @override
  bool build() {
    // Al cerrar el notifier, cancelamos la suscripción
    ref.onDispose(() => _subscription?.cancel());

    _init();
    return false; // Estado inicial
  }

  Future<void> _init() async {
    final inAppPurchaseManager = await _getInAppPurchaseManager();
    // 1. Verificación inmediata (Offline)
    state = await inAppPurchaseManager.getPremiumStatus();

    // 2. Conexión con la tienda (Online)
    final bool available = await InAppPurchase.instance.isAvailable();
    if (available) {
      _subscription = InAppPurchase.instance.purchaseStream.listen((
        purchases,
      ) async {
        await inAppPurchaseManager.listenToPurchaseUpdated(purchases);
        // Actualizamos el estado de Riverpod con lo que se guardó en SharedPreferences
        state = await inAppPurchaseManager.getPremiumStatus();
      }, onError: (error) => debugPrint("Error en tienda: $error"));
    }
  }

  /// Permite forzar una verificación (útil para el botón de 'Restaurar')
  Future<void> refreshStatus() async {
    final inAppPurchaseManager = await _getInAppPurchaseManager();
    state = await inAppPurchaseManager.getPremiumStatus();
  }

  /// Este método lo llamarás SOLO desde el botón "Restaurar" en tu UI.
  /// si se llama pide la contraseña
  Future<void> manualRestore() async {
    final inAppPurchaseManager = await _getInAppPurchaseManager();
    await InAppPurchaseManager.restorePurchases(); //static
    state = await inAppPurchaseManager.getPremiumStatus();
  }

  Future<InAppPurchaseManager> _getInAppPurchaseManager() async {
    if (_inAppPurchaseManager == null) {
      final pref = await SharedPreferences.getInstance();
      _inAppPurchaseManager = InAppPurchaseManager(
        PremiumManager(SubscriptionCache(pref)),
      );
    }
    return _inAppPurchaseManager!;
  }
}
