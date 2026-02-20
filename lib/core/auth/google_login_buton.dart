import 'package:flutter/material.dart';
import 'package:tag_links/core/auth/auth_manager.dart';

class GoogleLoginButton extends StatefulWidget {
  const GoogleLoginButton({super.key});

  @override
  State<GoogleLoginButton> createState() => _GoogleLoginButtonState();
}

class _GoogleLoginButtonState extends State<GoogleLoginButton> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isLoading
          ? null
          : () async {
              setState(() => isLoading = true);

              try {
                await AuthManager.interactiveLogin();

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Login exitoso")),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: $e")),
                  );
                }
              }

              setState(() => isLoading = false);
            },
      icon: const Icon(Icons.login),
      label: Text(isLoading ? "Cargando..." : "Continuar con Google"),
    );
  }
}
