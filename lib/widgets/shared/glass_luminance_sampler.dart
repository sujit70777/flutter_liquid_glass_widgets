import 'package:flutter/widgets.dart';

import 'glass_content_aware_scope.dart';

/// Reads the backdrop luminance behind glass surfaces.
///
/// This is the low-level primitive behind [AdaptiveGlassText] and
/// `GlassContrastRule` (see `package:flutter_liquid_glass_widgets/glass_a11y_lens_bridge.dart`):
/// anything that needs to know how bright the content behind a glass surface
/// is — to pick a readable text color, or to audit an existing one — goes
/// through here.
///
/// Sampling piggybacks on [GlassContentAwareScope]'s existing scroll-debounced
/// backdrop capture rather than performing a second one: wrap the region
/// behind your glass surfaces in [GlassContentAwareScope] +
/// [GlassContentAwareContent] (or use `GlassScaffold(contentAwareBrightness:
/// true)`, which does this automatically), and [sampleLuminance] reads
/// whatever that scope last captured.
///
/// There is deliberately no fallback capture path for screens without a
/// [GlassContentAwareScope] — that scope is what defines "the content behind
/// the glass" in the first place, so without one there is nothing correct to
/// sample. In that case [sampleLuminance] returns null and callers should
/// fall back to ambient brightness.
abstract final class GlassLuminanceSampler {
  /// Average WCAG relative luminance (0.0 dark – 1.0 light) of the content
  /// behind [rect] (in global/screen coordinates).
  ///
  /// Returns null when there is no enclosing [GlassContentAwareScope], no
  /// [GlassContentAwareContent] registered with it, or no capture has
  /// completed yet (the first frame or two after the scope mounts).
  static double? sampleLuminance(BuildContext context, Rect rect) {
    return GlassContentAwareScope.maybeOf(context)?.luminanceAt(rect);
  }
}
