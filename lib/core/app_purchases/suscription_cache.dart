import 'dart:convert';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tag_links/core/app_purchases/purchases_config.dart';

class PremiumManager {
  final SubscriptionCache cache;

  SubscriptionStatus? _status;

  PremiumManager(this.cache);

  bool get isPremium => _status?.isPremium ?? false;
  
  /// revisa si ya pasaron 7 dias desde el ultimo check
  bool get needsServerCheck =>
      _status?.lastCheck.isBefore(
        DateTime.now().subtract(delayCheckPurchase),
      ) ??
      true;
  SubscriptionStatus? get currentStatus => _status;

  Future<void> load() async {
    _status = cache.load();
  }

  Future<void> updateExpiration({PurchaseDetails? purchase ,required DateTime expiration, bool isServerCheck = false}) async {
    _status = SubscriptionStatus(
      expirationDate: expiration,
      lastCheck: DateTime.now(),
      isServerCheck: isServerCheck,
      lastStatus: purchase?.status,
      lastToken: purchase?.verificationData.serverVerificationData,
      productId: purchase?.productID,
      purchaseId: purchase?.purchaseID,
    );

    await cache.save(_status!);
  }
  /// isServerCheck: true y actualizar la fecha de expiracion, y lasCheck
  Future<void> updateExpirationSilently(DateTime expiration) async {
    _status = _status?.copyWith(
      expirationDate: expiration,
      isServerCheck: true,
      lastCheck: DateTime.now(),
    );
  }
}

class SubscriptionCache {
  final SharedPreferences prefs;
  SubscriptionCache(this.prefs);
  static const key = "subscription_status";

  Future<void> save(SubscriptionStatus status) async {
    final map = {
      "isServerCheck": status.isServerCheck,
      "expiration": status.expirationDate?.millisecondsSinceEpoch,
      "lastCheck": status.lastCheck.millisecondsSinceEpoch,
      "lastStatus": status.lastStatus?.index, // Guardamos el índice del enum
      "lastToken": status.lastToken,
      "productId": status.productId,
      "purchaseId": status.purchaseId,
    };
    await prefs.setString(key, jsonEncode(map));
  }

  SubscriptionStatus? load() {
    final data = prefs.getString(key);
    if (data == null) return null;
    final map = jsonDecode(data);

    return SubscriptionStatus(
      isServerCheck: map["isServerCheck"] ?? false,
      expirationDate: map["expiration"] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map["expiration"]) 
          : null,
      lastCheck: DateTime.fromMillisecondsSinceEpoch(map["lastCheck"]),
      lastStatus: map["lastStatus"] != null 
          ? PurchaseStatus.values[map["lastStatus"]] 
          : null,
      lastToken: map["lastToken"],
      productId: map["productId"],
      purchaseId: map["purchaseId"],

    );
  }
}
class SubscriptionStatus {
  final DateTime? expirationDate;
  final DateTime lastCheck;
  final bool isServerCheck;
  final PurchaseStatus? lastStatus; // El status de Google
  final String? lastToken;          // El token para reintentos
  final String? productId;          // El ID del producto
  final String? purchaseId;         // El ID de la compra

  SubscriptionStatus({
    required this.expirationDate,
    required this.lastCheck,
    required this.isServerCheck,
    this.lastStatus,
    this.lastToken,
    this.productId,
    this.purchaseId,
  });
  SubscriptionStatus copyWith({
    DateTime? expirationDate,
    DateTime? lastCheck,
    bool? isServerCheck,
    PurchaseStatus? lastStatus,
    String? lastToken,
    String? productId,
    String? purchaseId,
  }) {
    return SubscriptionStatus(
      expirationDate: expirationDate ?? this.expirationDate,
      lastCheck: lastCheck ?? this.lastCheck,
      isServerCheck: isServerCheck ?? this.isServerCheck,
      lastStatus: lastStatus ?? this.lastStatus,
      lastToken: lastToken ?? this.lastToken,
      productId: productId ?? this.productId,
      purchaseId: purchaseId ?? this.purchaseId,
    );
  }

  bool get isPremium {
    if (expirationDate == null) return false;
    // Es premium si la fecha no ha pasado
    return DateTime.now().isBefore(expirationDate!);
  }
}