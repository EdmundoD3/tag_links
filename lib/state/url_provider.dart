import 'package:share_handler/share_handler.dart';

class ShareListener {
  static Stream<SharedMedia?> get stream =>
      ShareHandler.instance.sharedMediaStream;

  static Future<SharedMedia?> getInitial() =>
      ShareHandler.instance.getInitialSharedMedia();

  static bool isUrl(String text) {
    final uri = Uri.tryParse(text);
    return uri != null && uri.hasScheme && uri.host.isNotEmpty;
  }
}
