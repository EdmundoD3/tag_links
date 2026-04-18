import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/locate/app_lang.dart';
import 'package:tag_links/core/locate/lang_provider.dart';
import 'package:tag_links/core/locate/t_keys.dart';

class LangSelector extends ConsumerWidget {
  const LangSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(langProvider);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            ref.tr(TKeys.pages.language, fallback: 'Idioma'),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.textTheme.titleLarge?.color,
              fontSize: 18,
            ),
          ),
        ),
        // RadioGroup<AppLang>(
        //   groupValue: current,
        //   onChanged: (val) {
        //     if (val != null) {
        //       ref.read(langProvider.notifier).set(val);
        //     }
        //   },
        //   child: Column(
        //     children: AppLang.values.map((lang) {
        //       return RadioListTile<AppLang>(
        //         selectedTileColor: theme.textTheme.titleSmall?.color,
        //         activeColor: theme.textTheme.titleSmall?.color,
        //         title: Text(
        //           lang.label,
        //           style: TextStyle(color: theme.textTheme.bodyMedium?.color),
        //         ),
        //         value: lang,
        //       );
        //     }).toList(),
        //   ),
        // ),
        GridView.builder(
          padding: EdgeInsets.symmetric(horizontal: 10),
          shrinkWrap: true, // Importante para que funcione dentro de un scroll
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Aquí definimos las 2 columnas
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            mainAxisExtent: 60, // Ajusta la altura de cada celda
          ),
          itemCount: AppLang.values.length,
          itemBuilder: (context, index) {
            final lang = AppLang.values[index];
            final isSelected = current == lang;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                // Usando withValues(alpha: ...) que es el estándar actual
                color: isSelected
                    ? theme.colorScheme.primary.withValues(alpha: 0.1)
                    : theme.cardColor.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: isSelected
                      ? theme.badgeTheme.textColor ?? Colors.black
                      : theme.dividerColor.withValues(alpha: 0.2),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: RadioListTile<AppLang>(
                value: lang,
                // ignore: deprecated_member_use
                groupValue: current,
                // ignore: deprecated_member_use
                onChanged: (val) {
                  if (val != null) {
                    ref.read(langProvider.notifier).set(val);
                  }
                },
                // Al ser dos columnas, quitamos un poco de padding interno
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                controlAffinity: ListTileControlAffinity.trailing,
                activeColor: theme.colorScheme.primary,
                title: Row(
                  children: [
                    _getLanguageIcon(lang),
                    const SizedBox(width: 8),
                    Expanded(
                      // Usamos Expanded para evitar errores de espacio en nombres largos
                      child: Text(
                        lang.label,
                        style: TextStyle(
                          fontSize:
                              14, // Un poco más pequeño para que quepa bien en 2 columnas
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

Widget _getLanguageIcon(AppLang lang) {
  // Usamos emojis de banderas para una identificación visual rápida
  switch (lang) {
    case AppLang.es:
      return const Text("🇪🇸", style: TextStyle(fontSize: 20));
    case AppLang.en:
      return const Text("🇺🇸", style: TextStyle(fontSize: 20));
    case AppLang.de:
      return const Text("🇩🇪", style: TextStyle(fontSize: 20));
    case AppLang.pt:
      return const Text(
        "🇧🇷",
        style: TextStyle(fontSize: 20),
      ); // O 🇵🇹 según tu preferencia
    case AppLang.fr:
      return const Text("🇫🇷", style: TextStyle(fontSize: 20));
    case AppLang.ru:
      return const Text("🇷🇺", style: TextStyle(fontSize: 20));
    case AppLang.ja:
      return const Text("🇯🇵", style: TextStyle(fontSize: 20));
    case AppLang.zh:
      return const Text("🇨🇳", style: TextStyle(fontSize: 20));
  }
}
