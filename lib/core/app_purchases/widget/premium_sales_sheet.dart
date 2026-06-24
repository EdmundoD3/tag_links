import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:tag_links/core/app_purchases/premium_provider.dart';
import 'package:tag_links/core/app_purchases/products_provider.dart';
import 'package:tag_links/core/locate/t_keys.dart';

class PremiumSalesSheet extends ConsumerWidget {
  final Widget? showEmpty;
  const PremiumSalesSheet({super.key, this.showEmpty});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. ESCUCHAMOS el estado premium. Si pasa a TRUE mientras el modal está abierto,
    // significa que la compra tuvo éxito. Cerramos el modal automáticamente.
    ref.listen<bool>(premiumStatusProvider, (previous, next) {
      if (next == true && context.mounted) {
        final thanksText = ref.tr(
          TKeys.premium.thanks,
          fallback: '¡Gracias por tu compra! Ya eres Premium.',
        );
        Navigator.pop(context); // Cerramos el modal con éxito
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(thanksText)));
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
              ...products.map(
                (product) => _PremiumProductTile(product: product),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PremiumProductTile extends ConsumerWidget {
  // Ya no necesita ser ConsumerWidget
  final ProductDetails product;
  const _PremiumProductTile({required this.product});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _buyProduct(product, context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.workspace_premium),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      product.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Text(product.description),

              const SizedBox(height: 16),

              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  product.price,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
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
