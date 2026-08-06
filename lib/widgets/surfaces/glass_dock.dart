import 'dart:math' as math;

import 'package:flutter/cupertino.dart';

import '../../src/renderer/liquid_glass_renderer.dart';
import '../../types/glass_quality.dart';
import '../containers/glass_card.dart';
import '../interactive/glass_icon_button.dart';
import '../shared/adaptive_liquid_glass_layer.dart';

/// A single icon registered with a [GlassDock].
class GlassDockItem {
  /// Creates a dock item.
  const GlassDockItem({
    required this.icon,
    required this.onTap,
    this.label,
  });

  /// The icon content.
  final Widget icon;

  /// Called when the item is tapped.
  final VoidCallback onTap;

  /// Optional accessibility label announced by screen readers.
  final String? label;
}

/// A macOS-style Dock: a row of glass-backed icons that magnify smoothly as
/// the cursor approaches, with a continuous falloff across neighboring icons
/// — matching Apple's dock magnification, not a simple per-icon hover-scale.
///
/// ```dart
/// GlassDock(
///   items: [
///     GlassDockItem(icon: const Icon(CupertinoIcons.mail), onTap: openMail),
///     GlassDockItem(icon: const Icon(CupertinoIcons.calendar), onTap: openCal),
///   ],
/// )
/// ```
///
/// Magnification is driven by [MouseRegion.onHover], so it only ever
/// activates for a mouse/trackpad pointer — touch input never produces hover
/// events in Flutter, so the dock renders at [baseSize] with no magnification
/// on touch-only platforms automatically, no platform detection needed.
///
/// Each icon's magnification is a Gaussian falloff of its distance from the
/// pointer, evaluated against the item's **resting** (unmagnified) position
/// rather than its current, possibly-already-magnified position — the
/// standard way to avoid feedback oscillation in this kind of effect. The
/// falloff width is [magnificationRadius]; distances much larger than it get
/// essentially no magnification, distances near 0 approach [maxScale].
class GlassDock extends StatefulWidget {
  /// Creates a glass dock.
  const GlassDock({
    super.key,
    required this.items,
    this.baseSize = 56,
    this.maxScale = 1.7,
    this.magnificationRadius = 80,
    this.spacing = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    this.borderRadius = 28,
    this.settings,
    this.quality,
  }) : assert(maxScale >= 1.0, 'maxScale must be at least 1.0');

  /// The dock's icons, left to right.
  final List<GlassDockItem> items;

  /// Size (width and height) of an unmagnified icon tile.
  final double baseSize;

  /// Scale factor applied to the icon directly under the pointer.
  ///
  /// Defaults to 1.7 — noticeably larger without overwhelming neighbors.
  final double maxScale;

  /// Falloff width, in logical pixels, of the magnification Gaussian.
  ///
  /// Roughly: an icon this far from the pointer's nearest icon is magnified
  /// to about 60% of [maxScale]'s boost; by ~2x this distance, magnification
  /// is negligible. Larger values spread the bulge across more neighbors.
  final double magnificationRadius;

  /// Horizontal gap between resting (unmagnified) icon tiles.
  final double spacing;

  /// Padding around the row of icons, inside the glass shelf.
  final EdgeInsets padding;

  /// Corner radius of the glass shelf.
  final double borderRadius;

  /// Custom glass settings for the dock shelf.
  final LiquidGlassSettings? settings;

  /// Rendering quality for the glass effect.
  final GlassQuality? quality;

  @override
  State<GlassDock> createState() => _GlassDockState();
}

class _GlassDockState extends State<GlassDock> {
  double? _hoverX;

  double _restingCenter(int index) =>
      index * (widget.baseSize + widget.spacing) + widget.baseSize / 2;

  double _scaleFor(int index) {
    final hoverX = _hoverX;
    if (hoverX == null) return 1.0;
    final distance = (hoverX - _restingCenter(index)).abs();
    final sigma = widget.magnificationRadius;
    if (sigma <= 0) return 1.0;
    final falloff = math.exp(-(distance * distance) / (2 * sigma * sigma));
    return 1.0 + (widget.maxScale - 1.0) * falloff;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveSettings = widget.settings ?? const LiquidGlassSettings();
    return MouseRegion(
      onHover: (event) => setState(() => _hoverX = event.localPosition.dx),
      onExit: (_) => setState(() => _hoverX = null),
      child: GlassCard(
        useOwnLayer: true,
        settings: widget.settings,
        quality: widget.quality,
        padding: widget.padding,
        shape: LiquidRoundedSuperellipse(borderRadius: widget.borderRadius),
        child: AdaptiveLiquidGlassLayer(
          settings: effectiveSettings,
          quality: widget.quality,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < widget.items.length; i++) ...[
                if (i > 0) SizedBox(width: widget.spacing),
                _GlassDockTile(
                  item: widget.items[i],
                  size: widget.baseSize * _scaleFor(i),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassDockTile extends StatelessWidget {
  const _GlassDockTile({required this.item, required this.size});

  final GlassDockItem item;
  final double size;

  @override
  Widget build(BuildContext context) {
    final button = AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOutCubic,
      width: size,
      height: size,
      alignment: Alignment.bottomCenter,
      child: GlassIconButton(
        icon: item.icon,
        onPressed: item.onTap,
        size: size,
        shape: GlassIconButtonShape.roundedSquare,
      ),
    );
    if (item.label == null) return button;
    return Semantics(label: item.label, child: button);
  }
}
