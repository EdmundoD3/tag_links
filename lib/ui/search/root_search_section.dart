import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/models/tag.dart';
import 'package:tag_links/state/folders_provider.dart';
import 'package:tag_links/state/notes_provider.dart';
import 'package:tag_links/state/search_query_provider.dart';
import 'package:tag_links/state/tags_provider.dart';
import 'package:tag_links/ui/button/switch_favorite.dart';
import 'package:tag_links/ui/search/search_bar.dart';
import 'package:tag_links/ui/search/tags_suggestion_list.dart';
import 'package:tag_links/ui/tags/tag_selected_container.dart';

class RootSearchSection extends ConsumerWidget {
  const RootSearchSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: _SearchBarInternal(),
        ),
        const SizedBox(height: 16),
        TagsSelectedContainer(
          tags: ref.watch(searchQueryProvider).includeTags,
          onDeleted: (Tag tag) {
            ref.read(searchQueryProvider.notifier).removeTag(tag);
          },
          isCreateTag: false,
        ),
      ],
    );
  }
}

class _SearchBarInternal extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtenemos el estado de las sugerencias (AsyncValue)
    final tagsAsync = ref.watch(tagsProvider);
    final queryText = ref.watch(searchQueryProvider).text;

    return SearchListBar<Tag>(
      queryText: queryText,
      itemsSuggestion: tagsAsync,
      // Icono izquierdo para favoritos
      iconLeftBtn: SwitchFavorite(
        isFavorite: ref.read(searchQueryProvider).isFavorite,
        onChanged: () {
          ref.read(searchQueryProvider.notifier).toggleFavorite();
        },
      ),
      // Lógica al escribir
      onChangeText: (String text) {
        ref.read(searchQueryProvider.notifier).setText(text);
        ref.read(tagSearchTextProvider.notifier).state = text;

        // Invalidamos los providers para refrescar la UI principal
        ref.invalidate(foldersProvider(null));
        ref.invalidate(notesProvider(null));
      },
      // Lógica al seleccionar un Tag de la lista
      onTagSelected: (Tag tag) {
        ref.read(searchQueryProvider.notifier).addTag(tag);
      },
      // --- ESTA ES LA PARTE NUEVA ---
      // Usamos el contrato que creamos. 
      // El buscador se encarga de decidir CUÁNDO mostrarlo (foco/texto),
      // y este widget se encarga de CÓMO dibujarlo.
      suggestionBuilder: TagsSuggestionList(
        itemsSuggestion: tagsAsync,
        onItemSelected: (Tag tag) {
          ref.read(searchQueryProvider.notifier).addTag(tag);
        },
      ),
    );
  }
}