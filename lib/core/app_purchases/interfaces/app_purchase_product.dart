// app_purchases/app_purchase_product.dart import 'package:tag_links/core/app_purchases/interfaces/purchase.dart';
import 'package:tag_links/core/app_purchases/interfaces/purchase_items.dart';

class AppPurchaseProduct<T> {
  final String id;
  final String title;
  final String description;
  final String price;
  final PurchaseStatus? status;
  final T rawProduct;
  const AppPurchaseProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.rawProduct,
    this.status,
  });
}
