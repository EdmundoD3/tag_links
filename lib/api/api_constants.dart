import 'package:tag_links/service/env.dart';

class ApiUrls {
  String get login => '$apiUrl/api/v1/login';
  String get sync => '$apiUrl/api/v1/sync';
  String get encryptionKey => '$apiUrl/api/v1/user/encryption-key';
  String get verifyPurchase => '$apiUrl/api/v1/verify-purchase';

  String get apiUrl => Env.apiBaseUrl;
  bool get isAvailable => apiUrl.isNotEmpty && apiUrl.contains("http");
}