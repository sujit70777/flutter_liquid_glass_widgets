import 'package:flutter/cupertino.dart';

import '../../theme/glass_theme_data.dart';

/// A single entry in a [GlassTimeline].
class GlassTimelineItem {
  /// Creates a timeline entry.
  const GlassTimelineItem({
    required this.title,
    this.subtitle,
    this.time,
    this.icon,
    this.color,
  });

  /// The entry's headline.
  final String title;

  /// Optional secondary text below [title].
  final String? subtitle;

  /// Optional trailing timestamp text (e.g. `'2h ago'`, `'Jan 4'`).
  final String? time;

  /// Icon shown inside the node dot. Defaults to a plain filled dot when
  /// null.
  final IconData? icon;

  /// Color of this entry's node and connecting line segment above it.
  /// Defaults to the theme's primary glow color.
  final Color? color;
}

/// A vertical activity/changelog timeline: a connected line of glass nodes,
/// each with a title, optional subtitle, and optional timestamp.
///
/// ```dart
/// GlassTimeline(
///   items: [
///     GlassTimelineItem(
///       title: 'Order placed',
///       time: '9:41 AM',
///       icon: CupertinoIcons.cart,
///     ),
///     GlassTimelineItem(
///       title: 'Shipped',
///       subtitle: 'Via Express Courier',
///       time: 'Yesterday',
///       icon: CupertinoIcons.cube_box,
///     ),
///   ],
/// )
/// ```
class GlassTimeline extends StatelessWidget {
  /// Creates a glass timeline.
  const GlassTimeline({
    super.key,
    required this.items,
    this.nodeSize = 28,
    this.lineWidth = 2,
    this.itemSpacing = 24,
  });

  /// The entries, in display order (top to bottom).
  final List<GlassTimelineItem> items;

  /// Diameter of each node.
  final double nodeSize;

  /// Width of the connecting line.
  final double lineWidth;

  /// Vertical gap between entries.
  final double itemSpacing;

  @override
  Widget build(BuildContext context) {
    final themeData = GlassThemeData.of(context);
    final glowColors = themeData.glowColorsFor(context);
    final defaultColor = glowColors.primary ?? CupertinoColors.activeBlue;
    final lineColor = CupertinoColors.systemGrey3.resolveFrom(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) SizedBox(height: itemSpacing),
          _GlassTimelineRow(
            item: items[i],
            nodeSize: nodeSize,
            lineWidth: lineWidth,
            itemSpacing: itemSpacing,
            color: items[i].color ?? defaultColor,
            lineColor: lineColor,
            showLineAbove: i > 0,
            showLineBelow: i < items.length - 1,
          ),
        ],
      ],
    );
  }
}

class _GlassTimelineRow extends StatelessWidget {
  const _GlassTimelineRow({
    required this.item,
    required this.nodeSize,
    required this.lineWidth,
    required this.itemSpacing,
    required this.color,
    required this.lineColor,
    required this.showLineAbove,
    required this.showLineBelow,
  });

  final GlassTimelineItem item;
  final double nodeSize;
  final double lineWidth;
  final double itemSpacing;
  final Color color;
  final Color lineColor;
  final bool showLineAbove;
  final bool showLineBelow;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: nodeSize,
            child: Column(
              children: [
                Expanded(child: showLineAbove ? _line() : const SizedBox()),
                Container(
                  width: nodeSize,
                  height: nodeSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.18),
                    border: Border.all(color: color, width: 1.5),
                  ),
                  child: item.icon == null
                      ? Center(
                          child: Container(
                            width: nodeSize * 0.32,
                            height: nodeSize * 0.32,
                            decoration:
                                BoxDecoration(color: color, shape: BoxShape.circle),
                          ),
                        )
                      : Icon(item.icon, size: nodeSize * 0.55, color: color),
                ),
                Expanded(child: showLineBelow ? _line() : const SizedBox()),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: CupertinoColors.label.resolveFrom(context),
                          ),
                        ),
                        if (item.subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            item.subtitle!,
                            style: TextStyle(
                              fontSize: 13,
                              color: CupertinoColors.secondaryLabel
                                  .resolveFrom(context),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (item.time != null)
                    Text(
                      item.time!,
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            CupertinoColors.tertiaryLabel.resolveFrom(context),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _line() => Container(width: lineWidth, color: lineColor);
}
