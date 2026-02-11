import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool isPremium = false;

// https://pub.dev/packages/in_app_purchase
class InAppPurchaseManager {
  static final Set<String> kPremiumIds = <String>{
    'premium_monthly',
    'premium_yearly',
  };

  static void listenToPurchaseUpdated(
    List<PurchaseDetails> purchases,
  ) async {
    for (final purchase in purchases) {
      if ((purchase.status == PurchaseStatus.purchased ||
              purchase.status == PurchaseStatus.restored) &&
          includesPremium(purchase.productID)) {
        
        // ESTRATEGIA HEARTBEAT: Actualizamos la fecha de validez
        await _updatePremiumExpiration(purchase);
        isPremium = true;
      }

      if (purchase.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchase);
      }
    }
  }

  static Future<void> _updatePremiumExpiration(PurchaseDetails purchase) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final isYearly = purchase.productID.contains('yearly');

    // Si es compra nueva: ciclo completo. Si es restore: 7 días buffer.
    final Duration extension = (purchase.status == PurchaseStatus.purchased)
        ? Duration(days: isYearly ? 370 : 35)
        : const Duration(days: 7);

    final newExpirationDate = now.add(extension);

    // Mantener la fecha más lejana para no restar días si ya tenía
    final currentExpiryMs = prefs.getInt('premium_expiration_date') ?? 0;
    final currentExpiry = DateTime.fromMillisecondsSinceEpoch(currentExpiryMs);

    final finalDate = newExpirationDate.isAfter(currentExpiry)
        ? newExpirationDate
        : currentExpiry;

    await prefs.setBool('is_premium_purchased', true);
    await prefs.setInt('premium_expiration_date', finalDate.millisecondsSinceEpoch);
  }

  static Future<bool> getPremiumStatus() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 1. Verificar expiración (Funciona Offline)
    final int? expiryMs = prefs.getInt('premium_expiration_date');
    if (expiryMs != null) {
      final expiry = DateTime.fromMillisecondsSinceEpoch(expiryMs);
      if (DateTime.now().isAfter(expiry)) {
        isPremium = false; // Expiró
      } else {
        isPremium = true; // Válido
      }
    } else {
      // Fallback para instalaciones antiguas
      isPremium = prefs.getBool('is_premium_purchased') ?? false;
    }

    return isPremium;
  }

  static bool includesPremium(String productId) {
    return kPremiumIds.contains(productId);
  }

  static Future<void> restorePurchases() async {
    final available = await InAppPurchase.instance.isAvailable();
    if (available) {
      await InAppPurchase.instance.restorePurchases();
    }
  }
}