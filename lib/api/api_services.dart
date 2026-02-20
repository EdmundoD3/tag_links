import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tag_links/api/login_response.dart';
import 'package:tag_links/service/env.dart';

class _ApiUrls {
  final login = '${Env.apiBaseUrl}/api/v1/login';
  final sync = '${Env.apiBaseUrl}/api/v1/sync';
}

class SyncResponseModel {
  final bool ok;
  final String? reason;
  final bool isPremium;
  final Map<String, dynamic> sync;
  final int serverTime;

  SyncResponseModel.fromJson(Map<String, dynamic> json)
    : ok = json['ok'],
      reason = json['reason'],
      isPremium = json['isPremium'],
      sync = json['sync'],
      serverTime = json['serverTime'];
}

class ApiServices {
  static final _paths = _ApiUrls();

  static Future<LoginApi> login({
    required String idToken,
    String? userName,
    Map<String, dynamic>? encryptedKey,
  }) async {
    final response = await http.post(
      Uri.parse(_paths.login),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'idToken': idToken,
        if (userName != null) 'userName': userName,
        if (encryptedKey != null) 'encryptedKey': encryptedKey,
      }),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final data = body['data'];
      return LoginApi(
        status: ApiLoginStatus.ok,
        data: LoginResponse.fromJson(data),
      );
    }

    if (response.statusCode == 401) {
      return LoginApi(status: ApiLoginStatus.unauthorized, data: null);
    }

    return LoginApi(status: ApiLoginStatus.loginFailed, data: null);
  }

  static Future<SyncApi> sync({
    required String accessToken,
    required List<Map<String, dynamic>> notes,
    required List<Map<String, dynamic>> folders,
    required int lastSync,
  }) async {
    final response = await http.post(
      Uri.parse(_paths.sync),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'notes': notes,
        'folders': folders,
        'lastSync': lastSync,
      }),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 401) {
      return SyncApi(status: SyncStatus.unauthorized);
    }

    if (response.statusCode == 200 || response.statusCode == 403) {
      final data = SyncResponseModel.fromJson(body['data']);

      if (data is Map<String, dynamic>) {
        if (data.ok == true) {
          return SyncApi(status: SyncStatus.ok, data: data);
        } else {
          return SyncApi(status: SyncStatus.limitStorageReached, data: data);
        }
      }
    }

    return SyncApi(status: SyncStatus.failed);
  }
}

// login
enum ApiLoginStatus { unauthorized, loginFailed, ok }

class LoginApi {
  final ApiLoginStatus status;
  final LoginResponse? data;

  LoginApi({required this.status, required this.data});
  bool get isSucces => status == ApiLoginStatus.ok;
}

// sync
enum SyncStatus { ok, unauthorized, limitStorageReached, failed }

class SyncApi {
  final SyncStatus status;
  final SyncResponseModel? data;

  SyncApi({required this.status, this.data});

  bool get isOk => status == SyncStatus.ok;
}
