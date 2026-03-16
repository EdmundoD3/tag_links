import 'dart:async';
import 'dart:convert';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:tag_links/api/api_constants.dart';
import 'package:tag_links/api/api_models.dart';
import 'package:tag_links/api/login_response.dart';
import 'package:tag_links/core/encypt/encrypted_datakey_model.dart';
import 'package:tag_links/core/sync/folder_raw_sync.dart';
import 'package:tag_links/core/sync/note_raw_sync.dart';

class ApiServices {
  static final _paths = ApiUrls();

  static Future<LoginApi?> login({
    required String idToken,
    String? userName,
    EncryptedDataKey? encryptedKey,
  }) async {
    if(!_paths.isAvailable)return null;
    final response = await _HttpService.post(
      path: _paths.login,
      body: {
        'idToken': idToken,
        'userName': userName,
        if (encryptedKey != null) 'encryptedKey': encryptedKey.toJson(),
      },
      accessToken: null,
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

  static Future<ApiSaveResult?> registerEncryptedKey({
    required String accessToken,
    required EncryptedDataKey encryptedKey,
  }) async {
    if(!_paths.isAvailable)return null;
    final response = await _HttpService.post(
      path: _paths.encryptionKey,
      body: {
        'encryptedKey': encryptedKey.toJson(),
      },
      accessToken: accessToken,
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return ApiSaveResult(ok: true, message: body['data']?['message']);
    }

    return ApiSaveResult(ok: false, error: body['error'] ?? 'Unknown error');
  }

  static Future<SyncApiRes?> sync({
    required String accessToken,
    required List<NoteRawSync> notes,
    required List<FolderRawSync> folders,
    required int? lastPulledAt,
    required String lastId,
  }) async {
    if(!_paths.isAvailable)return null;
    try {
      return await _performSync(
        accessToken: accessToken,
        notes: notes,
        folders: folders,
        lastPulledAt: lastPulledAt,
        lastId: lastId,
      );
    } on TimeoutException catch (_) {
      // 2. Manejo específico si el servidor tarda mucho (Cloudflare Worker frío o mala señal)
      debugPrint('Sync Timeout: El servidor no respondió a tiempo');
      return SyncApiRes(
        status: SyncApiStatus.failed,
      ); // O podrías crear un status 'timeout'
    } on Exception catch (e) {
      // 3. Manejo de errores de red (Sin internet, DNS error, etc)
      debugPrint('Sync Network Error: $e');
      return SyncApiRes(status: SyncApiStatus.failed);
    }
  }

  static Future<ApiPurchaseResult?> verifyPurchase({
    required String token,
    required String productId,
    required String purchaseId,
    required MethodPurchase platform,
  }) async {
    try {
      if(!_paths.isAvailable)return null;

      final response = await _HttpService.post(
        path: _paths.verifyPurchase,
        body: {
          'token': token,
          'productId': productId,
          'purchaseId': purchaseId,
          'platform': platform.name,
        },
      );
      debugPrint("implementar verifyPurchase en api_services.dart");
    } catch (e) {
      return null;
    }
  }
// -------------------------- performs ----------------------------
  static Future<SyncApiRes> _performSync({
    required String accessToken,
    required List<NoteRawSync> notes,
    required List<FolderRawSync> folders,
    required int? lastPulledAt,
    required String lastId,
  }) async {
    final response = await _HttpService.post(
      path: _paths.sync,
      accessToken: accessToken,
      body: {
        'notes': notes.map((e) => e.toJson()).toList(),
        'folders': folders.map((e) => e.toJson()).toList(),
        'lastPulledAt': lastPulledAt ?? 0,
        'lastId': lastId,
      },
    );

    if (response.statusCode == 401) {
      return SyncApiRes(status: SyncApiStatus.unauthorized);
    }

    final body = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 403) {
      final data = SyncResponseModel.fromJson(body['data']);
      return SyncApiRes(
        status: data.ok ? SyncApiStatus.ok : SyncApiStatus.limitStorageReached,
        data: data,
      );
    }

    return SyncApiRes(status: SyncApiStatus.failed);
  }
}

// login
class LoginApi {
  final ApiLoginStatus status;
  final LoginResponse? data;

  LoginApi({required this.status, required this.data});
  bool get isSucces => status == ApiLoginStatus.ok;
}

class _HttpService {
  static Future<http.Response> post({
    required String path,
    required Map<String, dynamic> body,
    String? accessToken,
    Duration duration = const Duration(seconds: 10),
  }) {
    return http
        .post(
          Uri.parse(path),
          headers: {
            'Content-Type': 'application/json',
            if (accessToken != null) 'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode(body),
        )
        .timeout(duration);
  }
}
