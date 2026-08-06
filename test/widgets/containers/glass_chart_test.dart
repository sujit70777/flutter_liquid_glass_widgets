import 'package:flutter/cupertino.dart';
import 'package:flutter_liquid_glass_widgets/widgets/containers/glass_chart.dart';
import 'package:flutter_liquid_glass_widgets/widgets/shared/adaptive_glass_text.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../shared/test_helpers.dart';

void main() {
  group('GlassChart', () {
    testWidgets('renders the chart child', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const GlassChart(
            child: SizedBox(key: Key('chart'), width: 100, height: 100),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('chart')), findsOneWidget);
    });

    testWidgets('renders a title when provided', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const GlassChart(
            title: 'Weekly Active Users',
            child: SizedBox(width: 100, height: 100),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Weekly Active Users'), findsOneWidget);
    });

    testWidgets('renders no title text when title is null', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const GlassChart(child: SizedBox(width: 100, height: 100)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AdaptiveGlassText), findsNothing);
    });

    testWidgets('renders one legend row per entry with matching labels',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const GlassChart(
            legend: [
              GlassChartLegendEntry(
                  color: CupertinoColors.systemBlue, label: 'This week'),
              GlassChartLegendEntry(
                  color: CupertinoColors.systemGrey, label: 'Last week'),
            ],
            child: SizedBox(width: 100, height: 100),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('This week'), findsOneWidget);
      expect(find.text('Last week'), findsOneWidget);
    });

    testWidgets('renders no legend when the list is empty', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const GlassChart(
            legend: [],
            child: SizedBox(width: 100, height: 100),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AdaptiveGlassText), findsNothing);
    });
  });

  group('GlassChart.adaptiveAxisLabel', () {
    testWidgets('renders the given text via AdaptiveGlassText', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) => GlassChart.adaptiveAxisLabel(context, '42'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('42'), findsOneWidget);
      expect(find.byType(AdaptiveGlassText), findsOneWidget);
    });
  });
}
