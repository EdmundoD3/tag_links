import 'package:flutter/cupertino.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:tag_links/api/api_models.dart';
import 'package:tag_links/api/api_services.dart';
import 'package:tag_links/core/app_purchases/suscription_cache.dart';
import 'package:url_launcher/url_launcher.dart';

class InAppPurchaseManager {
  final Set<String> kPremiumIds = {'premium_monthly', 'premium_yearly'};

  final PremiumManager premiumManager;

  InAppPurchaseManager(this.premiumManager);

  //--------- actualizar compras
  Future<void> listenToPurchaseUpdated(List<PurchaseDetails> purchases) async {
    if (purchases.isEmpty) return;

    await premiumManager.load();

    // 1. Ordenar las compras de la más NUEVA a la más VIEJA
    // Así nos aseguramos de procesar primero lo último que compró Vanessa
    purchases.sort((a, b) {
      int dateA = int.tryParse(a.transactionDate ?? '0') ?? 0;
      int dateB = int.tryParse(b.transactionDate ?? '0') ?? 0;
      return dateB.compareTo(dateA);
    });

    // 2. Tomamos solo la más reciente para actualizar el estado Premium
    final latestPurchase = purchases.first;

    for (final purchase in purchases) {
      // IMPORTANTE: Debemos completar TODAS las compras pendientes (pending)
      // para que Google no devuelva el dinero a Vanessa, sean viejas o nuevas.
      if (purchase.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchase);
      }
    }

    // 3. Procesamos el status Premium SOLO con la compra más reciente
    final currentCache = premiumManager.currentStatus;

    // Verificamos si la compra más reciente es distinta a lo que tenemos
    bool hasChanged =
        currentCache?.lastStatus != latestPurchase.status ||
        currentCache?.productId != latestPurchase.productID ||
        currentCache?.purchaseId != latestPurchase.purchaseID ||
        currentCache?.isServerCheck != true; //si no se a conectado al servidor lo intenta de nuevo en servidor

    if (_isPremiumPurchase(latestPurchase)) {
      if (hasChanged) {
        final expiration = await _verifyPurchaseOnServer(latestPurchase);

        if (expiration != null) {
          await premiumManager.updateExpiration(
            purchase: latestPurchase,
            expiration: expiration,
            isServerCheck: true,
          );
        } else {
          await _updatePremiumExpiration(latestPurchase);
        }
      } else {
        debugPrint("Vanessa ya tiene la compra más reciente registrada.");
      }
    }
  }

  // recuperar status de si es premium
  Future<bool> getPremiumStatus() async {
    await premiumManager.load();

    // Si es premium localmente, pero no hemos hablado con el servidor en 7 días...
    if (premiumManager.isPremium && premiumManager.needsServerCheck) {
      // Disparar verificación silenciosa en segundo plano
      _verifyStatusWithServerSilently();
    }

    return premiumManager.isPremium;
  }

  /// MAL: Llamar a restorePurchases() cada vez que abres la app. Esto obliga a Vanessa a poner su contraseña de Google a veces y genera tráfico innecesario.
  ///
  /// BIEN: Solo llamar a restorePurchases() cuando Vanessa presiona un botón físico que diga "Restaurar Compras" (por ejemplo, si instaló la app en un teléfono nuevo).
  static Future<void> restorePurchases() async {
    final available = await InAppPurchase.instance.isAvailable();
    if (available) {
      await InAppPurchase.instance.restorePurchases();
    }
  }
  // ---------------------- gestionar suscripciones ---------------------

  // Si Vanessa quiere cancelar o cambiar su plan:
  void goGestionSuscripciones() async {
    const String packageName = "com.tuapp.compras"; // Tu ID de app
    const String url =
        "https://play.google.com/store/account/subscriptions?package=$packageName";

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  // ------------------------ verify on server ---------------------
  Future<DateTime?> _verifyPurchaseOnServer(PurchaseDetails purchase) async {
    try {
      final token = purchase.verificationData.serverVerificationData;

      final ApiPurchaseResult? result = await ApiServices.verifyPurchase(
        token: token,
        productId: purchase.productID,
        purchaseId: purchase.purchaseID ?? '',
        platform: MethodPurchase.android,
      );

      if (result != null && result.ok && result.expiryDateMs != null) {
        return DateTime.fromMillisecondsSinceEpoch(result.expiryDateMs!);
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  // ------------------------ verify silently ---------------------
  Future<void> _verifyStatusWithServerSilently() async {
  final current = premiumManager.currentStatus;
  // Si no tenemos token o ya se verificó con el servidor, no hacemos nada
  if (current?.lastToken == null || current?.isServerCheck == true) return;

  try {
    // Usamos los datos guardados en el cache para intentar validar
    final ApiPurchaseResult? result = await ApiServices.verifyPurchase(
      token: current!.lastToken!,
      productId: current.productId!,
      purchaseId: current.purchaseId ?? '',
      platform: MethodPurchase.android,
    );

    if (result != null && result.ok && result.expiryDateMs != null) {
      final expiration = DateTime.fromMillisecondsSinceEpoch(result.expiryDateMs!);
      await premiumManager.updateExpirationSilently(expiration); 
      // ^ Este método debería poner isServerCheck: true y actualizar la fecha
    }
  } catch (e) {
    debugPrint("Reintento silencioso falló: $e");
  }
}
  Future<void> _updatePremiumExpiration(PurchaseDetails purchase) async {
    final expiration = _expirationDate(purchase);

    await premiumManager.updateExpiration(
      purchase: purchase,
      expiration: expiration,
      isServerCheck: false,
    );
  }

  bool _isPremiumPurchase(PurchaseDetails purchase) {
    final validStatus =
        purchase.status == PurchaseStatus.purchased ||
        purchase.status == PurchaseStatus.restored;

    return validStatus && includesPremium(purchase.productID);
  }

  // ------------------------ utils ---------------------
  bool includesPremium(String productId) {
    return kPremiumIds.contains(productId);
  }
}

DateTime _parseTransactionDate(PurchaseDetails purchase) {
  final int? ms = int.tryParse(purchase.transactionDate ?? '');

  return ms != null ? DateTime.fromMillisecondsSinceEpoch(ms) : DateTime.now();
}

Duration _durationPurchase(PurchaseDetails purchase) {
  final isYearly = purchase.productID.contains('yearly');

  // Si es compra nueva damos más margen, si es restauración damos el mes base
  return purchase.status == PurchaseStatus.purchased
      ? Duration(days: isYearly ? 370 : 35)
      : Duration(days: isYearly ? 30 : 7);
}

DateTime _expirationDate(PurchaseDetails purchase) {
  final DateTime referenceDate = _parseTransactionDate(purchase);
  final extension = _durationPurchase(purchase);
  return referenceDate.add(extension);
}
