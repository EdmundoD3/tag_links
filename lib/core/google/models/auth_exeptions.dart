/// Base para todas las excepciones de autenticación en Tag Links
sealed class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

class NetworkAuthException extends AuthException {
  NetworkAuthException() : super("No hay conexión a internet para validar la sesión.");
}

class DrivePermissionDeniedException extends AuthException {
  DrivePermissionDeniedException() : super("El usuario no otorgó permisos para Google Drive.");
}

class SessionExpiredException extends AuthException {
  SessionExpiredException() : super("La sesión ha expirado. Es necesario re-autenticar.");
}

class UserCancelledException extends AuthException {
  UserCancelledException() : super("El usuario canceló el inicio de sesión.");
}