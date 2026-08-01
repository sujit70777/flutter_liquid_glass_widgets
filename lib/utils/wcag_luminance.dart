// Package-private WCAG luminance/contrast math, shared by every feature that
// reads a captured RGBA backdrop (GlassContentAwareScope, GlassLuminanceSampler).
//
// NOT part of the public API — do not export from liquid_glass_widgets.dart.
library;

import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show Color, Rect;

/// WCAG 2.x relative luminance from non-linear sRGB channels in `[0, 1]`.
double wcagLuminance(double r, double g, double b) {
  double linearize(double channel) => channel <= 0.03928
      ? channel / 12.92
      : math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * linearize(r) + 0.7152 * linearize(g) + 0.0722 * linearize(b);
}

/// The WCAG relative luminance of an opaque [color] (alpha is ignored —
/// composite over its background first if it isn't already opaque).
double wcagLuminanceOfColor(Color color) =>
    wcagLuminance(color.r, color.g, color.b);

/// The WCAG contrast ratio between two relative luminances, in `[1, 21]`.
/// Order of arguments does not matter.
double wcagContrastRatio(double luminanceA, double luminanceB) {
  final hi = luminanceA > luminanceB ? luminanceA : luminanceB;
  final lo = luminanceA > luminanceB ? luminanceB : luminanceA;
  return (hi + 0.05) / (lo + 0.05);
}

/// Average WCAG relative luminance of [rgba] (a `rawRgba`-format image
/// buffer, [width]×[height]) within [pixelRect] (in pixel coordinates of
/// that buffer). Fully transparent pixels (alpha < 0.02) are evaluated as
/// [background] instead of their own (meaningless) color, mirroring how a
/// viewer would actually perceive them. Returns null if [pixelRect] doesn't
/// cover any pixel.
double? averageLuminanceOfRegion({
  required Uint8List rgba,
  required int width,
  required int height,
  required Rect pixelRect,
  required Color background,
}) {
  if (width <= 0 || height <= 0) return null;
  final x0 = pixelRect.left.floor().clamp(0, width - 1);
  final x1 = pixelRect.right.ceil().clamp(x0 + 1, width);
  final y0 = pixelRect.top.floor().clamp(0, height - 1);
  final y1 = pixelRect.bottom.ceil().clamp(y0 + 1, height);

  var sumR = 0.0, sumG = 0.0, sumB = 0.0;
  var n = 0;
  for (var y = y0; y < y1; y++) {
    for (var x = x0; x < x1; x++) {
      final i = (y * width + x) * 4;
      final a = rgba[i + 3] / 255.0;
      if (a < 0.02) {
        sumR += background.r;
        sumG += background.g;
        sumB += background.b;
      } else {
        sumR += rgba[i] / 255.0;
        sumG += rgba[i + 1] / 255.0;
        sumB += rgba[i + 2] / 255.0;
      }
      n++;
    }
  }
  if (n == 0) return null;
  return wcagLuminance(sumR / n, sumG / n, sumB / n);
}
