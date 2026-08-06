import 'package:flutter/cupertino.dart';

import '../../theme/glass_theme_data.dart';

/// An interactive (or read-only) star rating row.
///
/// Tap or drag across the stars to set [value]; supports fractional
/// (half-star) ratings via [allowHalfRating].
///
/// ```dart
/// double rating = 3.5;
///
/// GlassRatingBar(
///   value: rating,
///   allowHalfRating: true,
///   onChanged: (v) => setState(() => rating = v),
/// )
///
/// // Read-only display
/// GlassRatingBar(value: 4, onChanged: null)
/// ```
class GlassRatingBar extends StatefulWidget {
  /// Creates a star rating row.
  const GlassRatingBar({
    super.key,
    required this.value,
    this.onChanged,
    this.itemCount = 5,
    this.itemSize = 28,
    this.spacing = 4,
    this.color,
    this.unratedColor,
    this.allowHalfRating = false,
    this.filledIcon = CupertinoIcons.star_fill,
    this.halfIcon = CupertinoIcons.star_lefthalf_fill,
    this.emptyIcon = CupertinoIcons.star,
  })  : assert(itemCount > 0, 'itemCount must be positive'),
        assert(value >= 0, 'value must not be negative');

  /// The current rating, in `[0, itemCount]`.
  final double value;

  /// Called with the new rating when the user taps or drags. When null, the
  /// bar is read-only (still fully accessible via [Semantics]).
  final ValueChanged<double>? onChanged;

  /// Number of stars.
  final int itemCount;

  /// Size of each star.
  final double itemSize;

  /// Horizontal gap between stars.
  final double spacing;

  /// Color of filled (and half-filled) stars. Defaults to the theme's
  /// warning/amber glow color.
  final Color? color;

  /// Color of empty stars. Defaults to a muted system grey.
  final Color? unratedColor;

  /// Whether dragging/tapping can land on half-star increments.
  ///
  /// When false (default), [value] is always rounded to the nearest whole
  /// star as the user interacts.
  final bool allowHalfRating;

  /// Icon for a fully-rated star.
  final IconData filledIcon;

  /// Icon for a half-rated star. Only used when [allowHalfRating] is true.
  final IconData halfIcon;

  /// Icon for an unrated star.
  final IconData emptyIcon;

  @override
  State<GlassRatingBar> createState() => _GlassRatingBarState();
}

class _GlassRatingBarState extends State<GlassRatingBar> {
  double _valueFromLocalX(double localX) {
    final step = widget.itemSize + widget.spacing;
    final raw = (localX / step).clamp(0.0, widget.itemCount.toDouble());
    if (!widget.allowHalfRating) return raw.roundToDouble();
    return (raw * 2).round() / 2;
  }

  void _handleUpdate(Offset localPosition) {
    final onChanged = widget.onChanged;
    if (onChanged == null) return;
    final next = _valueFromLocalX(localPosition.dx)
        .clamp(0.0, widget.itemCount.toDouble());
    if (next != widget.value) onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final themeData = GlassThemeData.of(context);
    final glowColors = themeData.glowColorsFor(context);
    final filledColor = widget.color ??
        glowColors.warning ??
        const Color(0xFFFFB300);
    final emptyColor =
        widget.unratedColor ?? CupertinoColors.systemGrey3.resolveFrom(context);

    Widget row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < widget.itemCount; i++) ...[
          if (i > 0) SizedBox(width: widget.spacing),
          Icon(
            _iconFor(i),
            size: widget.itemSize,
            color: _iconFor(i) == widget.emptyIcon ? emptyColor : filledColor,
          ),
        ],
      ],
    );

    if (widget.onChanged != null) {
      row = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (details) => _handleUpdate(details.localPosition),
        onHorizontalDragUpdate: (details) =>
            _handleUpdate(details.localPosition),
        child: row,
      );
    }

    return Semantics(
      label: 'Rating',
      value: '${widget.value} out of ${widget.itemCount} stars',
      slider: widget.onChanged != null,
      child: ExcludeSemantics(child: row),
    );
  }

  IconData _iconFor(int index) {
    final remainder = widget.value - index;
    if (remainder >= 1) return widget.filledIcon;
    if (widget.allowHalfRating && remainder >= 0.5) return widget.halfIcon;
    return widget.emptyIcon;
  }
}
