import 'dart:async';

import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tag_links/core/app_purchases/in_app_purchase_manager.dart';
import 'package:tag_links/core/app_purchases/suscription_cache.dart';

final premiumNotifierProvider = NotifierProvider<PremiumNotifier, bool>(
  PremiumNotifier.new,
);

class PremiumNotifier extends Notifier<bool> {
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  InAppPurchaseManager? _inAppPurchaseManager;

  @override
  bool build() {
    ref.onDispose(() => _subscription?.cancel()); // <--- ¡Importante!
    Future.microtask(() => _init());
    return false;
  }

  Future<void> _init() async {
    try {
      final inAppPurchaseManager = await _getInAppPurchaseManager();

      // CARGA OFFLINE (Rápida, no bloquea)
      final isPremium = await inAppPurchaseManager.getPremiumStatus();
      state = isPremium;

      // CARGA ONLINE (Peligrosa en emulador)
      // Ponemos un timeout o verificamos disponibilidad con cuidado
      final bool available = await InAppPurchase.instance.isAvailable().timeout(
        const Duration(seconds: 5),
        onTimeout: () => false,
      );

      if (available) {
        final inAppPurchaseManager = await _getInAppPurchaseManager();
        _subscription = InAppPurchase.instance.purchaseStream.listen((
          purchases,
        ) async {
          await inAppPurchaseManager.listenToPurchaseUpdated(purchases);
          state = await inAppPurchaseManager.getPremiumStatus();
        }, onError: (error) => debugPrint("Error en tienda: $error"));
      }
    } catch (e) {
      debugPrint("Error inicializando Premium: $e");
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
