import 'package:in_app_purchase/in_app_purchase.dart';

bool isPremium = false;

// https://pub.dev/packages/in_app_purchase
class InAppPurchaseManager {
  static void listenToPurchaseUpdated(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        if (purchase.productID == 'premium_monthly') {
          isPremium = true; // 🎉 PREMIUM ACTIVO
        }
      }

      if (purchase.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchase);
      }
    }
  }

  static Future<bool> getPremiumStatus() async {
    const Set<String> kIds = <String>{'product1', 'product2'};
    final response = await InAppPurchase.instance.queryProductDetails(kIds);

    if (response.notFoundIDs.isNotEmpty) {
      // Handle the error.
    }
    List<ProductDetails> products = response.productDetails;
    for (ProductDetails product in products) {
      if (product.id == 'premium_monthly') {
        return true;
      }
      if (product.id == 'premium_yearly') {
        return true;
      }
    }
    return false;
  }
}
