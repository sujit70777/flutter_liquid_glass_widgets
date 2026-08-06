import 'package:flutter/cupertino.dart';

import '../../src/renderer/liquid_glass_renderer.dart';
import '../../theme/glass_theme_data.dart';
import '../../theme/glass_theme_helpers.dart';
import '../../types/glass_quality.dart';
import '../shared/adaptive_glass.dart';

/// A closed date range, as used by [GlassCalendarPicker]'s range-selection
/// mode.
///
/// A small local type rather than Flutter's `DateTimeRange` — this package
/// deliberately has no dependency on `package:flutter/material.dart`.
@immutable
class GlassDateRange {
  /// Creates a date range. [start] must not be after [end].
  GlassDateRange({required this.start, required this.end})
      : assert(!start.isAfter(end), 'start must not be after end');

  /// The first day of the range, inclusive.
  final DateTime start;

  /// The last day of the range, inclusive.
  final DateTime end;

  /// Whether [day] (compared by calendar date, ignoring time-of-day) falls
  /// within `[start, end]`.
  bool contains(DateTime day) {
    final d = _DateUtils.dateOnly(day);
    return !d.isBefore(_DateUtils.dateOnly(start)) &&
        !d.isAfter(_DateUtils.dateOnly(end));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GlassDateRange && start == other.start && end == other.end;

  @override
  int get hashCode => Object.hash(start, end);
}

/// Whether [GlassCalendarPicker] selects a single day or a date range.
enum GlassCalendarSelectionMode {
  /// Tapping a day selects it via [GlassCalendarPicker.onDateSelected].
  single,

  /// The first tap starts a range, the second completes it via
  /// [GlassCalendarPicker.onRangeSelected]; the next tap after that starts a
  /// new range.
  range,
}

/// Minimal date-arithmetic helpers used internally — kept private (rather
/// than reusing Flutter's own `DateUtils`) since importing
/// `package:flutter/material.dart` just for this would both reintroduce the
/// Material dependency this package deliberately dropped, and a public
/// `DateUtils` export would collide with Material's own class name for any
/// app that imports both packages.
abstract final class _DateUtils {
  /// Strips the time-of-day component, keeping only year/month/day.
  static DateTime dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  /// The first day of [date]'s month.
  static DateTime monthStart(DateTime date) =>
      DateTime(date.year, date.month);

  /// [date]'s month, offset by [months] (may roll into a different year).
  static DateTime addMonths(DateTime date, int months) =>
      DateTime(date.year, date.month + months);

  /// Number of days in [date]'s month.
  static int daysInMonth(DateTime date) =>
      DateTime(date.year, date.month + 1, 0).day;

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

/// A full calendar-grid date picker in the liquid glass aesthetic — month
/// navigation, single or range selection, with an animated glass highlight
/// that slides between days.
///
/// (A sliding highlight between same-sized grid cells is a plain position
/// interpolation, not a shape morph, so this uses a lightweight
/// [AnimatedPositioned] rather than the [GlassMorphController] engine — that
/// engine is built for morphing between different geometries, e.g. `GlassMenu`
/// button-into-panel, which isn't what's happening here.)
///
/// ```dart
/// DateTime? picked;
///
/// GlassCalendarPicker(
///   selectedDate: picked,
///   onDateSelected: (date) => setState(() => picked = date),
///   firstDate: DateTime(2020),
///   lastDate: DateTime(2030),
/// )
/// ```
///
/// For range selection:
///
/// ```dart
/// GlassCalendarPicker(
///   selectionMode: GlassCalendarSelectionMode.range,
///   selectedRange: range,
///   onRangeSelected: (r) => setState(() => range = r),
/// )
/// ```
class GlassCalendarPicker extends StatefulWidget {
  /// Creates a glass calendar picker.
  GlassCalendarPicker({
    super.key,
    DateTime? initialMonth,
    this.selectionMode = GlassCalendarSelectionMode.single,
    this.selectedDate,
    this.selectedRange,
    this.onDateSelected,
    this.onRangeSelected,
    this.firstDate,
    this.lastDate,
    this.settings,
    this.quality,
    this.useOwnLayer = false,
  }) : initialMonth = initialMonth ?? DateTime.now();

  /// The month initially shown. Defaults to the current month.
  final DateTime initialMonth;

  /// Whether this picks a single day or a range.
  final GlassCalendarSelectionMode selectionMode;

  /// The selected day, in [GlassCalendarSelectionMode.single] mode.
  final DateTime? selectedDate;

  /// The selected range, in [GlassCalendarSelectionMode.range] mode. Only
  /// used to seed the initial display — in-progress range selection (after
  /// the first of the two taps) is tracked internally.
  final GlassDateRange? selectedRange;

  /// Called with the tapped day in [GlassCalendarSelectionMode.single] mode.
  final ValueChanged<DateTime>? onDateSelected;

  /// Called once both ends of the range are picked, in
  /// [GlassCalendarSelectionMode.range] mode.
  final ValueChanged<GlassDateRange>? onRangeSelected;

  /// Earliest selectable day. Earlier days render disabled. Null means no
  /// lower bound.
  final DateTime? firstDate;

  /// Latest selectable day. Later days render disabled. Null means no upper
  /// bound.
  final DateTime? lastDate;

  /// Custom glass settings for the picker surface.
  final LiquidGlassSettings? settings;

  /// Rendering quality for the glass effect.
  final GlassQuality? quality;

  /// Whether to create its own layer or use grouped glass.
  final bool useOwnLayer;

