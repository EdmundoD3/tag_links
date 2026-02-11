import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:tag_links/core/app_purchases/products_provider.dart';

class PremiumPaywall extends ConsumerWidget {
  const PremiumPaywall({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);

    return productsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text('Error cargando productos'),
      ),
      data: (products) {
        if (products.isEmpty) {
          return const Center(
            child: Text('No hay productos disponibles'),
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Hazte Premium',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            for (final product in products)
              _PremiumProductTile(product: product),
          ],
        );
      },
    );
  }
}
class _PremiumProductTile extends StatelessWidget {
  final ProductDetails product;

  const _PremiumProductTile({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(product.title),
        subtitle: Text(product.price),
        trailing: ElevatedButton(
          onPressed: () {
            final purchaseParam = PurchaseParam(
              productDetails: product,
            );

            InAppPurchase.instance.buyNonConsumable(
              purchaseParam: purchaseParam,
            );
          },
          child: const Text('Comprar'),
        ),
      ),
    );
  }
}
