class ApiSaveResult {
  final bool ok;
  final String? error;
  final String? message;

  ApiSaveResult({required this.ok, this.error, this.message});

  factory ApiSaveResult.fromJson(Map<String, dynamic> json) {
    return ApiSaveResult(
      ok: json['ok'] as bool,
      error: json['error'] as String?,
      message: json['message'] as String?,
    );
  }
}

class ApiPurchaseResult {}


enum MethodPurchase { android, ios, windows}
