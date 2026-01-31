import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TextRule {
  final TextStyle style;
  final int offset;
  const TextRule({required this.style, this.offset = 0});
}

class DecoratedText extends StatelessWidget {
  final String text;
  const DecoratedText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final matches = _allMatches(text);
    final onlyEmojis = RegExp(r'^[\p{Emoji}\s]+$', unicode: true).hasMatch(text);

    return RichText(
      text: TextSpan(
        style: TextStyle(color: Colors.black, fontSize: onlyEmojis ? 32 : 14),
        children: _buildSpans(matches),
      ),
    );
  }

  Iterable<RegExpMatch> _allMatches(String text) {
    return RegExp(
      r'(?<escape>\\.)|'
      r'(?<bold>\*\*.*?\*\*|\*.*?\*)|'
      r'(?<underline>__.*?__|~.*?~)|' // Puedes agrupar similares si quieres
      r'(?<italic>_.*?_)|'
      r'(?<strike>~.*?~)|'
      r'(?<codeText>`.*?`)|'
      r'(?<link>https?:\/\/[^\s]+)|'
      r'(?<mention>@\w+)|'
      r'(?<hashtag>#\w+)',
      unicode: true,
    ).allMatches(text);
  }
    // Configuración centralizada de estilos
  static const Map<String, TextRule> _styleRules = {
    'bold': TextRule(style: TextStyle(fontWeight: FontWeight.bold), offset: 1),
    'italic': TextRule(style: TextStyle(fontStyle: FontStyle.italic), offset: 1),
    'underline': TextRule(style: TextStyle(decoration: TextDecoration.underline), offset: 2),
    'strike': TextRule(style: TextStyle(decoration: TextDecoration.lineThrough), offset: 1),
    'code': TextRule(
      style: TextStyle(fontFamily: 'monospace', backgroundColor: Color(0xFFE0E0E0)),
      offset: 1,
    ),
    'mention': TextRule(style: TextStyle(color: Colors.blueAccent)),
    'hashtag': TextRule(style: TextStyle(color: Colors.deepPurple)),
  };

  List<TextSpan> _buildSpans(Iterable<RegExpMatch> matches) {
    final List<TextSpan> spans = [];
    int lastIndex = 0;

    for (final match in matches) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: text.substring(lastIndex, match.start)));
      }

      final matchText = match.group(0)!;
      bool matched = false;

      // Aplicar estilos del mapa
      for (final entry in _styleRules.entries) {
        if (match.namedGroup(entry.key) != null) {
          final rule = entry.value;
          spans.add(TextSpan(
            text: matchText.substring(rule.offset, matchText.length - rule.offset),
            style: rule.style,
          ));
          matched = true;
          break;
        }
      }

      // Casos que no están en el mapa (Links y Escapes)
      if (!matched) {
        if (match.namedGroup('link') != null) {
          spans.add(TextSpan(
            text: matchText,
            style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
            recognizer: TapGestureRecognizer()..onTap = () => launchUrl(Uri.parse(matchText)),
          ));
        } else if (match.namedGroup('escape') != null) {
          spans.add(TextSpan(text: matchText.substring(1)));
        }
      }
      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex)));
    }
    return spans;
  }
}