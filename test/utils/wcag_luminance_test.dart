import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_liquid_glass_widgets/utils/wcag_luminance.dart';

void main() {
  group('wcagLuminance', () {
    test('black is 0.0', () {
      expect(wcagLuminance(0, 0, 0), 0.0);
    });

    test('white is 1.0', () {
      expect(wcagLuminance(1, 1, 1), closeTo(1.0, 1e-9));
    });

    test('matches the known WCAG mid-gray crossover', () {
      // #808080 has WCAG relative luminance ≈ 0.2158.
      final luma = wcagLuminance(0x80 / 255, 0x80 / 255, 0x80 / 255);
      expect(luma, closeTo(0.2158, 0.001));
    });
  });

  group('wcagLuminanceOfColor', () {
    test('matches wcagLuminance on the same channels', () {
      const color = Color(0xFF3399CC);
      expect(
        wcagLuminanceOfColor(color),
        wcagLuminance(color.r, color.g, color.b),
      );
    });
  });

  group('wcagContrastRatio', () {
    test('black vs white is the maximum ratio, 21:1', () {
      expect(wcagContrastRatio(0.0, 1.0), closeTo(21.0, 0.01));
    });

    test('a luminance against itself is 1:1', () {
      expect(wcagContrastRatio(0.5, 0.5), closeTo(1.0, 1e-9));
    });

    test('order of arguments does not matter', () {
      expect(wcagContrastRatio(0.2, 0.8), wcagContrastRatio(0.8, 0.2));
    });
  });

  group('averageLuminanceOfRegion', () {
    Uint8List solidImage(int width, int height, int r, int g, int b, int a) {
      final bytes = Uint8List(width * height * 4);
      for (var i = 0; i < width * height; i++) {
        bytes[i * 4] = r;
        bytes[i * 4 + 1] = g;
        bytes[i * 4 + 2] = b;
        bytes[i * 4 + 3] = a;
      }
      return bytes;
    }

    test('averages an opaque solid-color region to that color\'s luminance',
        () {
      final rgba = solidImage(4, 4, 0, 0, 0, 255);
      final luma = averageLuminanceOfRegion(
        rgba: rgba,
        width: 4,
        height: 4,
        pixelRect: const Rect.fromLTWH(0, 0, 4, 4),
        background: const Color(0xFFFFFFFF),
      );
      expect(luma, closeTo(0.0, 1e-9));
    });

    test('substitutes background for fully transparent pixels', () {
      final rgba = solidImage(2, 2, 0, 0, 0, 0); // fully transparent
      final luma = averageLuminanceOfRegion(
        rgba: rgba,
        width: 2,
        height: 2,
        pixelRect: const Rect.fromLTWH(0, 0, 2, 2),
        background: const Color(0xFFFFFFFF),
      );
      expect(luma, closeTo(1.0, 1e-9));
    });

    test('returns null for a degenerate image', () {
      expect(
        averageLuminanceOfRegion(
          rgba: Uint8List(0),
          width: 0,
          height: 0,
          pixelRect: const Rect.fromLTWH(0, 0, 1, 1),
          background: const Color(0xFFFFFFFF),
        ),
        isNull,
      );
    });

    test('clamps a rect extending outside the image bounds', () {
      final rgba = solidImage(2, 2, 10, 20, 30, 255);
      final luma = averageLuminanceOfRegion(
        rgba: rgba,
        width: 2,
        height: 2,
        pixelRect: const Rect.fromLTWH(-5, -5, 20, 20),
        background: const Color(0xFFFFFFFF),
      );
      expect(luma, closeTo(wcagLuminance(10 / 255, 20 / 255, 30 / 255), 1e-9));
    });
  });
}
