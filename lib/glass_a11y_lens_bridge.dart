/// Optional integration with `package:flutter_a11y_lens`.
///
/// Import this file directly — it is **not** part of the main
/// `package:flutter_liquid_glass_widgets/liquid_glass_widgets.dart` barrel —
/// so apps that don't use `flutter_a11y_lens` aren't forced to think about
/// it. This mirrors how `flutter_a11y_lens` itself separates its own
/// `testing.dart` entry point from its main barrel.
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_a11y_lens/a11y_lens.dart';

import 'liquid_glass_widgets.dart'
    show AdaptiveGlass, LiquidGlassLayer, LightweightLiquidGlass, AdaptiveLiquidGlassLayer;
import 'utils/wcag_luminance.dart';
import 'widgets/shared/glass_luminance_sampler.dart';

/// An [A11yRule] that checks text contrast against the actual sampled
/// backdrop luminance behind glass surfaces, instead of comparing against
/// the nearest solid ancestor color like `flutter_a11y_lens`'s own
/// [ContrastRule].
///
/// A frosted glass surface has no single solid color behind it — it has a
/// blurred, possibly-scrolling composite of whatever content sits
/// underneath — so [ContrastRule] can't see it and either skips glass-backed
/// text entirely (no ancestor paints an opaque color) or, worse, compares
/// against whatever incidental color happens to be the nearest opaque
/// ancestor, which usually isn't the actual backdrop.
///
/// [GlassContrastRule] only evaluates [Text] widgets with a glass ancestor
/// ([AdaptiveGlass], [LiquidGlassLayer], [LightweightLiquidGlass], or
/// [AdaptiveLiquidGlassLayer]) — everything else is left to [ContrastRule].
/// Register both side by side:
///
/// ```dart
/// A11yLensOverlay(
///   rules: const [ContrastRule(), TapTargetSizeRule(), GlassContrastRule()],
///   child: MyApp(),
/// )
/// ```
///
/// Sampling requires a `GlassContentAwareScope` with a registered
/// `GlassContentAwareContent` ancestor (see `GlassLuminanceSampler` for why);
/// text without one is skipped rather than guessed at, same policy as
/// [ContrastRule] skipping text with no solid ancestor.
///
/// **A single one-shot `check()` call can under-report.** The first time
/// this rule sees a piece of glass-backed text, there is no capture to read
/// yet — that first call is what *requests* one (see
/// [GlassLuminanceSampler]), and the text is skipped for that pass rather
/// than flagged. [A11yLensOverlay] calls `check()` continuously, so this
/// self-corrects within a frame or two of nothing else changing. Calling
/// [A11yReport.generate] a single time (e.g. in a `flutter test` assertion)
/// will not — call it once to warm up the capture, settle a frame, then
/// call it again for the real result.
///
/// [AdaptiveGlassText] already manages its own contrast via
/// [GlassA11yMode.auto] — expect occasional false positives from this rule
/// mid cross-fade, since its internal light/dark vote and this rule's direct
/// contrast-ratio check are different (if related) computations.
class GlassContrastRule extends A11yRule {
  /// Creates a glass-aware contrast rule.
  const GlassContrastRule({this.minimumContrast = 4.5});

  /// WCAG contrast ratio required between text and its sampled backdrop.
  /// Defaults to 4.5 — WCAG AA for normal-size text. Use 3.0 for large-scale
  /// text or 7.0 for AAA.
  final double minimumContrast;

  @override
  String get id => 'glass-contrast';

  @override
  String get description =>
      'Text over a glass surface must have sufficient contrast against the '
      'actual (sampled) content behind it, not a static ancestor color.';

  @override
  List<A11yViolation> check(List<A11yElementInfo> elements) {
    final violations = <A11yViolation>[];

    for (final info in elements) {
      final widget = info.widget;
      if (widget is! Text) continue;
      if (!info.element.mounted) continue;
      final bounds = info.bounds;
      if (bounds == null) continue;
      if (!_hasGlassAncestor(info.element)) continue;

      final style = _resolveStyle(info.element, widget);
      final foreground = style.color;
      if (foreground == null || foreground.a <= 0.0) continue;

      final backdropLuminance =
          GlassLuminanceSampler.sampleLuminance(info.element, bounds);
      if (backdropLuminance == null) continue;

      final ratio = wcagContrastRatio(
        wcagLuminanceOfColor(foreground),
        backdropLuminance,
      );
      if (ratio >= minimumContrast) continue;

      violations.add(
        A11yViolation(
          ruleId: id,
          severity: A11ySeverity.error,
          widgetType: info.widgetType.toString(),
          bounds: bounds,
          message:
              'Text contrast ratio ${ratio.toStringAsFixed(2)}:1 is below the '
              '${minimumContrast.toStringAsFixed(1)}:1 minimum against the '
              'sampled glass backdrop.',
          suggestedFix:
              'Wrap this text in AdaptiveGlassText so its color flips '
              'automatically, or choose a color with sufficient contrast '
              'against the actual content behind the glass.',
        ),
      );
    }

    return violations;
  }

  TextStyle _resolveStyle(BuildContext context, Text widget) {
    final defaultStyle = DefaultTextStyle.of(context).style;
    return widget.style == null
        ? defaultStyle
        : defaultStyle.merge(widget.style);
  }

  bool _hasGlassAncestor(Element element) {
    var found = false;
    element.visitAncestorElements((ancestor) {
      final widget = ancestor.widget;
      if (widget is AdaptiveGlass ||
          widget is LiquidGlassLayer ||
          widget is LightweightLiquidGlass ||
          widget is AdaptiveLiquidGlassLayer) {
        found = true;
        return false;
      }
      return true;
    });
    return found;
  }
}
