import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/locate/t_keys.dart';
import 'package:url_launcher/url_launcher.dart';

final Uri _donationUrl = Uri.parse('https://buymeacoffee.com/Notita');

class InvitameUnCaffe extends ConsumerWidget {
  const InvitameUnCaffe({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return ListTile(
      leading: const Icon(Icons.coffee, color: Color(0xFFBB9457)),
      title: Text(
        ref.tr(TKeys.ads.buyCoffee, fallback: 'Invítame un café'),
        style: TextStyle(color: theme.textTheme.bodyMedium?.color),
      ),
      subtitle: Text(
        ref.tr(
          TKeys.ads.buyCoffeeDesc,
          fallback:
              'Si te gusta la app, invítame un café para apoyar el proyecto',
        ),
        style: TextStyle(color: theme.hintColor),
      ),
      onTap: _launchDonationUrl,
    );
  }

  Future<void> _launchDonationUrl() async {
    await launchUrl(
      _donationUrl,
      mode: LaunchMode.externalApplication,
    );
  }
}