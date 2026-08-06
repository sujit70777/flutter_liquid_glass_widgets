import 'package:flutter/cupertino.dart';
import 'package:flutter_liquid_glass_widgets/widgets/input/glass_rating_bar.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../shared/test_helpers.dart';

void main() {
  group('GlassRatingBar', () {
    testWidgets('renders itemCount stars', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassRatingBar(value: 3, itemCount: 5, onChanged: (_) {}),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Icon), findsNWidgets(5));
    });

    testWidgets('shows filledIcon for rated stars and emptyIcon beyond',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassRatingBar(value: 3, itemCount: 5, onChanged: (_) {}),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(CupertinoIcons.star_fill), findsNWidgets(3));
      expect(find.byIcon(CupertinoIcons.star), findsNWidgets(2));
    });

    testWidgets('half rating shows the half icon when allowHalfRating',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassRatingBar(
            value: 2.5,
            itemCount: 5,
            allowHalfRating: true,
            onChanged: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(CupertinoIcons.star_fill), findsNWidgets(2));
      expect(find.byIcon(CupertinoIcons.star_lefthalf_fill), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.star), findsNWidgets(2));
    });

    testWidgets('tapping a star reports the rounded whole-star value',
        (tester) async {
      double? reported;
      await tester.pumpWidget(
        createTestApp(
          child: GlassRatingBar(
            value: 0,
            itemCount: 5,
            itemSize: 28,
            spacing: 4,
            onChanged: (v) => reported = v,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap near the end of the 4th star (index 3): step = 28+4 = 32, so
      // x ~ 3*32+28 = 124 -> raw = 124/32 = 3.875 -> rounds to 4.
      final topLeft = tester.getTopLeft(find.byType(GlassRatingBar));
      await tester.tapAt(topLeft + const Offset(3 * 32 + 28, 14));
      await tester.pumpAndSettle();

      expect(reported, 4);
    });

    testWidgets('read-only (onChanged null) does not crash on tap',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const GlassRatingBar(value: 4, itemCount: 5),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(GlassRatingBar));
      await tester.pumpAndSettle();

      expect(find.byIcon(CupertinoIcons.star_fill), findsNWidgets(4));
    });
  });
}
