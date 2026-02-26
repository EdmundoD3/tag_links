import 'package:flutter/material.dart';
import 'package:tag_links/core/auth/auth_manager.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _loading = false;

  Future<void> _handleLogin() async {
    setState(() => _loading = true);

    try {
      await AuthManager.loginFlow(askPin: () => _showPinDialog(context));

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, "/home");
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : ElevatedButton.icon(
                onPressed: _handleLogin,
                icon: const Icon(Icons.login),
                label: const Text("Continuar con Google"),
              ),
      ),
    );
  }

  Future<String> _showPinDialog(BuildContext context) async {
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Ingresa tu PIN"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          obscureText: true,
          maxLength: 6,
          decoration: const InputDecoration(hintText: "PIN de 6 dígitos"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.length < 4) return;
              Navigator.pop(context, controller.text);
            },
            child: const Text("Aceptar"),
          ),
        ],
      ),
    );

    if (result == null || result.isEmpty) {
      throw Exception("PIN requerido");
    }

    return result;
  }
}
