import 'package:flutter/cupertino.dart';
import 'package:flutter_liquid_glass_widgets/widgets/feedback/glass_skeleton_loader.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../shared/test_helpers.dart';

void main() {
  group('GlassSkeletonLoader', () {
    testWidgets('default constructor sizes to width/height', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const GlassSkeletonLoader(width: 200, height: 20),
        ),
      );
      await tester.pump();

      expect(
        tester.getSize(find.byType(GlassSkeletonLoader)),
        const Size(200, 20),
      );
    });

    testWidgets('.text() defaults to a 14px-tall bar', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const GlassSkeletonLoader.text(width: 120),
        ),
      );
      await tester.pump();

      expect(
        tester.getSize(find.byType(GlassSkeletonLoader)),
        const Size(120, 14),
      );
    });

    testWidgets('.circle() is square (diameter x diameter)', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const GlassSkeletonLoader.circle(diameter: 48),
        ),
      );
      await tester.pump();

      expect(
        tester.getSize(find.byType(GlassSkeletonLoader)),
        const Size(48, 48),
      );
    });

    testWidgets('shimmer animation runs across frames without throwing',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const GlassSkeletonLoader(width: 100, height: 16),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pump(const Duration(milliseconds: 700));

      expect(tester.takeException(), isNull);
    });

    testWidgets('disposes its AnimationController cleanly on unmount',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const GlassSkeletonLoader(width: 100, height: 16),
        ),
      );
      await tester.pump();

      await tester.pumpWidget(createTestApp(child: const SizedBox()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
