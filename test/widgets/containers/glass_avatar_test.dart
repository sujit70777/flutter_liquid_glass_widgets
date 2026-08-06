import 'package:flutter/cupertino.dart';
import 'package:flutter_liquid_glass_widgets/widgets/containers/glass_avatar.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../shared/test_helpers.dart';

void main() {
  group('GlassAvatar', () {
    testWidgets('renders custom child content', (tester) async {
      await tester.pumpWidget(
        createTestApp(child: const GlassAvatar(child: Text('JD'))),
      );
      await tester.pumpAndSettle();

      expect(find.text('JD'), findsOneWidget);
    });

    testWidgets('renders a fallback person icon with no image or child',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(child: const GlassAvatar()),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(CupertinoIcons.person_fill), findsOneWidget);
    });

    testWidgets('sizes itself to 2x radius', (tester) async {
      await tester.pumpWidget(
        createTestApp(child: const GlassAvatar(radius: 30)),
      );
      await tester.pumpAndSettle();

      expect(tester.getSize(find.byType(GlassAvatar)), const Size(60, 60));
    });
  });
}
