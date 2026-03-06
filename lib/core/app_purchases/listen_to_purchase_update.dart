import 'package:flutter/rendering.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tag_links/api/api_services.dart';

bool isPremium = false;

// https://pub.dev/packages/in_app_purchase
class InAppPurchaseManager {
  static final Set<String> kPremiumIds = <String>{
    'premium_monthly',
    'premium_yearly',
  };

static Future<void> listenToPurchaseUpdated(
  List<PurchaseDetails> purchases,
) async {
  for (final purchase in purchases) {
    if ((purchase.status == PurchaseStatus.purchased ||
         purchase.status == PurchaseStatus.restored) &&
        includesPremium(purchase.productID)) {
      
      // 🚀 PASO NUEVO: Enviar al servidor
      // Es recomendable hacerlo antes de marcarlo como premium localmente
      bool serverVerified = await _verifyPurchaseOnServer(purchase);

      if (serverVerified) {
        await _updatePremiumExpiration(purchase);
        isPremium = true;
      }
    }

    if (purchase.pendingCompletePurchase) {
      // IMPORTANTE: Solo completamos la compra si el servidor ya la registró
      // o si decides que la app sea funcional aunque el servidor falle (tú eliges)
      await InAppPurchase.instance.completePurchase(purchase);
    }
  }
}

static Future<bool> _verifyPurchaseOnServer(PurchaseDetails purchase) async {
  try {
    // El token que necesita tu servidor
    final String token = purchase.verificationData.serverVerificationData;
    final String productId = purchase.productID;
    final String purchaseId = purchase.purchaseID ?? '';

    debugPrint('Enviando token al servidor: $token');
    // final s = ApiServices.verifyPurchase();
    // Aquí haces tu petición HTTP
    /*
    
    return response.statusCode == 200;
    */
    
    return true; // Temporalmente true para no bloquearte
  } catch (e) {
    debugPrint('Error informando al servidor: $e');
    // Si falla el servidor, podrías devolver 'true' para no arruinarle 
    // la experiencia al usuario, o 'false' si tu app depende 100% del backend.
    return true; 
  }
}

  static Future<void> _updatePremiumExpiration(PurchaseDetails purchase) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final isYearly = purchase.productID.contains('yearly');

    // Si es compra nueva: ciclo completo. Si es restore: 7 días buffer.
    // Sugerencia para la duración en _updatePremiumExpiration
final Duration extension = (purchase.status == PurchaseStatus.purchased)
    ? Duration(days: isYearly ? 370 : 35)
    : Duration(days: isYearly ? 30 : 7); // Un buffer más realista para restores

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