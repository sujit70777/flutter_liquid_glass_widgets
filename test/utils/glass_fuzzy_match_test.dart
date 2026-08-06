import 'package:flutter_liquid_glass_widgets/utils/glass_fuzzy_match.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('glassFuzzyScore', () {
    test('empty query matches everything with score 0', () {
      expect(glassFuzzyScore('', 'New File'), 0);
      expect(glassFuzzyScore('', ''), 0);
    });

    test('empty target never matches a non-empty query', () {
      expect(glassFuzzyScore('a', ''), isNull);
    });

    test('non-subsequence returns null', () {
      expect(glassFuzzyScore('xyz', 'New File'), isNull);
      expect(glassFuzzyScore('fn', 'New File'), isNull); // wrong order
    });

    test('subsequence match (possibly scattered) returns a score', () {
      expect(glassFuzzyScore('nf', 'New File'), isNotNull);
      expect(glassFuzzyScore('newfile', 'New File'), isNotNull);
    });

    test('is case-insensitive', () {
      expect(glassFuzzyScore('NEW', 'new file'), isNotNull);
      expect(glassFuzzyScore('new', 'NEW FILE'), isNotNull);
    });

    test('contiguous prefix match scores higher than scattered match', () {
      final prefix = glassFuzzyScore('new', 'New File')!;
      final scattered = glassFuzzyScore('nfl', 'New File')!;
      expect(prefix, greaterThan(scattered));
    });

    test('word-boundary match scores higher than mid-word match', () {
      // 'f' matches at a word boundary in "New File" (after the space) vs.
      // mid-word in "Reference".
      final boundary = glassFuzzyScore('f', 'New File')!;
      final midWord = glassFuzzyScore('f', 'Reference')!;
      expect(boundary, greaterThan(midWord));
    });

    test('shorter target ranks higher among otherwise-equal matches', () {
      final short = glassFuzzyScore('ok', 'ok')!;
      final long = glassFuzzyScore('ok', 'ok, sure thing')!;
      expect(short, greaterThan(long));
    });
  });
}
