import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:tag_links/core/app_purchases/premium_provider.dart';
import 'package:tag_links/core/app_purchases/products_provider.dart';

class PremiumSalesSheet extends ConsumerWidget {
  final Widget? showEmpty;
  const PremiumSalesSheet({super.key, this.showEmpty});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. ESCUCHAMOS el estado premium. Si pasa a TRUE mientras el modal está abierto,
    // significa que la compra tuvo éxito. Cerramos el modal automáticamente.
    ref.listen<bool>(premiumStatusProvider, (previous, next) {
      if (next == true && context.mounted) {
        Navigator.pop(context); // Cerramos el modal con éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Gracias por tu compra! Ya eres Premium.'),
          ),
        );
      }
    });

    final productsAsync = ref.watch(productsProvider);

    return productsAsync.when(
      loading: () => const SizedBox(
        height: 250,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => showEmpty ?? const SizedBox.shrink(),
      data: (products) {
        if (products.isEmpty) return showEmpty ?? const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.stars, size: 50, color: Colors.amber),
              const SizedBox(height: 12),
              const Text(
                'Tag Links Premium',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Sincronización ilimitada y sin anuncios.',
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              ...products.map(
                (product) => _PremiumProductTile(product: product),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Quizás más tarde'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PremiumProductTile extends StatelessWidget {
  // Ya no necesita ser ConsumerWidget
  final ProductDetails product;
  const _PremiumProductTile({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(
          product.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(product.description),
        trailing: Text(
          product
              .price, // Ya incluye el símbolo de moneda local (e.g., "$9.99")
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        onTap: () => _buyProduct(product, context),
      ),
    );
  }

  Future<void> _buyProduct(ProductDetails product, BuildContext context) async {
    final purchaseParam = PurchaseParam(productDetails: product);
    try {
      // Nota: Para suscripciones también se usa buyNonConsumable en este plugin
      await InAppPurchase.instance.buyNonConsumable(
        purchaseParam: purchaseParam,
      );
      // NO hacemos Navigator.pop aquí.
      // Dejamos que el ref.listen en el SalesSheet lo haga cuando la compra se confirme.
    } catch (e) {
      debugPrint('Error en compra: $e');
    }
  }
}
