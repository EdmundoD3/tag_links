import 'package:tag_links/service/env.dart';

class ApiUrls {
  final login = '${Env.apiBaseUrl}/api/v1/login';
  final sync = '${Env.apiBaseUrl}/api/v1/sync';
  final encryptionKey = '${Env.apiBaseUrl}/api/v1/user/encryption-key';
  final verifyPurchase = '${Env.apiBaseUrl}/api/v1/verify-purchase';
}