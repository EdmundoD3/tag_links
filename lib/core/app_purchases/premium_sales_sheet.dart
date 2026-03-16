import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:tag_links/core/app_purchases/products_provider.dart';

class PremiumSalesSheet extends ConsumerWidget {
  final Widget? showEmpty;
  const PremiumSalesSheet({super.key, required this.showEmpty});

@override
Widget build(BuildContext context, WidgetRef ref) {
  final productsAsync = ref.watch(productsProvider);

  return productsAsync.when(
    loading: () => const SizedBox(
      height: 200, 
      child: Center(child: CircularProgressIndicator())
    ),
    error: (err, stack) {
      // Si hay un error real, mostramos el contenido vacío opcional
      return showEmpty ?? const SizedBox.shrink();
    },
    data: (products) {
      if (products.isEmpty) {
        return showEmpty ?? const SizedBox.shrink();
      }

      // IMPORTANTE: Si usas ListView dentro de un BottomSheet, 
      // asegúrate de que no crezca infinitamente.
      return Column(
        mainAxisSize: MainAxisSize.min, // Ajusta el modal al contenido
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('Hazte Premium', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return _PremiumProductTile(product: product);
            },
          ),
          const SizedBox(height: 20),
        ],
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
