import 'package:flutter/cupertino.dart';

import '../../src/renderer/liquid_glass_renderer.dart';
import '../../theme/glass_theme_helpers.dart';
import '../../types/glass_quality.dart';
import '../shared/adaptive_glass.dart';
import '../shared/adaptive_glass_text.dart';

/// A single row in a [GlassChart]'s legend.
@immutable
class GlassChartLegendEntry {
  /// Creates a legend entry.
  const GlassChartLegendEntry({required this.color, required this.label});

  /// Swatch color for this series.
  final Color color;

  /// Series label.
  final String label;
}

/// Wraps any chart widget — [child] can be an `fl_chart` `LineChart`,
/// `BarChart`, `PieChart`, a custom painter, or anything else — in a
/// properly-styled liquid glass surface, with an optional title and legend.
///
/// ```dart
/// GlassChart(
///   title: 'Weekly Active Users',
///   legend: const [
///     GlassChartLegendEntry(color: Colors.blue, label: 'This week'),
///     GlassChartLegendEntry(color: Colors.grey, label: 'Last week'),
///   ],
///   child: SizedBox(height: 220, child: LineChart(myChartData)),
/// )
/// ```
///
/// [GlassChart] is chart-library-agnostic by design — it never imports
/// `fl_chart` or any other charting package, so adding it doesn't add a new
/// dependency to apps that don't chart anything. It just supplies glass
/// chrome and [AdaptiveGlassText] for the title/legend text it owns.
///
/// The chart library's own axis-tick labels are drawn by the chart library
/// itself, outside [GlassChart]'s reach — for those, use
/// [GlassChart.adaptiveAxisLabel] in the chart's own label-builder callback
/// (e.g. `fl_chart`'s `SideTitles.getTitlesWidget`) so tick labels get the
/// same backdrop-aware contrast as the title and legend:
///
/// ```dart
/// SideTitles(
///   getTitlesWidget: (value, meta) =>
///       GlassChart.adaptiveAxisLabel(context, value.toStringAsFixed(0)),
/// )
/// ```
///
/// Both [title]/legend text and [adaptiveAxisLabel] are built on
/// [AdaptiveGlassText] (in turn built on [GlassLuminanceSampler]) — the same
/// mechanism `GlassA11yScope` uses, applied here to a second, independent
/// consumer.
class GlassChart extends StatelessWidget {
  /// Creates a glass chart surface around [child].
  const GlassChart({
    super.key,
    required this.child,
    this.title,
    this.titleColor,
    this.legend,
    this.padding = const EdgeInsets.all(16),
    this.settings,
    this.quality,
    this.useOwnLayer = true,
  });

  /// The chart content.
  final Widget child;

  /// Optional title shown above [child].
  final String? title;

  /// Light/dark color pair for [title]. Defaults to label/secondaryLabel
  /// Cupertino colors.
  final (Color light, Color dark)? titleColor;

  /// Optional legend rows shown below [child].
  final List<GlassChartLegendEntry>? legend;

  /// Padding around the whole surface.
  final EdgeInsetsGeometry padding;

  /// Custom glass settings for the surface.
  final LiquidGlassSettings? settings;

  /// Rendering quality for the glass effect.
  final GlassQuality? quality;

  /// Whether to create its own layer or use grouped glass.
  final bool useOwnLayer;

  /// Builds a chart axis-tick label with the same backdrop-aware contrast
  /// as [GlassChart]'s own title/legend text.
  ///
  /// Intended for a charting library's per-tick label callback — e.g.
  /// `fl_chart`'s `SideTitles(getTitlesWidget: ...)`. Requires the same
  /// [GlassContentAwareScope] precondition as [AdaptiveGlassText] generally;
  /// falls back to ambient-brightness static coloring when there is no
  /// scope to sample, the same as any other [AdaptiveGlassText].
  static Widget adaptiveAxisLabel(
    BuildContext context,
    String text, {
    Color? lightColor,
    Color? darkColor,
    TextStyle? style,
  }) {
    return AdaptiveGlassText(
      text,
      lightColor: lightColor ?? CupertinoColors.black.withValues(alpha: 0.6),
      darkColor: darkColor ?? CupertinoColors.white.withValues(alpha: 0.6),
      style: style ?? const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveQuality = GlassThemeHelpers.resolveQuality(
      context,
      widgetQuality: quality,
    );
    final resolvedTitleColor = titleColor ??
        (CupertinoColors.label.resolveFrom(context),
            CupertinoColors.label.darkColor);

    return AdaptiveGlass(
      shape: const LiquidRoundedSuperellipse(borderRadius: 20),
      settings: settings ?? const LiquidGlassSettings(blur: 8),
      quality: effectiveQuality,
      useOwnLayer: useOwnLayer,
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              AdaptiveGlassText(
                title!,
                lightColor: resolvedTitleColor.$1,
                darkColor: resolvedTitleColor.$2,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
            ],
            child,
            if (legend != null && legend!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 6,
                children: [
                  for (final entry in legend!)
                    _LegendRow(entry: entry),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.entry});

  final GlassChartLegendEntry entry;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: entry.color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        AdaptiveGlassText(
          entry.label,
          lightColor: CupertinoColors.black.withValues(alpha: 0.7),
          darkColor: CupertinoColors.white.withValues(alpha: 0.7),
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }
}
