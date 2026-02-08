import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

bool isPremium = false;

// https://pub.dev/packages/in_app_purchase
class InAppPurchaseManager {
  static final Set<String> kPremiumIds = <String>{
    'premium_monthly',
    'premium_yearly',
  };

  static void listenToPurchaseUpdated(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        if (includesPremium(purchase.productID)) {
          isPremium = true; // 🎉 PREMIUM ACTIVO
        }
      }

      if (purchase.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchase);
      }
    }
  }

  static Future<bool> getPremiumStatus() async {
    final bool available = await InAppPurchase.instance.isAvailable();
    if (!available) {
      // La tienda no está disponible (ej. emulador sin Play Store), asumimos no premium.
      return false;
    }
    
    // CORRECCIÓN: queryProductDetails solo sirve para ver precios/títulos, NO para ver si se compró.
    // El estado de compra real llega a través del stream (listenToPurchaseUpdated).
    // Aquí retornamos el valor actual que haya procesado el stream.
    return isPremium;
  }

  static bool includesPremium(String productId) {
    return kPremiumIds.contains(productId);
  }
}
