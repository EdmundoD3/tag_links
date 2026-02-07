import 'package:in_app_purchase/in_app_purchase.dart';

bool isPremium = false;
// https://pub.dev/packages/in_app_purchase
void listenToPurchaseUpdated(List<PurchaseDetails> purchases) async {
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
Future<void> loadPremiumStatus() async {
  const Set<String> _kIds = <String>{'product1', 'product2'};
  final response = await InAppPurchase.instance.queryProductDetails(_kIds);

 if (response.notFoundIDs.isNotEmpty) {
  // Handle the error.
}
List<ProductDetails> products = response.productDetails;
}
