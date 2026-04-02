import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/auth/account_sync_tile.dart';
import 'package:tag_links/core/google/auth_provider.dart';
import 'package:tag_links/core/locate/lang_selector.dart';
import 'package:tag_links/core/locate/t_keys.dart';

class WelcomePage extends ConsumerWidget {
  const WelcomePage({super.key});
  
@override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: authState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Selector de idioma en la parte superior derecha
                    Align(
                      alignment: Alignment.topRight,
                      child: const LangSelector(),
                    ),
                    
                    const Spacer(), // Empuja el contenido al centro

                    const Icon(Icons.cloud_sync, size: 100, color: Colors.blue),
                    const SizedBox(height: 32),
                    
                    Text(
                      ref.tr(TKeys.auth.syncLinks, fallback: "Sincroniza tus enlaces"),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    
                    Text(
                      ref.tr(TKeys.auth.syncWithGoogleDrive, 
                        fallback: "Mantén tus notas seguras y sincronizadas entre todos tus dispositivos."),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    
                    const SizedBox(height: 48),

                    // Componente que ya maneja el login de Google
                    const AccountSyncTile(),

                    const SizedBox(height: 16),

                    // Botón para saltar
                    TextButton(
                      onPressed: () => ref.read(authProvider.notifier).skipLogin(),
                      child: Text(
                        ref.tr(TKeys.auth.skipForNow, fallback: "Omitir por ahora"),
                        style: const TextStyle(decoration: TextDecoration.underline),
                      ),
                    ),

                    const Spacer(flex: 2), // Espacio extra al final
                  ],
                ),
              ),
      ),
    );
  }
}