import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:tag_links/core/app_purchases/interfaces/purchase_items.dart';
import 'package:tag_links/core/app_purchases/premium_provider.dart';
import 'package:tag_links/core/app_purchases/products_provider.dart';
import 'package:tag_links/core/locate/t_keys.dart';

class PremiumPurchaseButton extends ConsumerWidget {
  const PremiumPurchaseButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
    final theme = Theme.of(context);
    return productsAsync.when(
      loading: () => const SizedBox(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => const SizedBox.shrink(),
      data: (products) {
        final premium = products
            .where((p) => p.id == PurchaseItems.premiumYearly.id)
            .toList();
            
        if(premium.isEmpty) return const SizedBox.shrink();

return SizedBox(
  width: double.infinity,
  child: ElevatedButton.icon(
    onPressed: () async => _buyProduct(
      premium.first,
      context,
    ),
    icon: Icon(
      Icons.workspace_premium,
      color: theme.textTheme.labelMedium?.color,
    ),
    label: Text(
      '${ref.tr(
        TKeys.premium.buyYear,
        fallback: 'Premium por 1 año',
      )} · ${premium.first.price}',
    ),
    style: ElevatedButton.styleFrom(
      elevation: 1,
      backgroundColor: theme.cardColor,
      foregroundColor: theme.textTheme.labelMedium?.color,
      side: BorderSide(
        color: theme.focusColor.withAlpha(120),
        width: 1,
      ),
    ),
  ),
);
      },
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
