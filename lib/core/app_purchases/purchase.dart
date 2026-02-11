import 'package:in_app_purchase/in_app_purchase.dart';

void purchase() async {
  final response = await InAppPurchase.instance.queryProductDetails(
  {'premium_monthly'},
);

final product = response.productDetails.first;

final purchaseParam = PurchaseParam(productDetails: product);

InAppPurchase.instance.buyNonConsumable(purchaseParam: purchaseParam);

}