import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../utils/wcag_luminance.dart';
import 'glass_a11y_scope.dart';
import 'glass_content_aware_scope.dart';
import 'glass_luminance_sampler.dart';

/// A [Text] drop-in that keeps itself readable over a glass surface by
/// sampling the content behind it.
///
/// Behavior is governed by the closest enclosing [GlassA11yScope] (or
/// [GlassA11yMode.auto] if there is none):
///
/// * **auto** — cross-fades between [lightColor] and [darkColor] to track
///   the sampled backdrop, exactly like [GlassContentAwareBrightness] (which
///   this widget is built on).
/// * **warnOnly** — renders a static color resolved from ambient platform
///   brightness, but logs a contrast warning in debug builds when that
///   color fails [GlassA11yScopeData.minimumContrast] against the sampled
///   backdrop. No-op in release builds.
/// * **off** — a static color resolved from ambient platform brightness,
///   with no sampling or registration at all.
///
/// Sampling requires a [GlassContentAwareScope] with a registered
/// [GlassContentAwareContent] — see [GlassLuminanceSampler] for why there is
/// no fallback capture. [GlassA11yScope] installs the scope for you; you
/// still need to mark your actual scrolling content.
///
/// ```dart
/// AdaptiveGlassText(
///   'Settings',
///   lightColor: Colors.black87,
///   darkColor: Colors.white,
///   style: theme.textTheme.titleMedium,
/// )
/// ```
class AdaptiveGlassText extends StatefulWidget {
  /// Creates adaptive glass-aware text.
  const AdaptiveGlassText(
    this.data, {
    required this.lightColor,
    required this.darkColor,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    super.key,
  });

  /// The text to display.
  final String data;

  /// Color used when the sampled backdrop is light (or as the static color
  /// in [GlassA11yMode.warnOnly]/[GlassA11yMode.off] when ambient brightness
  /// is light).
  final Color lightColor;

  /// Color used when the sampled backdrop is dark (or as the static color
  /// in [GlassA11yMode.warnOnly]/[GlassA11yMode.off] when ambient brightness
  /// is dark).
  final Color darkColor;

  /// Passed through to the underlying [Text]; `color` is ignored if set —
  /// use [lightColor]/[darkColor] instead.
  final TextStyle? style;

  /// Passed through to the underlying [Text].
  final TextAlign? textAlign;

  /// Passed through to the underlying [Text].
  final int? maxLines;

  /// Passed through to the underlying [Text].
  final TextOverflow? overflow;

  /// Passed through to the underlying [Text].
  final bool? softWrap;

  @override
  State<AdaptiveGlassText> createState() => _AdaptiveGlassTextState();
}

class _AdaptiveGlassTextState extends State<AdaptiveGlassText> {
  final GlobalKey _key = GlobalKey();
  GlassContentAwareScopeState? _warnScope;
  GlassContentAwareSubscription? _warnSubscription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncWarnRegistration();
  }

  @override
  void didUpdateWidget(AdaptiveGlassText oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncWarnRegistration();
  }

  @override
  void dispose() {
    _warnSubscription?.cancel();
    super.dispose();
  }

  void _syncWarnRegistration() {
    final wantWarn =
        !kReleaseMode && GlassA11yScope.maybeOf(context)?.mode == GlassA11yMode.warnOnly;
    if (!wantWarn) {
      _warnSubscription?.cancel();
      _warnSubscription = null;
      _warnScope = null;
      return;
    }
    final scope = GlassContentAwareScope.maybeOf(context);
    if (scope == _warnScope && _warnSubscription != null) return;
    _warnSubscription?.cancel();
    _warnScope = scope;
    _warnSubscription = scope?.register(
      controlBox: () {
        final ro = _key.currentContext?.findRenderObject();
        return ro is RenderBox ? ro : null;
      },
      onBrightnessChanged: (_) => _checkContrast(),
      initialBrightness: Brightness.light,
    );
  }

  void _checkContrast() {
    assert(() {
      final box = _key.currentContext?.findRenderObject();
      if (box is! RenderBox || !box.attached || !box.hasSize) return true;
      final rect = box.localToGlobal(Offset.zero) & box.size;
      final backdropLuminance =
          GlassLuminanceSampler.sampleLuminance(context, rect);
      if (backdropLuminance == null) return true;

      final color = _resolveStaticColor(context);
      final ratio = wcagContrastRatio(
        wcagLuminanceOfColor(color),
        backdropLuminance,
      );
      final minimumContrast =
          GlassA11yScope.maybeOf(context)?.minimumContrast ?? 4.5;
      if (ratio < minimumContrast) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: FlutterError(
              'AdaptiveGlassText "${widget.data}" has insufficient contrast '
              '(${ratio.toStringAsFixed(2)}:1, needs '
              '${minimumContrast.toStringAsFixed(1)}:1) against its sampled '
              'backdrop. Use GlassA11yMode.auto to flip its color '
              'automatically, or adjust lightColor/darkColor.',
            ),
            library: 'flutter_liquid_glass_widgets',
            context: ErrorDescription('during GlassA11yMode.warnOnly check'),
            silent: true,
          ),
        );
      }
      return true;
    }());
  }

  Color _resolveStaticColor(BuildContext context) {
    final brightness =
        MediaQuery.maybePlatformBrightnessOf(context) ?? Brightness.light;
    return brightness == Brightness.dark ? widget.darkColor : widget.lightColor;
  }

  Widget _buildText(Color color) => Text(
        widget.data,
        style: (widget.style ?? const TextStyle()).copyWith(color: color),
        textAlign: widget.textAlign,
        maxLines: widget.maxLines,
        overflow: widget.overflow,
        softWrap: widget.softWrap,
      );

  @override
  Widget build(BuildContext context) {
    final mode = GlassA11yScope.maybeOf(context)?.mode ?? GlassA11yMode.auto;
    switch (mode) {
      case GlassA11yMode.off:
        return _buildText(_resolveStaticColor(context));
      case GlassA11yMode.warnOnly:
        return KeyedSubtree(
          key: _key,
          child: _buildText(_resolveStaticColor(context)),
        );
      case GlassA11yMode.auto:
        return GlassContentAwareBrightness(
          builder: (context, brightness, darkAmount) {
            final color =
                Color.lerp(widget.lightColor, widget.darkColor, darkAmount)!;
            return _buildText(color);
          },
        );
    }
  }
}
