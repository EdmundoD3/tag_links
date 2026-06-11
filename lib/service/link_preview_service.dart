import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:tag_links/models/link_preview.dart';

class LinkPreviewService {
  static Future<LinkPreview?> prepareForSave(LinkPreview? link) async {
    if (link == null) return null;

    if (!link.shouldRefreshThumbnail) {
      return link;
    }
    final now = DateTime.now().millisecondsSinceEpoch;

    try {
      final enriched = await _fetchMetadata(link);

      return (enriched ?? link).copyWith(lastUpdate: now);
    } catch (_) {
      return link.copyWith(lastUpdate: now);
    }
  }

  static Future<LinkPreview?> _fetchMetadata(LinkPreview link) async {
    try {
      final uri = Uri.tryParse(link.url);
      if (uri == null) return null;

      final response = await http
          .get(
            uri,
            headers: {
              'User-Agent':
                  'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/04.1',
            },
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) return null;

      final document = parse(
        utf8.decode(response.bodyBytes, allowMalformed: true),
      );

      String? meta(String selector, [String attr = 'content']) =>
          document.querySelector(selector)?.attributes[attr];

      String? title =
          meta('meta[property="og:title"]') ??
          document.querySelector('title')?.text;
      String? desc =
          meta('meta[property="og:description"]') ??
          meta('meta[name="description"]');
      String? img = meta('meta[property="og:image"]');

      if (img != null && img.startsWith('/')) {
        img = "${uri.scheme}://${uri.host}$img";
      }

      // IMPORTANTE: Aquí no ponemos el lastUpdate todavía,
      // dejamos que prepareForSave lo haga para centralizar la lógica.
      return link.copyWith(
        title: title?.trim(),
        description: desc?.trim(),
        image: img,
        siteName: meta('meta[property="og:site_name"]'),
      );
    } catch (e) {
      debugPrint("Error en scraping de ${link.url}: $e");
      return null; // El try-catch de prepareForSave se encargará del resto
    }
  }
}
