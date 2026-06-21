enum PurchaseItems {
  premiumYearly('premium_yearly');

  final String id;
  const PurchaseItems(this.id);

  bool get grantsPremium {
    switch (this) {
      case PurchaseItems.premiumYearly:
        return true;
    }
  }
}

class PurchaseStatus {
  final PurchaseOwnershipStatus status;
  final int? expirationDate;
  final int? lastVerifiedAt;

  const PurchaseStatus({
    required this.status,
    this.expirationDate,
    this.lastVerifiedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'status': status.code,
      'expirationDate': expirationDate,
      'lastVerifiedAt': lastVerifiedAt,
    };
  }

  factory PurchaseStatus.fromJson(Map<String, dynamic> json) {
    return PurchaseStatus(
      status: PurchaseOwnershipStatus.fromCode(json['status']),
      expirationDate: json['expirationDate'] as int?,
      lastVerifiedAt: json['lastVerifiedAt'] as int?,
    );
  }

  bool needsVerification(Duration delay) {
    final last = lastVerifiedAt;

    if (last == null) return true;

    return DateTime.now().millisecondsSinceEpoch - last >
        delay.inMilliseconds;
  }

  static const notOwned = PurchaseStatus(
    status: PurchaseOwnershipStatus.notOwned,
  );

  bool get isActive {
    if (status != PurchaseOwnershipStatus.active) {
      return false;
    }

    if (expirationDate == null) {
      return true;
    }

    return expirationDate! >
        DateTime.now().millisecondsSinceEpoch;
  }

  bool get isExpired =>
      expirationDate != null &&
      expirationDate! <
          DateTime.now().millisecondsSinceEpoch;
}

enum PurchaseOwnershipStatus {
  notOwned('notOwned'),
  active('active'),
  expired('expired'),
  pending('pending');

  final String code;

  const PurchaseOwnershipStatus(this.code);

  static PurchaseOwnershipStatus fromCode(String? code) {
    for (final item in values) {
      if (item.code == code) return item;
    }
    return PurchaseOwnershipStatus.notOwned;
  }
}