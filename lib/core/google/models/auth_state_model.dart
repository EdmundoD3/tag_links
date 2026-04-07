import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:tag_links/core/google/models/silent_login_result.dart';

class AuthState {
  final GoogleSignInAccount? user;
  final DriveApi? driveApi;
  final bool isLoading;
  final SilentLoginResult? lastResult; // <--- Nuevo campo

  AuthState({
    this.user,
    this.driveApi,
    this.isLoading = false,
    this.lastResult,
  });

  bool get isAuthenticated => user != null && driveApi != null;
  bool get isSessionExpired => lastResult == SilentLoginResult.expired;
}
