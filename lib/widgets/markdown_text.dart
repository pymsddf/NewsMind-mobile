import 'package:flutter/material.dart';
import '../theme/intelligence_design_system.dart';

/// Lightweight markdown renderer for AI-generated article bodies.
///
/// Handles the subset the generator actually emits — `#`/`##`/`###` headings,
/// `**bold**`, `*italic*`, `-`/`*` bullets, `1.` numbered items, and `>` quotes
/// — styled in the editorial type system (Fraunces headings, Newsreader body).
/// Anything else renders as a normal paragraph, so it never shows raw `##`.
class MarkdownText extends StatelessWidget {
  final String data;
  final Color? color;

  const MarkdownText(this.data, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final ink = color ?? AppColors.ink;
    final lines = data.replaceAll('\r\n', '\n').split('\n');
    final children = <Widget>[];

    for (final raw in lines) {
      final line = raw.trim();
      if (line.isEmpty) {
        children.add(SizedBox(height: AppSpace.sm));
        continue;
      }
      final h = RegExp(r'^(#{1,6})\s*(.*)$').firstMatch(line);
      if (h != null && h.group(2)!.trim().isNotEmpty) {
        // Lenient: `#`/`##`/`###` heading WITH or WITHOUT a space after the
        // hashes, so malformed markers (e.g. "##Title") still render cleanly.
        final level = h.group(1)!.length;
        final size = level <= 1 ? 23.0 : (level == 2 ? 19.0 : 16.0);
        final weight = level <= 1 ? FontWeight.w800 : FontWeight.w700;
        children.add(_heading(h.group(2)!.trim(), size, ink, weight));
      } else if (line.startsWith('> ')) {
        children.add(_quote(line.substring(2), ink));
      } else if (line.startsWith('- ') || line.startsWith('* ')) {
        children.add(_listItem('•', line.substring(2), ink));
      } else {
        final m = RegExp(r'^(\d+)\.\s+(.*)').firstMatch(line);
        if (m != null) {
          children.add(_listItem('${m.group(1)}.', m.group(2)!, ink));
        } else {
          children.add(_paragraph(line, ink));
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _heading(String text, double size, Color ink, FontWeight weight) {
    return Padding(
      padding: EdgeInsets.only(top: AppSpace.md, bottom: AppSpace.xs),
      child: Text(
        _stripInline(text),
        style: AppType.headline(
            size: size, weight: weight, color: ink, height: 1.25, letterSpacing: -0.3),
      ),
    );
  }

  Widget _paragraph(String text, Color ink) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpace.sm),
      child: Text.rich(
        TextSpan(children: _inline(text, AppType.display(size: 15.5, color: ink, height: 1.6))),
      ),
    );
  }

  Widget _listItem(String marker, String text, Color ink) {
    final base = AppType.display(size: 15.5, color: ink, height: 1.55);
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpace.xs, left: AppSpace.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 22,
            child: Text(marker,
                style: AppType.display(size: 15.5, color: AppColors.graphite, height: 1.55)),
          ),
          Expanded(child: Text.rich(TextSpan(children: _inline(text, base)))),
        ],
      ),
    );
  }

  Widget _quote(String text, Color ink) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpace.sm),
      padding: EdgeInsets.only(left: AppSpace.md),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: AppColors.redline, width: 3)),
      ),
      child: Text.rich(
        TextSpan(
          children: _inline(
            text,
            AppType.display(
                size: 15.5,
                color: AppColors.graphite,
                height: 1.6,
                fontStyle: FontStyle.italic),
          ),
        ),
      ),
    );
  }

  /// Parse `**bold**` and `*italic*` into styled spans.
  List<TextSpan> _inline(String text, TextStyle base) {
    final spans = <TextSpan>[];
    final re = RegExp(r'\*\*(.+?)\*\*|\*(.+?)\*');
    int i = 0;
    for (final m in re.allMatches(text)) {
      if (m.start > i) spans.add(TextSpan(text: text.substring(i, m.start), style: base));
      if (m.group(1) != null) {
        spans.add(TextSpan(text: m.group(1), style: base.copyWith(fontWeight: FontWeight.w700)));
      } else {
        spans.add(TextSpan(text: m.group(2), style: base.copyWith(fontStyle: FontStyle.italic)));
      }
      i = m.end;
    }
    if (i < text.length) spans.add(TextSpan(text: text.substring(i), style: base));
    return spans;
  }

  /// Strip inline markers from heading text (headings aren't re-styled inline).
  String _stripInline(String text) =>
      text.replaceAll('**', '').replaceAll('*', '').trim();
}
