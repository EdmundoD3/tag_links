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
      children: [
        _title(
          languageTitle: ref.tr(TKeys.pages.languageTitle, fallback: 'Idioma'),
          color: theme.textTheme.titleLarge?.color,
        ),
        GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: _grid,
          itemCount: AppLang.values.length,
          itemBuilder: (context, index) {
            final lang = AppLang.values[index];

            return _LanguageCard(
              lang: lang,
              isSelected: current == lang,
              onTap: () {
                ref.read(langProvider.notifier).set(lang);
              },
            );
          },
        ),
      ],
    );
  }

  SliverGridDelegate get _grid =>
      const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        mainAxisExtent: 62,
      );

  Widget _title({required String languageTitle, required Color? color}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        languageTitle,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: color,
          fontSize: 18,
        ),
      ),
    );
  }
}
class _LanguageCard extends StatelessWidget {
  final AppLang lang;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.lang,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: isSelected
          ? theme.colorScheme.primaryContainer
          : theme.cardColor,
      elevation: isSelected ? 2 : 0,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.dividerColor.withValues(alpha: 0.25),
              width: isSelected ? 1.8 : 1,
            ),
          ),
          child: Row(
            children: [
              Text(
                lang.emoji,
                style: const TextStyle(fontSize: 20),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  lang.label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),

              if (isSelected)
                Icon(
                  Icons.check_rounded,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}