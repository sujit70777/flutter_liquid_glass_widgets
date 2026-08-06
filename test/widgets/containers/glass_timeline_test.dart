import 'package:flutter/cupertino.dart';
import 'package:flutter_liquid_glass_widgets/widgets/containers/glass_timeline.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../shared/test_helpers.dart';

void main() {
  group('GlassTimeline', () {
    testWidgets('renders title, subtitle, and time for each item',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const GlassTimeline(
            items: [
              GlassTimelineItem(
                title: 'Order placed',
                time: '9:41 AM',
                icon: CupertinoIcons.cart,
              ),
              GlassTimelineItem(
                title: 'Shipped',
                subtitle: 'Via Express Courier',
                time: 'Yesterday',
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Order placed'), findsOneWidget);
      expect(find.text('9:41 AM'), findsOneWidget);
      expect(find.text('Shipped'), findsOneWidget);
      expect(find.text('Via Express Courier'), findsOneWidget);
      expect(find.text('Yesterday'), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.cart), findsOneWidget);
    });

    testWidgets('renders a single item without a connecting line crash',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const GlassTimeline(
            items: [GlassTimelineItem(title: 'Only entry')],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Only entry'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders nothing for an empty item list', (tester) async {
      await tester.pumpWidget(
        createTestApp(child: const GlassTimeline(items: [])),
      );
      await tester.pumpAndSettle();

      expect(find.byType(GlassTimeline), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
