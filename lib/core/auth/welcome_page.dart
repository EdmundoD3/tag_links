import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/auth/account_sync_tile.dart';
import 'package:tag_links/core/google/auth_provider.dart';
import 'package:tag_links/core/locate/lang_selector.dart';
import 'package:tag_links/core/locate/t_keys.dart';

class WelcomePage extends ConsumerWidget {
  // Añadimos el parámetro opcional
  final bool isExpired;
  
  const WelcomePage({
    super.key,
    this.isExpired = false, // Por defecto es una bienvenida normal
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchamos el authProvider para bloquear botones si está cargando
    final authState = ref.watch(authProvider);
    final bool isLoading = authState.isLoading;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Align(
              //   alignment: Alignment.topRight,
              //   child: const LangSelector(),
              // ),
              
              const Spacer(),

              // --- ICONO DINÁMICO ---
              // Si expiró, usamos un icono de alerta naranja
              Icon(
                isExpired ? Icons.sync_problem : Icons.cloud_sync,
                size: 100,
                color: isExpired ? Colors.orange : Colors.blue,
              ),
              
              const SizedBox(height: 32),
              
              // --- TÍTULO DINÁMICO ---
              Text(
                isExpired 
                  ? ref.tr(TKeys.auth.sessionExpired, fallback: "Sesión expirada")
                  : ref.tr(TKeys.auth.syncLinks, fallback: "Sincroniza tus enlaces"),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // --- SUBTÍTULO DINÁMICO ---
              Text(
                isExpired
                  ? ref.tr(TKeys.auth.reconnectGoogle, 
                      fallback: "Tu conexión con Google Drive se ha perdido. Vuelve a iniciar sesión para sincronizar tus cambios.")
                  : ref.tr(TKeys.auth.syncWithGoogleDrive, 
                      fallback: "Mantén tus notas seguras y sincronizadas entre todos tus dispositivos."),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              
              const SizedBox(height: 48),

              // Botón de Google (AccountSyncTile ya debería manejar su propio estado interno)
              const AccountSyncTile(),

              const SizedBox(height: 16),

              // --- BOTÓN OMITIR ---
              // Lo deshabilitamos si está intentando loguear
              TextButton(
                onPressed: isLoading 
                  ? null 
                  : () => ref.read(authProvider.notifier).skipLogin(),
                child: Text(
                  ref.tr(TKeys.auth.skipForNow, fallback: "Omitir por ahora"),
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: isLoading ? Colors.grey : null,
                  ),
                ),
              ),

              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}