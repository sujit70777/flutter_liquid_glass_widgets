import 'package:flutter/widgets.dart';

/// A single action registered with a [GlassCommandPalette].
///
/// See [GlassCommandPalette] for how commands are searched, ranked, and
/// activated.
@immutable
class GlassCommand {
  /// Creates a command palette entry.
  const GlassCommand({
    required this.id,
    required this.label,
    required this.onSelect,
    this.icon,
    this.subtitle,
    this.keywords = const [],
    this.shortcutLabel,
  });

  /// Stable identifier used to track recency across palette invocations.
  ///
  /// Must be unique within the [List<GlassCommand>] passed to a single
  /// palette. Not shown in the UI.
  final String id;

  /// The primary label shown for this command, and the main text matched
  /// against the search query.
  final String label;

  /// Called when the user activates this command (tap, or Enter while
  /// highlighted). The palette closes itself before invoking this.
  final VoidCallback onSelect;

  /// Optional leading icon.
  final Widget? icon;

  /// Optional secondary line shown below [label].
  final String? subtitle;

  /// Extra search terms matched (in addition to [label]) but never
  /// displayed — use this for aliases and synonyms, e.g. `['dark mode']`
  /// on a command labeled "Appearance".
  final List<String> keywords;

  /// Optional trailing hint, e.g. `'⌘N'`, shown at the end of the row.
  final String? shortcutLabel;
}
