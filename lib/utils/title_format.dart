/// Reduce a possibly-markdown string to a clean single-line title: the first
/// non-empty line with heading (`##`), list, and emphasis (`*_\``) markers
/// stripped. Used so a title that was stored as raw markdown (e.g. from history)
/// doesn't render as literal "## … ### I".
String cleanTitle(String? s) {
  if (s == null) return '';
  final line = s
      .split('\n')
      .map((l) => l.trim())
      .firstWhere((l) => l.isNotEmpty, orElse: () => '');
  return line
      .replaceAll(RegExp(r'^#{1,6}\s*'), '')
      .replaceAll(RegExp(r'^[-*]\s+'), '')
      .replaceAll(RegExp(r'[*_`]'), '')
      .trim();
}

/// Flatten markdown into a one-line plain-text excerpt (for previews): strips
/// heading/bullet markers and emphasis, collapses whitespace. Keeps the full
/// text, unlike [cleanTitle] which keeps only the first line.
String stripMarkdown(String? s) {
  if (s == null) return '';
  return s
      .replaceAll(RegExp(r'#{1,6}\s*'), '')
      .replaceAll(RegExp(r'(^|\n)\s*[-*]\s+'), ' ')
      .replaceAll(RegExp(r'[*_`>]'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