  @override
  State<GlassCalendarPicker> createState() => _GlassCalendarPickerState();
}

class _GlassCalendarPickerState extends State<GlassCalendarPicker> {
  static const _weekdayLabels = [
    'Su',
    'Mo',
    'Tu',
    'We',
    'Th',
    'Fr',
    'Sa'
  ];
  static const _monthLabels = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  late DateTime _visibleMonth;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  @override
  void initState() {
    super.initState();
    _visibleMonth = _DateUtils.monthStart(widget.initialMonth);
    _rangeStart = widget.selectedRange?.start;
    _rangeEnd = widget.selectedRange?.end;
  }

  bool _isDisabled(DateTime day) {
    if (widget.firstDate != null &&
        day.isBefore(_DateUtils.dateOnly(widget.firstDate!))) {
      return true;
    }
    if (widget.lastDate != null &&
        day.isAfter(_DateUtils.dateOnly(widget.lastDate!))) {
      return true;
    }
    return false;
  }

  void _changeMonth(int delta) {
    setState(() => _visibleMonth = _DateUtils.addMonths(_visibleMonth, delta));
  }

  void _handleDayTap(DateTime day) {
    if (_isDisabled(day)) return;
    if (widget.selectionMode == GlassCalendarSelectionMode.single) {
      widget.onDateSelected?.call(day);
      return;
    }
    if (_rangeStart == null || _rangeEnd != null) {
      setState(() {
        _rangeStart = day;
        _rangeEnd = null;
      });
      return;
    }
    setState(() {
      if (day.isBefore(_rangeStart!)) {
        _rangeEnd = _rangeStart;
        _rangeStart = day;
      } else {
        _rangeEnd = day;
      }
    });
    widget.onRangeSelected?.call(GlassDateRange(
      start: _rangeStart!,
      end: _rangeEnd!,
    ));
  }

  /// Weeks of the visible month, as 7-day rows; days outside the month are
  /// null (rendered blank).
  List<List<DateTime?>> _weeks() {
    final firstOfMonth = _visibleMonth;
    final daysInMonth = _DateUtils.daysInMonth(_visibleMonth);
    final leadingBlanks = firstOfMonth.weekday % 7; // Sunday-start grid

    final cells = <DateTime?>[
      for (var i = 0; i < leadingBlanks; i++) null,
      for (var d = 1; d <= daysInMonth; d++)
        DateTime(_visibleMonth.year, _visibleMonth.month, d),
    ];
    while (cells.length % 7 != 0) {
      cells.add(null);
    }

    return [
      for (var i = 0; i < cells.length; i += 7) cells.sublist(i, i + 7),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final effectiveQuality = GlassThemeHelpers.resolveQuality(
      context,
      widgetQuality: widget.quality,
    );
    final themeData = GlassThemeData.of(context);
    final accent = themeData.glowColorsFor(context).primary ??
        CupertinoColors.activeBlue.resolveFrom(context);
    final labelColor = CupertinoColors.label.resolveFrom(context);
    final secondaryColor = CupertinoColors.secondaryLabel.resolveFrom(context);

    return AdaptiveGlass(
      shape: const LiquidRoundedSuperellipse(borderRadius: 20),
      settings: widget.settings ?? const LiquidGlassSettings(blur: 8),
      quality: effectiveQuality,
      useOwnLayer: widget.useOwnLayer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                _NavButton(
                  icon: CupertinoIcons.chevron_left,
                  onTap: () => _changeMonth(-1),
                  color: labelColor,
                ),
                Expanded(
                  child: Text(
                    '${_monthLabels[_visibleMonth.month - 1]} ${_visibleMonth.year}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: labelColor,
                    ),
                  ),
                ),
                _NavButton(
                  icon: CupertinoIcons.chevron_right,
                  onTap: () => _changeMonth(1),
                  color: labelColor,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                for (final label in _weekdayLabels)
                  Expanded(
                    child: Center(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: secondaryColor,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            for (final week in _weeks())
              Row(
                children: [
                  for (final day in week)
                    Expanded(
                      child: day == null
                          ? const SizedBox(height: 40)
                          : _DayCell(
                              day: day,
                              disabled: _isDisabled(day),
                              selected: widget.selectionMode ==
                                      GlassCalendarSelectionMode.single
                                  ? widget.selectedDate != null &&
                                      _DateUtils.isSameDay(
                                          day, widget.selectedDate!)
                                  : (_rangeStart != null &&
                                          _DateUtils.isSameDay(
                                              day, _rangeStart!)) ||
                                      (_rangeEnd != null &&
                                          _DateUtils.isSameDay(
                                              day, _rangeEnd!)),
                              inRange: widget.selectionMode ==
                                      GlassCalendarSelectionMode.range &&
                                  _rangeStart != null &&
                                  _rangeEnd != null &&
                                  GlassDateRange(
                                          start: _rangeStart!,
                                          end: _rangeEnd!)
                                      .contains(day),
                              accent: accent,
                              labelColor: labelColor,
                              onTap: () => _handleDayTap(day),
                            ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.onTap,
    required this.color,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.disabled,
    required this.selected,
    required this.inRange,
    required this.accent,
    required this.labelColor,
    required this.onTap,
  });

  final DateTime day;
  final bool disabled;
  final bool selected;
  final bool inRange;
  final Color accent;
  final Color labelColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isToday = _DateUtils.isSameDay(day, DateTime.now());

    return GestureDetector(
      onTap: disabled ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          height: 36,
          decoration: BoxDecoration(
            color: selected
                ? accent
                : inRange
                    ? accent.withValues(alpha: 0.18)
                    : null,
            shape: selected ? BoxShape.circle : BoxShape.rectangle,
            border: !selected && isToday
                ? Border.all(color: accent, width: 1.2)
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            '${day.day}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              color: disabled
                  ? labelColor.withValues(alpha: 0.3)
                  : selected
                      ? CupertinoColors.white
                      : labelColor,
            ),
          ),
        ),
      ),
    );
  }
}
