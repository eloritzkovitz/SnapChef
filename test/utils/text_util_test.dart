import 'package:flutter_test/flutter_test.dart';
import 'package:snapchef/utils/text_util.dart';

void main() {
  group('stripMarkdown', () {
    test('removes bold, italics, headings, links, and code', () {
      final input = '**Bold** _Italic_ __Underline__ # Heading [Link](url) `code`';
      final output = stripMarkdown(input);
      expect(output, 'Bold Italic Underline Heading  code');
    });

    test('removes markdown and preserves newlines if requested', () {
      final input = '**Bold**\n# Heading\nLine';
      final output = stripMarkdown(input, preserveNewlines: true);
      expect(output, 'Bold\nHeading\nLine');
    });

    test('removes markdown and replaces newlines with spaces by default', () {
      final input = '**Bold**\n# Heading\nLine';
      final output = stripMarkdown(input);
      expect(output, 'Bold Heading Line');
    });

    test('trims whitespace', () {
      final input = '   **Bold**   ';
      final output = stripMarkdown(input);
      expect(output, 'Bold');
    });

    test('empty string returns empty', () {
      expect(stripMarkdown(''), '');
    });
  });

  group('preprocessForTTS', () {
    test('splits lines and removes markdown', () {
      final input = '''
# Heading
**Bold**
* List item
- Another item
Normal line
''';
      final output = preprocessForTTS(input);
      expect(output, [
        'Heading.',
        'Bold.',
        ' List item.',
        'Next ingredient: Another item.',
        'Normal line.',
        ''
      ]);
    });

    test('handles empty lines', () {
      final input = '\n\n';
      final output = preprocessForTTS(input);
      expect(output, ['', '', '']);
    });

    test('adds punctuation if missing', () {
      final input = 'No punctuation';
      final output = preprocessForTTS(input);
      expect(output, ['No punctuation.']);
    });

    test('keeps punctuation if present', () {
      final input = 'Hello!';
      final output = preprocessForTTS(input);
      expect(output, ['Hello!']);
    });

    test('handles parenthesis', () {
      final input = 'Ingredient (optional)';
      final output = preprocessForTTS(input);
      expect(output, ['Ingredient , (optional), .']);
    });

    test('removes multiple markdown styles', () {
      final input = '# Heading\n**Bold**\n__Underline__\n* List';
      final output = preprocessForTTS(input);
      expect(output, [
        'Heading.',
        'Bold.',
        'Underline.',
        ' List.',
      ]);
    });

    test('handles only markdown symbols', () {
      final input = '**__**';
      final output = preprocessForTTS(input);
      expect(output, ['.']);
    });
  });
}