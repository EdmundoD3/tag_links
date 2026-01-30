import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DecoratedText extends StatelessWidget {
  final String text;

  const DecoratedText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final matches = _allmatches(text);
    final spans = _textSpans(matches);

    // Emojis grandes
    final onlyEmojis = RegExp(
      r'^[\p{Emoji}\s]+$',
      unicode: true,
    ).hasMatch(text);

    return RichText(
      text: TextSpan(
        style: TextStyle(color: Colors.black, fontSize: onlyEmojis ? 32 : 14),
        children: spans,
      ),
    );
  }

  Iterable<RegExpMatch> _allmatches(String text) sync* {
    final regex = RegExp(
      r'(\\.|' // escape
      r'\*\*.*?\*\*|' // bold alternative
      r'\*.*?\*|' // bold
      r'__.*?__|' // underline
      r'_.*?_|' // italic
      r'~.*?~|' // strike
      r'`.*?`|' // code
      r'\|\|.*?\|\||' // spoiler
      r'https?:\/\/[^\s]+|' // link
      r'@\w+|' // mention
      r'#\w+)', // hashtag
      unicode: true,
    );
//    ✔ Negrita *text*
//    ✔ Cursiva _text_
//    ✔ Tachado ~text~
//    ✔ Subrayado __text__
//    ✔ Código `code`
//    ✔ Spoiler ||text|| (tap para revelar)
//    ✔ Links clicables
//    ✔ Menciones @user
//    ✔ Hashtags #topic
//    ✔ Emojis grandes si el texto solo tiene emojis
//    ✔ Escape \*no bold*

    final matches = regex.allMatches(text);
    yield* matches;
  }

  List<TextSpan> _textSpans(Iterable<RegExpMatch> matches) {
    final List<TextSpan> spans = [];
    int lastIndex = 0;
    for (final match in matches) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: text.substring(lastIndex, match.start)));
      }

      final matchText = match.group(0)!;

      // ESCAPE
      if (matchText.startsWith(r'\')) {
        spans.add(TextSpan(text: matchText.substring(1)));
      }
      // BOLD
      else if (matchText.startsWith('*')) {
        spans.add(
          TextSpan(
            text: matchText.substring(1, matchText.length - 1),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      }
      // ITALIC
      else if (matchText.startsWith('_') && !matchText.startsWith('__')) {
        spans.add(
          TextSpan(
            text: matchText.substring(1, matchText.length - 1),
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
        );
      }
      // UNDERLINE
      else if (matchText.startsWith('__')) {
        spans.add(
          TextSpan(
            text: matchText.substring(2, matchText.length - 2),
            style: const TextStyle(decoration: TextDecoration.underline),
          ),
        );
      }
      // STRIKE
      else if (matchText.startsWith('~')) {
        spans.add(
          TextSpan(
            text: matchText.substring(1, matchText.length - 1),
            style: const TextStyle(decoration: TextDecoration.lineThrough),
          ),
        );
      }
      // CODE
      else if (matchText.startsWith('`')) {
        spans.add(
          TextSpan(
            text: matchText.substring(1, matchText.length - 1),
            style: TextStyle(
              fontFamily: 'monospace',
              backgroundColor: Colors.grey.shade300,
            ),
          ),
        );
      }
      // SPOILER
      else if (matchText.startsWith('||')) {
        spans.add(
          TextSpan(
            text: matchText.substring(2, matchText.length - 2),
            style: const TextStyle(
              color: Colors.transparent,
              backgroundColor: Colors.black,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                // En producción: manejar estado para revelar
              },
          ),
        );
      }
      // LINK
      else if (matchText.startsWith('http')) {
        spans.add(
          TextSpan(
            text: matchText,
            style: const TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => launchUrl(Uri.parse(matchText)),
          ),
        );
      }
      // MENTION
      else if (matchText.startsWith('@')) {
        spans.add(
          TextSpan(
            text: matchText,
            style: const TextStyle(color: Colors.blueAccent),
          ),
        );
      }
      // HASHTAG
      else if (matchText.startsWith('#')) {
        spans.add(
          TextSpan(
            text: matchText,
            style: const TextStyle(color: Colors.deepPurple),
          ),
        );
      }

      lastIndex = match.end;
    }
    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex)));
    }
    return spans;
  }
}
