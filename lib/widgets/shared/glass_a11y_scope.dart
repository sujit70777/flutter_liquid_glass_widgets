import 'package:flutter/widgets.dart';

import 'glass_content_aware_scope.dart';

/// How [AdaptiveGlassText] (and other glass-aware text widgets) behave
/// inside a [GlassA11yScope].
enum GlassA11yMode {
  /// Automatically flip between the light/dark color variant to keep
  /// contrast against the sampled backdrop.
  auto,

  /// Keep the authored color, but log a contrast warning in debug builds
  /// when it fails against the sampled backdrop. No behavior change in
  /// release builds.
  warnOnly,

  /// No sampling, no registration, no diagnostics — a plain, static text
  /// color resolved once from ambient platform brightness.
  off,
}

/// Configures how glass-aware text widgets in [child] handle contrast
/// against the content behind glass surfaces.
///
/// Frosted glass reduces contrast between foreground text and whatever is
/// behind it — and unlike a solid background, that backdrop is a blurred,
/// possibly-scrolling composite, so a static contrast checker comparing
/// against the nearest solid ancestor color can't see the real picture.
/// [AdaptiveGlassText] and `GlassContrastRule` (see
/// `package:flutter_liquid_glass_widgets/glass_a11y_lens_bridge.dart`) close
/// that gap by sampling the actual backdrop via [GlassLuminanceSampler].
///
/// Wrap your app (or a subtree) in this scope to control that behavior:
///
/// ```dart
/// GlassA11yScope(
///   mode: GlassA11yMode.auto,
///   child: MyApp(),
/// )
/// ```
///
/// [GlassA11yScope] does not, by itself, mark *what* content is behind your
/// glass surfaces — it installs a [GlassContentAwareScope] for convenience,
/// but sampling only produces real data once you mark the actual scrolling
/// content with [GlassContentAwareContent] (or use
/// `GlassScaffold(contentAwareBrightness: true)`, which does this for you).
/// Without a marked content region, glass-aware text falls back to ambient
/// platform brightness — never a guess, never a crash.
///
/// [minimumContrast] is the WCAG contrast ratio (foreground vs. sampled
/// backdrop) glass-aware text is held to; defaults to 4.5, WCAG AA for
/// normal-size text.
class GlassA11yScope extends StatelessWidget {
  /// Creates a scope controlling glass-aware text contrast behavior.
  const GlassA11yScope({
    this.mode = GlassA11yMode.auto,
    this.minimumContrast = 4.5,
    required this.child,
    super.key,
  });

  /// How glass-aware text widgets in [child] behave. Defaults to [GlassA11yMode.auto].
  final GlassA11yMode mode;

  /// WCAG contrast ratio glass-aware text is held to. Defaults to 4.5 (WCAG
  /// AA, normal-size text); use 3.0 for large-scale text or 7.0 for AAA.
  final double minimumContrast;

  /// The subtree this scope governs.
  final Widget child;

  /// The [GlassA11yScopeData] from the closest enclosing scope, or null if
  /// there is none — callers should treat a null scope as [GlassA11yMode.auto]
  /// with the default 4.5 minimum contrast, since that's the behavior
  /// [AdaptiveGlassText] has with no [GlassA11yScope] ancestor at all.
  static GlassA11yScopeData? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_GlassA11yScopeMarker>()
        ?.data;
  }

  @override
  Widget build(BuildContext context) {
    return _GlassA11yScopeMarker(
      data: GlassA11yScopeData(mode: mode, minimumContrast: minimumContrast),
      child: GlassContentAwareScope(child: child),
    );
  }
}

/// The resolved configuration exposed by a [GlassA11yScope].
@immutable
class GlassA11yScopeData {
  /// Creates scope data.
  const GlassA11yScopeData({required this.mode, required this.minimumContrast});

  /// How glass-aware text widgets behave.
  final GlassA11yMode mode;

  /// WCAG contrast ratio glass-aware text is held to.
  final double minimumContrast;

  @override
  bool operator ==(Object other) =>
      other is GlassA11yScopeData &&
      other.mode == mode &&
      other.minimumContrast == minimumContrast;

  @override
  int get hashCode => Object.hash(mode, minimumContrast);
}

class _GlassA11yScopeMarker extends InheritedWidget {
  const _GlassA11yScopeMarker({required this.data, required super.child});

  final GlassA11yScopeData data;

  @override
  bool updateShouldNotify(_GlassA11yScopeMarker oldWidget) =>
      data != oldWidget.data;
}
