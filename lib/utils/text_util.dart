/// Strips markdown formatting from the given text.
/// Optionally preserves newlines if `preserveNewlines` is true.
String stripMarkdown(String markdownText, {bool preserveNewlines = false}) {
  String text = markdownText
      .replaceAll(RegExp(r'\*\*|__'), '')
      .replaceAll(RegExp(r'_'), '')
      .replaceAll(RegExp(r'#+ '), '')
      .replaceAll(RegExp(r'\[.*?\]\(.*?\)'), '')
      .replaceAll(RegExp(r'`'), '');
  if (!preserveNewlines) {
    text = text.replaceAll(RegExp(r'\n'), ' ');
  }
  return text.trim();
}

/// Preprocesses text for Text-to-Speech (TTS) by removing markdown formatting,
/// handling headings, and ensuring proper punctuation.
List<String> preprocessForTTS(String text) {
  final lines = text.split('\n');
  final processed = <String>[];
  for (var line in lines) {
    String l = line.trim();
    if (l.isEmpty) {
      processed.add('');
      continue;
    }
    l = l.replaceAllMapped(RegExp(r'^#+\s*(.*)'), (m) => '${m[1]}');
    l = l.replaceAll(RegExp(r'\*\*|\*|__|_'), '');
    l = l.replaceAllMapped(RegExp(r'^[\*\-]\s*'), (m) => 'Next ingredient: ');
    l = l.replaceAll('(', ', (');
    l = l.replaceAll(')', '), ');
    if (!l.endsWith('.') && !l.endsWith('!') && !l.endsWith('?')) {
      l = '$l.';
    }
    processed.add(l);
  }
  return processed;
}