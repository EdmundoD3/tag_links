import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/auth/account_sync_tile.dart';
import 'package:tag_links/core/google/auth_provider.dart';
import 'package:tag_links/core/locate/lang_selector.dart';
import 'package:tag_links/core/locate/t_keys.dart';
import 'package:tag_links/ui/button/action_button.dart';

class WelcomePage extends ConsumerWidget {
  final bool isExpired;
  
  const WelcomePage({
    super.key,
    this.isExpired = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final bool isLoading = authState.isLoading;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  // Forzamos a que el contenido mida al menos lo mismo que la pantalla
                  minHeight: constraints.maxHeight - 48, // 48 es el ajuste por padding (24 arriba + 24 abajo)
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // --- PARTE SUPERIOR ---
                    Align(
                      alignment: Alignment.topRight,
                      child: const LangSelector(),
                    ),
                    
                    // --- PARTE CENTRAL (CONTENIDO) ---
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 32),
                        Icon(
                          isExpired ? Icons.sync_problem : Icons.cloud_sync,
                          size: 100,
                          color: isExpired ? Colors.orange : Colors.blue,
                        ),
                        const SizedBox(height: 32),
                        Text(
                          isExpired 
                            ? ref.tr(TKeys.auth.sessionExpired, fallback: "Sesión expirada")
                            : ref.tr(TKeys.auth.syncLinks, fallback: "Sincroniza tus enlaces"),
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isExpired
                            ? ref.tr(TKeys.auth.reconnectGoogle, 
                                fallback: "Tu conexión con Google Drive se ha perdido. Vuelve a iniciar sesión para sincronizar tus cambios.")
                            : ref.tr(TKeys.auth.syncWithGoogleDrive, 
                                fallback: "Mantén tus notas seguras y sincronizadas entre todos tus dispositivos."),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),

                    // --- PARTE INFERIOR (BOTONES) ---
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 48),
                        const AccountSyncTile(),
                        const SizedBox(height: 16),
                        ActionTextButton(
                          onPressed: isLoading 
                            ? null 
                            : () => ref.read(authProvider.notifier).skipLogin(),
                          label: ref.tr(TKeys.auth.skipForNow, fallback: "Omitir por ahora"),
                        ),
                        const SizedBox(height: 42),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}