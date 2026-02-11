import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

final productsProvider = FutureProvider<List<ProductDetails>>((ref) async {
  final available = await InAppPurchase.instance.isAvailable();
  if (!available) return [];

  const ids = <String>{
    'premium_monthly',
    'premium_yearly',
  };

  final response =
      await InAppPurchase.instance.queryProductDetails(ids);

  if (response.error != null) {
    debugPrint('Product query error: ${response.error}');
    return [];
  }

  return response.productDetails;
});
