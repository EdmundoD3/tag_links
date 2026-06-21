// app_purchases/purchase_cache.dart import 'package:tag_links/core/app_purchases/interfaces/purchase.dart';
import 'package:tag_links/core/app_purchases/interfaces/purchase_items.dart';

const delayCheckPurchase = Duration(days: 7);

class PurchaseCache {
  final Map<PurchaseItems, PurchaseStatus> purchases;
  const PurchaseCache({required this.purchases});
  Map<String, dynamic> toJson() {
    return {
      for (final entry in purchases.entries) entry.key.id: entry.value.toJson(),
    };
  }

  factory PurchaseCache.fromJson(Map<String, dynamic> json) {
    final purchases = <PurchaseItems, PurchaseStatus>{};
    for (final item in PurchaseItems.values) {
      final data = json[item.id];
      if (data is Map) {
        purchases[item] = PurchaseStatus.fromJson(
          Map<String, dynamic>.from(data),
        );
      }
    }
    return PurchaseCache(purchases: purchases);
  }
  PurchaseStatus getStatus(PurchaseItems item) {
    return purchases[item] ?? PurchaseStatus.notOwned;
  }

  bool hasPurchase(PurchaseItems item) {
    return getStatus(item).isActive;
  }

  bool get isPremium =>
      purchases[PurchaseItems.premiumYearly]?.isActive ?? false;
}
