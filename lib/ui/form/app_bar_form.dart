import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppBarForm extends StatelessWidget implements PreferredSizeWidget {
  final bool isFavorite;
  final String title;
  final void Function() onFavoriteToogle;
  final void Function() onSave;
  final List<Widget>? actions;
  final bool isSaving;
  final ValueListenable<TextEditingValue>? titleListenable;


  const AppBarForm({
    super.key,
    required this.title,
    this.actions,
    required this.onSave,
    required this.isFavorite,
    required this.onFavoriteToogle,
    required this.isSaving, this.titleListenable,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget titleWidget;

    if (titleListenable != null) {
      titleWidget = ValueListenableBuilder<TextEditingValue>(
        valueListenable: titleListenable!,
        builder: (_, value, _) {
          return Text(value.text);
        },
      );
    } else {
      titleWidget = Text(title);
    }
    return AppBar(
      title: titleWidget,
      actions: [
        isFavorite
            ? IconButton(
                onPressed: onFavoriteToogle,
                icon: const Icon(Icons.favorite, color: Colors.red),
              )
            : IconButton(
                onPressed: onFavoriteToogle,
                icon: Icon(
                  Icons.favorite_border,
                  color: theme.iconTheme.color ?? Colors.grey,
                ),
              ),
        IconButton(
          icon: isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(),
                )
              : Icon(
                  Icons.save,
                  color: theme.iconTheme.color ?? Colors.deepPurple,
                ),
          onPressed: onSave,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
