import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tag_links/core/google/auth_provider.dart';
import 'package:tag_links/core/locate/t_keys.dart';
import 'package:tag_links/sync/sync_fowder_handler.dart';
import 'package:tag_links/ui/modals/confirm_dialog.dart';

class AccountSyncTile extends ConsumerWidget {
  const AccountSyncTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    // Si está autenticado, mostramos el resumen de cuenta
    if (auth.isAuthenticated) {
      return _UserInfoTile(
        user: auth.user!,
        onLogout: () => ref.read(authProvider.notifier).logout(),
      );
    }

    // Si no, mostramos el botón de acción para loguear
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: _GoogleLoginButton(),
    );
  }
}

class _GoogleLoginButton extends ConsumerWidget {
  const _GoogleLoginButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(authProvider.select((s) => s.isLoading));

    return ElevatedButton.icon(
      onPressed: isLoading
          ? null
          : () async {
              // 🎯 1. Invocamos al manejador interactivo unificado pasándole el contexto fresco
              await SyncFlowHandler.handleInteractiveLogin(context, ref);
              
              // 🛡️ 2. Cláusula de guardia: Si el usuario tardó mucho y cerró la pantalla de ajustes,
              // evitamos cualquier debugPrint posterior.
              if (!context.mounted) return;

              // 3. Verificamos el resultado final para tu log de control
              final auth = ref.read(authProvider);
              if (auth.isAuthenticated) {
                debugPrint(
                  "🎯 Login exitoso desde Ajustes: Todo sincronizado correctamente.",
                );
              }
            },
      icon: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.cloud_upload, color: Color(0xFF7E57C2)),
      label: Text(
        ref.tr(TKeys.auth.loginWithGoogle),
        style: const TextStyle(color: Color(0xFF9E80D1)),
      ),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(
          double.infinity,
          48,
        ),
      ),
    );
  }
}

class _UserInfoTile extends ConsumerWidget {
  final GoogleSignInAccount user;
  final VoidCallback onLogout;

  const _UserInfoTile({required this.user, required this.onLogout});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: user.photoUrl != null
            ? NetworkImage(user.photoUrl!)
            : null,
        child: user.photoUrl == null ? const Icon(Icons.person) : null,
      ),
      title: Text(user.displayName ?? "User"),
      subtitle: Text(user.email),
      trailing: IconButton(
        icon: const Icon(Icons.logout, color: Colors.redAccent),
        tooltip: ref.tr(TKeys.auth.logOut),
        onPressed: () async {
          // 🎯 Llamamos al diálogo de confirmación
          final confirm = await ConfirmDialog.logout(context, ref);

          // Si el usuario aceptó (true), ejecutamos el logout
          if (confirm == true) {
            onLogout();
          }
        },
      ),
    );
  }
}
