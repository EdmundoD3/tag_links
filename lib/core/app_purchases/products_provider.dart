import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

// Usamos .autoDispose para limpiar si ya no se usa,
// pero verás que la lógica interna será más robusta.
// En el archivo de productos_provider.dart

final productsProvider = FutureProvider.autoDispose<List<ProductDetails>>((ref) async {
  // 1. Usamos los IDs definidos en tu manager (opcional pero recomendado)
  final Set<String> premiumIds = {'premium_monthly', 'premium_yearly'};

  try {
    return await InAppPurchase.instance
        .queryProductDetails(premiumIds)
        .timeout(const Duration(seconds: 8))
        .then((response) {
          if (response.error != null || response.productDetails.isEmpty) {
            return <ProductDetails>[];
          }
          final products = response.productDetails;
          // Ordenamos por precio para que el mensual salga primero
          products.sort((a, b) => a.rawPrice.compareTo(b.rawPrice));
          return products;
        });
  } catch (e) {
    debugPrint('InAppPurchase: Error al obtener productos: $e');
    return [];
  }
});