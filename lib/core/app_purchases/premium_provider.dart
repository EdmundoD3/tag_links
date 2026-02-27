import 'dart:async';

import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:tag_links/core/app_purchases/listen_to_purchase_update.dart';

final premiumNotifierProvider = NotifierProvider<PremiumNotifier, bool>(
  PremiumNotifier.new,
);

class PremiumNotifier extends Notifier<bool> {
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  @override
  bool build() {
    // Al cerrar el notifier, cancelamos la suscripción
    ref.onDispose(() => _subscription?.cancel());

    _init();
    return false; // Estado inicial
  }

  Future<void> _init() async {
    // 1. Verificación inmediata (Offline)
    state = await InAppPurchaseManager.getPremiumStatus();

    // 2. Conexión con la tienda (Online)
    final bool available = await InAppPurchase.instance.isAvailable();
    if (available) {
      _subscription = InAppPurchase.instance.purchaseStream.listen((
        purchases,
      ) async {
        await InAppPurchaseManager.listenToPurchaseUpdated(purchases);
        // Actualizamos el estado de Riverpod con lo que se guardó en SharedPreferences
        state = await InAppPurchaseManager.getPremiumStatus();
      }, onError: (error) => debugPrint("Error en tienda: $error"));
    }
  }

  /// Permite forzar una verificación (útil para el botón de 'Restaurar')
  Future<void> refreshStatus() async {
    state = await InAppPurchaseManager.getPremiumStatus();
  }

  // Este método lo llamarás SOLO desde el botón "Restaurar" en tu UI
  Future<void> manualRestore() async {
    await InAppPurchaseManager.restorePurchases();
    state = await InAppPurchaseManager.getPremiumStatus();
  }
  
}
