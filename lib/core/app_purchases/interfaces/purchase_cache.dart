// app_purchases/purchase_cache.dart import 'package:tag_links/core/app_purchases/interfaces/purchase.dart';
import 'package:tag_links/core/app_purchases/interfaces/purchase_items.dart';

const delayCheckPurchase = Duration(days: 7);

class PurchaseCache {
  final PurchaseStatus premium;
  const PurchaseCache({required this.premium});
  Map<String, dynamic> toJson() {
    return {'premium': premium.toJson()};
  }

  factory PurchaseCache.fromPurchases(
    Map<PurchaseItems, PurchaseStatus> purchases,
  ) {
    final premium =
        purchases[PurchaseItems.premiumYearly] ??
        PurchaseStatus.notOwned;

    return PurchaseCache(
      premium: premium,
    );
  }

  factory PurchaseCache.fromJson(Map<String, dynamic> json) {
    return PurchaseCache(premium: PurchaseStatus.fromJson(json['premium']));
  }

  bool get isPremium => premium.isActive;
}
