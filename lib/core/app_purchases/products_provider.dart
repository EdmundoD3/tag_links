import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

// Usamos .autoDispose para limpiar si ya no se usa, 
// pero verás que la lógica interna será más robusta.
final productsProvider = FutureProvider.autoDispose<List<ProductDetails>>((ref) async {
  // 1. Límite de tiempo global para la operación
  return await _fetchProducts().timeout(
    const Duration(seconds: 8), // Si en 8 segundos no responde, dispara el TimeoutException
    onTimeout: () {
      debugPrint('InAppPurchase: Tiempo de espera agotado');
      return []; // Devolvemos lista vacía para que la UI deje de cargar
    },
  );
});

Future<List<ProductDetails>> _fetchProducts() async {
  try {
    final bool available = await InAppPurchase.instance.isAvailable();
    if (!available) return [];

    const Set<String> ids = {'premium_monthly', 'premium_yearly'};

    // 2. La consulta a la tienda suele ser lo que se queda pegado
    final ProductDetailsResponse response = 
        await InAppPurchase.instance.queryProductDetails(ids);

    if (response.error != null || response.productDetails.isEmpty) {
      return [];
    }

    final products = response.productDetails;
    products.sort((a, b) => a.rawPrice.compareTo(b.rawPrice));
    
    return products;
  } catch (e) {
    debugPrint('Error en productsProvider: $e');
    return []; // En lugar de lanzar error, devolvemos vacío para no bloquear la UI
  }
}