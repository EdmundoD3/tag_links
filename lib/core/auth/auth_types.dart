import 'package:tag_links/core/encypt/encrypted_datakey_model.dart';

class AuthData {
  final EncryptedDataKey? dataKey;
  final String? token;

  AuthData({required this.dataKey, required this.token});
}

enum AuthMode {
  guest, // Usuario omitió el login (Solo local)
  logged, // Usuario logueado (Sync activo)
  reauth, // Sesión expirada (Necesita re-loguear para volver a sync)
  initial, // Primera vez abriendo la app
}