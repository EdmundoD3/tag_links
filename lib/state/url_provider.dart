import 'package:tag_links/core/media_in_coming/incoming_share.dart';

class ShareListener {
  static Stream<String> get stream => IncomingShare.stream;

  static Future<String?> getInitial() {
    return IncomingShare.getInitial();
  }

  static bool isUrl(String text) {
    final uri = Uri.tryParse(text);

    return uri != null &&
        uri.hasScheme &&
        uri.host.isNotEmpty;
  }
}