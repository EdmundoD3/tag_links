import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:tag_links/models/link_preview.dart';

class LinkPreviewService {
  Future<LinkPreview?> prepareForSave(LinkPreview? link) async {
    if (link == null) return null;
    if (link.hasMetadata) return link;

    try {
      final enriched = await _fetchMetadata(link);
      return enriched ?? link;
    } catch (_) {
      return link;
    }
  }
Future<LinkPreview?> enrich(LinkPreview link) async {
    if (link.hasMetadata) return link;

    try {
      final updated = await _fetchMetadata(link);
      return updated ?? link;
    } catch (_) {
      return link;
    }
  }

  Future<LinkPreview?> _fetchMetadata(LinkPreview link) async {
    final uri = Uri.tryParse(link.url);
    if (uri == null) return null;

    final response = await http
        .get(uri, headers: {
          'User-Agent': 'Mozilla/5.0 (compatible; TagLinks/1.0)',
        })
        .timeout(const Duration(seconds: 5));

    if (response.statusCode != 200) return null;

    final document = parse(response.body);

    String? meta(String selector, [String attr = 'content']) =>
        document.querySelector(selector)?.attributes[attr];

    return link.copyWith(
      title: document.querySelector('title')?.text,
      description: meta('meta[name="description"]'),
      image: meta('meta[property="og:image"]'),
      siteName: meta('meta[property="og:site_name"]'),
    );
  }
}
