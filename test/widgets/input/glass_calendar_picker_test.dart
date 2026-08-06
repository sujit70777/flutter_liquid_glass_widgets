import 'package:flutter/cupertino.dart';
import 'package:flutter_liquid_glass_widgets/widgets/input/glass_calendar_picker.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../shared/test_helpers.dart';

void main() {
  group('GlassCalendarPicker', () {
    testWidgets('shows the initial month and year', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassCalendarPicker(initialMonth: DateTime(2024, 2)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('February 2024'), findsOneWidget);
    });

    testWidgets('renders every day of a 29-day (leap) February', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassCalendarPicker(initialMonth: DateTime(2024, 2)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('29'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('30'), findsNothing);
    });

    testWidgets('next/prev month buttons update the header', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassCalendarPicker(initialMonth: DateTime(2024, 2)),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(CupertinoIcons.chevron_right));
      await tester.pumpAndSettle();
      expect(find.text('March 2024'), findsOneWidget);

      await tester.tap(find.byIcon(CupertinoIcons.chevron_left));
      await tester.tap(find.byIcon(CupertinoIcons.chevron_left));
      await tester.pumpAndSettle();
      expect(find.text('January 2024'), findsOneWidget);
    });

    testWidgets('tapping a day in single mode reports it', (tester) async {
      DateTime? picked;
      await tester.pumpWidget(
        createTestApp(
          child: GlassCalendarPicker(
            initialMonth: DateTime(2024, 2),
            onDateSelected: (d) => picked = d,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('15'));
      await tester.pumpAndSettle();

      expect(picked, DateTime(2024, 2, 15));
    });

    testWidgets('disabled days (before firstDate) do not report a tap',
        (tester) async {
      DateTime? picked;
      await tester.pumpWidget(
        createTestApp(
          child: GlassCalendarPicker(
            initialMonth: DateTime(2024, 2),
            firstDate: DateTime(2024, 2, 10),
            onDateSelected: (d) => picked = d,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('5'));
      await tester.pumpAndSettle();

      expect(picked, isNull);
    });

    testWidgets(
        'range mode: two taps complete a range, reported in start<=end order',
        (tester) async {
      GlassDateRange? range;
      await tester.pumpWidget(
        createTestApp(
          child: GlassCalendarPicker(
            initialMonth: DateTime(2024, 2),
            selectionMode: GlassCalendarSelectionMode.range,
            onRangeSelected: (r) => range = r,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('20'));
      await tester.pumpAndSettle();
      expect(range, isNull); // first tap only starts the range

      await tester.tap(find.text('10'));
      await tester.pumpAndSettle();

      // Tapped 20 then 10 (an earlier day) — start/end should swap so the
      // range is always chronological.
      expect(range, isNotNull);
      expect(range!.start, DateTime(2024, 2, 10));
      expect(range!.end, DateTime(2024, 2, 20));
    });

    testWidgets('range mode: a tap after a completed range starts a new one',
        (tester) async {
      final ranges = <GlassDateRange>[];
      await tester.pumpWidget(
        createTestApp(
          child: GlassCalendarPicker(
            initialMonth: DateTime(2024, 2),
            selectionMode: GlassCalendarSelectionMode.range,
            onRangeSelected: ranges.add,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('5'));
      await tester.tap(find.text('8'));
      await tester.pumpAndSettle();
      expect(ranges, hasLength(1));
      expect(ranges.single.start, DateTime(2024, 2, 5));
      expect(ranges.single.end, DateTime(2024, 2, 8));

      // Third tap starts a fresh range rather than extending the old one.
      await tester.tap(find.text('12'));
      await tester.pumpAndSettle();
      expect(ranges, hasLength(1)); // no new callback yet — only a start

      await tester.tap(find.text('14'));
      await tester.pumpAndSettle();
      expect(ranges, hasLength(2));
      expect(ranges.last.start, DateTime(2024, 2, 12));
      expect(ranges.last.end, DateTime(2024, 2, 14));
    });
  });

  group('GlassDateRange', () {
    test('contains is inclusive of both endpoints', () {
      final range =
          GlassDateRange(start: DateTime(2024, 1, 5), end: DateTime(2024, 1, 10));
      expect(range.contains(DateTime(2024, 1, 5)), isTrue);
      expect(range.contains(DateTime(2024, 1, 10)), isTrue);
      expect(range.contains(DateTime(2024, 1, 7)), isTrue);
      expect(range.contains(DateTime(2024, 1, 4)), isFalse);
      expect(range.contains(DateTime(2024, 1, 11)), isFalse);
    });

    test('asserts start is not after end', () {
      expect(
        () => GlassDateRange(start: DateTime(2024, 1, 10), end: DateTime(2024, 1, 5)),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
