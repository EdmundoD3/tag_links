import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/google/auth_provider.dart';

class AuthPage extends ConsumerWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchamos el estado del provider
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: Center(
        child: authState.isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_sync, size: 80, color: Colors.blue),
                  const SizedBox(height: 20),
                  const Text(
                    "Sincroniza tus enlaces",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                    child: Text(
                      "Utilizaremos Google Drive para mantener tus notas seguras y sincronizadas entre dispositivos.",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () => _handleLogin(context, ref),
                    icon: const Icon(Icons.login),
                    label: const Text("Continuar con Google"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _handleLogin(BuildContext context, WidgetRef ref) async {
    try {
      // Llamamos al método login del Notifier
      await ref.read(authProvider.notifier).login();
      
      // Nota: Si usas un Wrapper en el main, no necesitas Navigator.push.
      // La app detectará el cambio de estado y cambiará la pantalla sola.
      
    } catch (e) {
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error de autenticación: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}