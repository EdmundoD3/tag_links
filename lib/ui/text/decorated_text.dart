import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────────
/// MODELOS
/// ─────────────────────────────────────────────────────────────

class TextRule {
  final TextStyle style;
  final int offset;
  const TextRule({required this.style, this.offset = 0});
}

enum TokenType {
  escape,
  bold,
  italic,
  underline,
  strike,
  code,
  link,
  mention,
  hashtag,
}

/// ─────────────────────────────────────────────────────────────
/// CONFIGURACIÓN (regex + reglas)
/// ─────────────────────────────────────────────────────────────

final RegExp _tokenRegex = RegExp(
  r'(?<escape>\\.)|'
  r'(?<bold>\*\*.*?\*\*)|' //** 
  r'(?<underline>__.*?__)|' //__
  r'(?<italic>_.*?_)|' //_
  r'(?<strike>~.*?~)|' //~
  r'(?<code>`.*?`)|' //`
  r'(?<link>https?:\/\/[^\s]+)|'
  r'(?<mention>@\w+)|'
  r'(?<hashtag>#\w+)',
  unicode: true,
);

const Map<TokenType, TextRule> _styleRules = {
  TokenType.bold: TextRule(
    style: TextStyle(fontWeight: FontWeight.bold),
    offset: 2, // Corregido a 2 por el uso de **
  ),
  TokenType.italic: TextRule(
    style: TextStyle(fontStyle: FontStyle.italic),
    offset: 1,
  ),
  TokenType.underline: TextRule(
    style: TextStyle(decoration: TextDecoration.underline),
    offset: 2,
  ),
  TokenType.strike: TextRule(
    style: TextStyle(decoration: TextDecoration.lineThrough),
    offset: 1,
  ),
  TokenType.code: TextRule(
    style: TextStyle(
      fontFamily: 'monospace',
      backgroundColor: Color(0xFFE0E0E0),
    ),
    offset: 1,
  ),
};

/// ─────────────────────────────────────────────────────────────
/// WIDGET
/// ─────────────────────────────────────────────────────────────

class DecoratedText extends StatelessWidget {
  final String text;
  const DecoratedText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final matches = _tokenRegex.allMatches(text).toList();
    final onlyEmojis = RegExp(
      r'^[\u{1F000}-\u{1FFFF}\u{2600}-\u{27BF}\s]+$',
      unicode: true,
    ).hasMatch(text);

    return RichText(
      text: TextSpan(
        style: TextStyle(
          color: theme.textTheme.bodyMedium?.color,
          fontSize: onlyEmojis ? 32 : 14,
        ),
        children: _buildSpans(context, matches),
      ),
    );
  }

  /// ───────────────────────────────────────────────────────────
  /// PARSER
  /// ───────────────────────────────────────────────────────────

  List<TextSpan> _buildSpans(
    BuildContext context,
    Iterable<RegExpMatch> matches,
  ) {
    final List<TextSpan> spans = [];
    int lastIndex = 0;

    for (final match in matches) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: text.substring(lastIndex, match.start)));
      }

      final matchText = match.group(0)!;
      final type = _resolveType(match);

      if (type == null) {
        spans.add(TextSpan(text: matchText));
        lastIndex = match.end;
        continue;
      }

      switch (type) {
        case TokenType.escape:
          spans.add(TextSpan(text: matchText.substring(1)));
          break;

        case TokenType.link:
          spans.add(
            TextSpan(
              text: matchText.length > 60
                  ? '${matchText.substring(0, 60)}...'
                  : matchText,
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          );
          break;

        case TokenType.mention:
        case TokenType.hashtag:
          spans.add(
            TextSpan(
              text: matchText,
              style: TextStyle(
                color: type == TokenType.mention
                    ? Colors.blueAccent
                    : Colors.deepPurple,
              ),
            ),
          );
          break;

        default:
          if (_styleRules.containsKey(type)) {
            final rule = _styleRules[type];
            if (rule != null) {
              spans.add(
                TextSpan(
                  text: matchText.substring(
                    rule.offset,
                    matchText.length - rule.offset,
                  ),
                  style: DefaultTextStyle.of(context).style.merge(rule.style),
                ),
              );
            }
          }
      }

      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex)));
    }

    return spans;
  }

  TokenType? _resolveType(RegExpMatch match) {
    for (final type in TokenType.values) {
      if (match.namedGroup(type.name) != null) {
        return type;
      }
    }
    return null;
  }
}
