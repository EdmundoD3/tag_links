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
      crossAxisAlignment: CrossAxisAlignment.start,
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
        RadioGroup<AppLang>(
          groupValue: current,
          onChanged: (val) {
            if (val != null) {
              ref.read(langProvider.notifier).set(val);
            }
          },
          child: Column(
            children: AppLang.values.map((lang) {
              return RadioListTile<AppLang>(
                selectedTileColor: theme.textTheme.titleSmall?.color,
                activeColor: theme.textTheme.titleSmall?.color,
                title: Text(
                  lang.label,
                  style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                ),
                value: lang,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
