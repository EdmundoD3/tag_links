import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/locate/app_lang.dart';

final String _donationUrl ="";
class InvitameUnCaffe extends ConsumerWidget {
  const InvitameUnCaffe({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    if(_donationUrl.isEmpty) return const SizedBox.shrink();
    
    return ListTile(
      leading: const Icon(Icons.coffee, color: Color(0xFFBB9457)),
      title: Text(
        t(ref, 'buyMeCoffee', fallback: 'Invítame un café'),
        style: TextStyle(color: theme.textTheme.bodyMedium?.color),
      ),
      subtitle: Text(
        t(ref, 'buyMeCoffeeDescription', fallback: 'Si te gusta la app, invítame un café para apoyar el proyecto'),
        style: TextStyle(color: theme.hintColor),
      ),
      onTap: _launchDonationUrl,
    );
  }

  void _launchDonationUrl() {}
}
