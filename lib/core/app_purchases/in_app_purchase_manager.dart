import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:tag_links/config/purchases_config.dart';

class MobileInAppPurchaseManager {
  /// Procesa las compras y devuelve la info de suscripción si existe una válida
  Future<PremiumInfo?> processPurchaseUpdates(
    List<PurchaseDetails> purchases,
  ) async {
    // 1. Completar siempre las pendientes (fuera de cualquier if)
    for (var p in purchases) {
      if (p.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(p);
      }
    }

    if (purchases.isEmpty) return null;

    // 2. Filtrar compras de productos premium con estado exitoso
    final validPurchases = purchases
        .where(
          (p) =>
              (p.status == PurchaseStatus.purchased ||
                  p.status == PurchaseStatus.restored) &&
              kPremiumIds.contains(p.productID),
        )
        .toList();

    if (validPurchases.isNotEmpty) {
      final latest = _getLatest(validPurchases);
      final expiration = _calculateExpiration(latest);
      final now = DateTime.now().millisecondsSinceEpoch;

      // SI LA COMPRA EXISTE PERO YA EXPIRÓ (Cancelada o fin de periodo)
      if (expiration.millisecondsSinceEpoch < now) {
        return PremiumInfo(
          isPremium: false, // <--- Marcamos como falso
          productId: latest.productID,
          purchaseToken: latest.verificationData.serverVerificationData,
          expirationDate: expiration.millisecondsSinceEpoch,
        );
      }

      return PremiumInfo(
        isPremium: true,
        productId: latest.productID,
        purchaseToken: latest.verificationData.serverVerificationData,
        expirationDate: expiration.millisecondsSinceEpoch,
      );
    }

    // Si llegó aquí y no hay compras válidas en absoluto
    return PremiumInfo(isPremium: false, expirationDate: 0);
  }

  PurchaseDetails _getLatest(List<PurchaseDetails> p) {
    p.sort(
      (a, b) => (int.tryParse(b.transactionDate ?? '0') ?? 0).compareTo(
        int.tryParse(a.transactionDate ?? '0') ?? 0,
      ),
    );
    return p.first;
  }

  DateTime _calculateExpiration(PurchaseDetails p) {
    final date = DateTime.fromMillisecondsSinceEpoch(
      int.tryParse(p.transactionDate ?? '') ??
          DateTime.now().millisecondsSinceEpoch,
    );
    return date.add(Duration(days: p.productID.contains('yearly') ? 366 : 31));
  }
}

class PremiumInfo {
  final bool isPremium;
  final String? productId;
  final String? purchaseToken;
  final int expirationDate;

  PremiumInfo({
    required this.isPremium,
    this.productId,
    this.purchaseToken,
    required this.expirationDate,
  });

  bool get hasActivePremium =>
      isPremium && expirationDate > DateTime.now().millisecondsSinceEpoch;
}
