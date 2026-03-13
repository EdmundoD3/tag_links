import 'package:tag_links/core/sync/folder_raw_sync.dart';
import 'package:tag_links/core/sync/note_raw_sync.dart';

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

// ==========================================
// MODELOS DE RESPUESTA (DATA TRANSFER OBJECTS)
// ==========================================

class SyncResult {
  final ApiSaveResult save;
  final PullResult pull;

  SyncResult({required this.save, required this.pull});

  factory SyncResult.fromJson(Map<String, dynamic> json) {
    return SyncResult(
      save: ApiSaveResult.fromJson(json['save']),
      pull: PullResult.fromJson(json['pull']),
    );
  }
}

class SyncResponseModel {
  final bool ok;
  final String? reason;
  final bool isPremium;
  final SyncResult sync;
  final int serverTime;

  SyncResponseModel({
    required this.ok,
    required this.reason,
    required this.isPremium,
    required this.sync,
    required this.serverTime,
  });

  factory SyncResponseModel.fromJson(Map<String, dynamic> json) {
    return SyncResponseModel(
      ok: json['ok'] as bool,
      reason: json['reason'] as String?,
      isPremium: json['isPremium'] as bool,
      sync: SyncResult.fromJson(json['sync']),
      serverTime: json['serverTime'] as int,
    );
  }
}


class PullResult {
  final bool ok;
  final String? error;
  final PullData? data;
  final int? cursor;
  final bool hasMore;

  PullResult({
    required this.ok,
    this.error,
    this.data,
    this.cursor,
    required this.hasMore,
  });

  factory PullResult.fromJson(Map<String, dynamic> json) {
    final isOk = json['ok'] as bool;
    if (!isOk) {
      return PullResult(ok: false, error: json['error'], hasMore: false);
    }

    return PullResult(
      ok: true,
      data: PullData.fromJson(json['data']),
      cursor: json['cursor'] as int?,
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }
}

class PullData {
  final List<NoteRawSync> notes;
  final List<FolderRawSync> folders;

  PullData({required this.notes, required this.folders});

  factory PullData.fromJson(Map<String, dynamic> json) {
    return PullData(
      // Usamos el factory fromJson que creamos en NoteRawSync/FolderRawSync
      notes: (json['notes'] as List? ?? [])
          .map((n) => NoteRawSync.fromJson(n as Map<String, dynamic>))
          .toList(),
      folders: (json['folders'] as List? ?? [])
          .map((f) => FolderRawSync.fromJson(f as Map<String, dynamic>))
          .toList(),
    );
  }
}