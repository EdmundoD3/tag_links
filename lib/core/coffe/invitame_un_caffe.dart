import 'package:flutter/material.dart';
final String _donationUrl ="";
class InvitameUnCaffe extends StatelessWidget {
  const InvitameUnCaffe({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if(_donationUrl.isEmpty) return const SizedBox.shrink();

    return ListTile(
      leading: const Icon(Icons.coffee, color: Color(0xFFBB9457)),
      title: Text(
        "Invítame un café",
        style: TextStyle(color: theme.textTheme.bodyMedium?.color),
      ),
      subtitle: Text(
        "Apoyo externo para el desarrollo.",
        style: TextStyle(color: theme.hintColor),
      ),
      onTap: _launchDonationUrl,
    );
  }

  void _launchDonationUrl() {}
}
