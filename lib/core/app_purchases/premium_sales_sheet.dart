import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:tag_links/core/app_purchases/products_provider.dart';

class PremiumSalesSheet extends ConsumerWidget {
  final Widget? showEmpty;
  const PremiumSalesSheet({
    super.key,
    required this.showEmpty
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);

    return productsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) =>
          showEmpty?? const SizedBox.shrink(),
      data: (products) {
        // LÓGICA: Si no hay productos disponibles en la tienda, ocultamos la sección
        if (products.isEmpty) {
          return showEmpty?? const SizedBox.shrink(); 
        }

        return ListView.builder(
          shrinkWrap: true,
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return _PremiumProductTile(product: product);
          },
        );
      },
    );
  }
}

class _PremiumProductTile extends ConsumerWidget {
  final ProductDetails product;
  const _PremiumProductTile({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(product.title),
        subtitle: Text(product.description),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${product.price} ${product.currencyCode}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            // const Text('Pago único/Mes', style: TextStyle(fontSize: 10)),
          ],
        ),
        onTap: () => _buyProduct(product, context),
      ),
    );
  }

  Future<void> _buyProduct(ProductDetails product, BuildContext context) async {
    final purchaseParam = PurchaseParam(productDetails: product);

    try {
      // Esto abre la interfaz de Google Play / App Store
      await InAppPurchase.instance.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      // Cerramos el modal de ventas inmediatamente.
      // Si la compra tiene éxito, el Stream del Notifier actualizará la app sola.
      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint('Error al intentar comprar: $e');
    }
  }
}
