import 'package:flutter/material.dart';
import 'package:tag_links/core/auth/auth_response.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _loading = false;

  Future<void> _handleGoogleLogin() async {
    setState(() => _loading = true);

    try {
      final idToken = await _getGoogleIdToken();
      if (idToken == null) return;

      final response = await _sendToBackend(idToken);

      if (response.isFirstLogin) {
        await _handleFirstLogin(idToken);
      } else {
        await _handleNormalLogin(response.encryptedKey);
      }

      _goToHome();
    } catch (e) {
      debugPrint("Login error: $e");
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _handleGoogleLogin,
                child: const Text("Login with Google"),
              ),
      ),
    );
  }

  Future<String?> _getGoogleIdToken() async {
    // Aquí usarías google_sign_in package
    // Placeholder:

    return "GOOGLE_ID_TOKEN";
  }

  Future<AuthResponse> _sendToBackend(String idToken) async {
    // Simulación de llamada HTTP

    // Si el servidor devuelve encryptedKey
    return AuthResponse(
      token: "JWT_TOKEN",
      encryptedKey: DataKey(
        ciphertext: "base64...",
        nonce: "base64...",
        mac: "base64...",
        salt: "base64...",
      ), //datakey recivida o sea la que se almacenara
    );
  }

  Future<void> _handleFirstLogin(String idToken) async {
    final pin = await _askUserForPin();

    final encryptedKey = await _generateEncryptedKey(pin);

    await _registerWithEncryptedKey(idToken, encryptedKey);
  }

  Future<void> _handleNormalLogin(DataKey encryptedKey) async {
    final pin = await _askUserForPin();

    final dataKey = await _decryptDataKey(pin, encryptedKey);

    await _storeDataKeyInMemory(dataKey);
  }

  Future<DataKey> _generateEncryptedKey(String pin) async {
    // 1. Generar DataKey random 32 bytes
    // 2. Derivar key desde PIN (PBKDF2 o Argon2)
    // 3. Cifrar DataKey
    // 4. Retornar base64

    return DataKey(
      ciphertext: "base64...",
      nonce: "base64...",
      mac: "base64...",
      salt: "base64...",
    );
    //datakey generada
  }

  Future<void> _registerWithEncryptedKey(String idToken, DataKey encryptedKey) async {}
  Future<List<int>> _decryptDataKey(
    String pin,
    DataKey encryptedKey,
  ) async {
    // 1. Derivar clave desde PIN usando salt
    // 2. Desencriptar ciphertext
    // 3. Verificar MAC
    // 4. Retornar DataKey

    return [];
  }

  Future<String> _askUserForPin() async {
    // Mostrar dialog
    return "123456";
  }

  Future<void> _storeDataKeyInMemory(List<int> dataKey) async {
    // Idealmente en memoria segura, no en disco plano
  }
  void _goToHome(){

  }
}
