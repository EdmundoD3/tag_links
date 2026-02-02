import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/locate/app_lang.dart';
import 'package:tag_links/state/lang_provider.dart';

class LangSelector extends ConsumerWidget {
  const LangSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(langProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Idioma',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        ...AppLang.values.map((lang) {
          return RadioListTile<AppLang>(
            title: Text(lang.label),
            value: lang,
            groupValue: current,
            onChanged: (val) {
              if (val != null) {
                ref.read(langProvider.notifier).set(val);
              }
            },
          );
        }),
      ],
    );
  }
}
