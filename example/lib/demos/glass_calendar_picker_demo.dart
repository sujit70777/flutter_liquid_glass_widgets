/// GlassCalendarPicker Demo — single-day and range selection modes.
///
/// Run standalone:
///   flutter run -t example/lib/demos/glass_calendar_picker_demo.dart
library;

import 'package:flutter/cupertino.dart';

import 'package:flutter_liquid_glass_widgets/liquid_glass_widgets.dart';

import 'package:liquid_glass_widgets_example/theme/app_theme.dart';

class GlassCalendarPickerDemo extends StatefulWidget {
  const GlassCalendarPickerDemo({super.key});

  @override
  State<GlassCalendarPickerDemo> createState() =>
      _GlassCalendarPickerDemoState();
}

class _GlassCalendarPickerDemoState extends State<GlassCalendarPickerDemo> {
  bool _rangeMode = false;
  DateTime? _selectedDate;
  GlassDateRange? _selectedRange;

  String get _summary {
    if (_rangeMode) {
      final r = _selectedRange;
      if (r == null) return 'Tap a day to start a range';
      return '${_fmt(r.start)} → ${_fmt(r.end)}';
    }
    return _selectedDate == null ? 'No date selected' : _fmt(_selectedDate!);
  }

  String _fmt(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}'
      '-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/wallpaper.jpg', fit: BoxFit.cover),
          Container(color: CupertinoColors.black.withValues(alpha: 0.25)),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'GlassCalendarPicker',
                    style: AppType.display(isDark: true, size: 26, color: CupertinoColors.white),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _summary,
                    style: TextStyle(
                      color: CupertinoColors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  CupertinoSlidingSegmentedControl<bool>(
                    groupValue: _rangeMode,
                    children: const {
                      false: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('Single'),
                      ),
                      true: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('Range'),
                      ),
                    },
                    onValueChanged: (value) {
                      setState(() {
                        _rangeMode = value ?? false;
                        _selectedDate = null;
                        _selectedRange = null;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  GlassCalendarPicker(
                    key: ValueKey(_rangeMode),
                    selectionMode: _rangeMode
                        ? GlassCalendarSelectionMode.range
                        : GlassCalendarSelectionMode.single,
                    selectedDate: _selectedDate,
                    onDateSelected: (d) => setState(() => _selectedDate = d),
                    onRangeSelected: (r) => setState(() => _selectedRange = r),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
