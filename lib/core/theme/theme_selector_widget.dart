import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/theme/theme_provider.dart';
import 'package:tag_links/core/theme/app_theme.dart';
import 'package:tag_links/core/locate/app_lang.dart';

class ThemeSelector extends ConsumerWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(paletteProvider);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            t(ref, 'settingsTheme', fallback: 'Tema'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.titleLarge?.color,
            ),
          ),
        ),
        const SizedBox(height: 12),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: AppPalette.values.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final palette = AppPalette.values[index];
            final selected = palette == current;

            return GestureDetector(
              onTap: () => ref.read(paletteProvider.notifier).set(palette),
              child: AnimatedContainer(
                duration: const Duration(
                  milliseconds: 250,
                ), // Un poco más lento para que se note el efecto
                curve: Curves
                    .easeInOut, // Suaviza la animación de entrada y salida
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color.fromARGB(40, 142, 145, 153),
                  border: Border.all(
                    color: selected
                        ? const Color(0xFF8E9199)
                        : Colors.transparent,
                    width: selected ? 2 : 1,
                  ),
                ),
                // 1. EL TRUCO: Padding dinámico.
                // Si está seleccionado el padding es 4 (cuadro grande).
                // Si no, es 12 (cuadro pequeño).
                padding: EdgeInsets.all(selected ? 4 : 12),

                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  decoration: BoxDecoration(
                    color: getPalette(
                      palette: palette,
                    ).appBarTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: selected
                        ? Icon(
                            Icons.check,
                            size:
                                18, // Un poco más pequeño para que no sature el cuadro
                            color: theme.iconTheme.color,
                          )
                        : null,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
