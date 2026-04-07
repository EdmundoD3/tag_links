sealed class SyncException implements Exception {
  final String message;
  SyncException(this.message);

  @override
  String toString() => message;
}

/// Error de red o falta de conexión
class NetworkSyncException extends SyncException {
  NetworkSyncException() : super("Sin conexión a internet");
}

/// Error de Google Drive (ej: falta de espacio o permisos)
class DriveStorageException extends SyncException {
  DriveStorageException(String detail) : super("Error en Drive: $detail");
}

/// Error de autenticación (sesión expirada o nula)
class AuthSyncException extends SyncException {
  AuthSyncException() : super("Sesión de usuario no válida");
}

/// Error al procesar JSON o datos corruptos
class DataSyncException extends SyncException {
  DataSyncException(String detail) : super("Datos corruptos: $detail");
}

/// Error crítico de configuración
class ConfigSyncException extends SyncException {
  ConfigSyncException() : super("Error en el archivo de configuración");
}