import 'package:flutter/cupertino.dart';

/// A shimmering placeholder block for loading states, in the glass aesthetic.
///
/// A translucent glass-tinted panel with a soft highlight band that sweeps
/// across it continuously. Use the named constructors for common shapes, or
/// the default constructor for a custom rectangle:
///
/// ```dart
/// // A block of placeholder text lines
/// Column(
///   children: [
///     GlassSkeletonLoader.text(width: 200),
///     const SizedBox(height: 8),
///     GlassSkeletonLoader.text(width: 140),
///   ],
/// )
///
/// // A placeholder avatar
/// GlassSkeletonLoader.circle(diameter: 48)
///
/// // A custom placeholder card
/// GlassSkeletonLoader(width: double.infinity, height: 120, borderRadius: 16)
/// ```
class GlassSkeletonLoader extends StatefulWidget {
  /// Creates a rectangular skeleton placeholder.
  const GlassSkeletonLoader({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 8,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1400),
  }) : _shape = BoxShape.rectangle;

  /// Creates a single placeholder text line — a short, fully-rounded bar.
  const GlassSkeletonLoader.text({
    super.key,
    this.width,
    this.height = 14,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1400),
  })  : borderRadius = height / 2,
        _shape = BoxShape.rectangle;

  /// Creates a circular placeholder (e.g. for an avatar).
  const GlassSkeletonLoader.circle({
    super.key,
    required double diameter,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1400),
  })  : width = diameter,
        height = diameter,
        borderRadius = diameter / 2,
        _shape = BoxShape.circle;

  /// Width of the placeholder. Null fills the available width.
  final double? width;

  /// Height of the placeholder.
  final double height;

  /// Corner radius (ignored for [GlassSkeletonLoader.circle]).
  final double borderRadius;

  /// Base fill color. Defaults to a theme-aware translucent grey.
  final Color? baseColor;

  /// Color of the sweeping highlight band. Defaults to a lighter translucent
  /// grey/white, adapting to light/dark mode.
  final Color? highlightColor;

  /// Duration of one full sweep of the highlight band.
  final Duration duration;

  final BoxShape _shape;

  @override
  State<GlassSkeletonLoader> createState() => _GlassSkeletonLoaderState();
}

class _GlassSkeletonLoaderState extends State<GlassSkeletonLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void didUpdateWidget(GlassSkeletonLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    final base = widget.baseColor ??
        (isDark
            ? CupertinoColors.white.withValues(alpha: 0.08)
            : CupertinoColors.black.withValues(alpha: 0.06));
    final highlight = widget.highlightColor ??
        (isDark
            ? CupertinoColors.white.withValues(alpha: 0.18)
            : CupertinoColors.white.withValues(alpha: 0.7));

    return ClipPath(
      clipper: widget._shape == BoxShape.circle
          ? _CircleClipper()
          : _RRectClipper(widget.borderRadius),
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: base),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                // Sweep from -1.5..1.5 so the band fully enters and exits.
                final t = _controller.value * 3.0 - 1.5;
                return Align(
                  alignment: Alignment(t, 0),
                  child: FractionallySizedBox(
                    widthFactor: 0.5,
                    heightFactor: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            base.withValues(alpha: 0),
                            highlight,
                            base.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RRectClipper extends CustomClipper<Path> {
  _RRectClipper(this.radius);
  final double radius;

  @override
  Path getClip(Size size) => Path()
    ..addRRect(RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    ));

  @override
  bool shouldReclip(covariant _RRectClipper oldClipper) =>
      oldClipper.radius != radius;
}

class _CircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => Path()..addOval(Offset.zero & size);

  @override
  bool shouldReclip(covariant _CircleClipper oldClipper) => false;
}
