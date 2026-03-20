import 'dart:convert';

import 'package:flutter/material.dart';
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

      // 1. Decodificar correctamente para evitar problemas con acentos/eñes
      final document = parse(
        utf8.decode(response.bodyBytes, allowMalformed: true),
      );

      String? meta(String selector, [String attr = 'content']) =>
          document.querySelector(selector)?.attributes[attr];

      // 2. Priorizar etiquetas Open Graph
      String? title =
          meta('meta[property="og:title"]') ??
          document.querySelector('title')?.text;
      String? desc =
          meta('meta[property="og:description"]') ??
          meta('meta[name="description"]');
      String? img = meta('meta[property="og:image"]');

      // 3. Validar URL de imagen
      if (img != null && img.startsWith('/')) {
        img = "${uri.scheme}://${uri.host}$img";
      }

      return link.copyWith(
        title: title?.trim(),
        description: desc?.trim(),
        image: img,
        siteName: meta('meta[property="og:site_name"]'),
      );
    } catch (e) {
      debugPrint("Error en scraping de ${link.url}: $e");
      return null;
    }
  }
}
