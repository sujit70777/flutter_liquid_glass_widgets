import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_liquid_glass_widgets/widgets/interactive/glass_icon_button.dart';
import 'package:flutter_liquid_glass_widgets/widgets/surfaces/glass_dock.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../shared/test_helpers.dart';

void main() {
  group('GlassDock', () {
    List<String> tapped = [];
    List<GlassDockItem> makeItems() {
      tapped = [];
      return [
        GlassDockItem(
          icon: const Icon(CupertinoIcons.mail),
          label: 'Mail',
          onTap: () => tapped.add('mail'),
        ),
        GlassDockItem(
          icon: const Icon(CupertinoIcons.calendar),
          label: 'Calendar',
          onTap: () => tapped.add('calendar'),
        ),
        GlassDockItem(
          icon: const Icon(CupertinoIcons.photo),
          label: 'Photos',
          onTap: () => tapped.add('photos'),
        ),
      ];
    }

    testWidgets('renders one GlassIconButton per item', (tester) async {
      await tester.pumpWidget(
        createTestApp(child: GlassDock(items: makeItems())),
      );
      await tester.pumpAndSettle();

      expect(find.byType(GlassIconButton), findsNWidgets(3));
    });

    testWidgets('tapping an icon activates its onTap', (tester) async {
      await tester.pumpWidget(
        createTestApp(child: GlassDock(items: makeItems())),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(CupertinoIcons.calendar));
      await tester.pumpAndSettle();

      expect(tapped, ['calendar']);
    });

    testWidgets('all icons render at baseSize with no pointer present',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassDock(items: makeItems(), baseSize: 50),
        ),
      );
      await tester.pumpAndSettle();

      for (final size in tester
          .widgetList<GlassIconButton>(find.byType(GlassIconButton))
          .map((w) => w.size)) {
        expect(size, 50);
      }
    });

    testWidgets(
        'hovering near an icon magnifies it more than a distant neighbor',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassDock(
            items: makeItems(),
            baseSize: 50,
            spacing: 10,
            maxScale: 2.0,
            magnificationRadius: 40,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final dockTopLeft = tester.getTopLeft(find.byType(GlassDock));
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: dockTopLeft);
      addTearDown(gesture.removePointer);
      await tester.pump();

      // Move the pointer to hover directly over the first icon's resting
      // center (baseSize/2 from the dock's padded content origin).
      await gesture.moveTo(dockTopLeft + const Offset(12 + 25, 10));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      final sizes = tester
          .widgetList<GlassIconButton>(find.byType(GlassIconButton))
          .map((w) => w.size)
          .toList();

      // First icon (under the pointer) should be magnified well past
      // baseSize; the last icon (two full spacings away, well past the
      // falloff radius) should be at or very near baseSize.
      expect(sizes[0], greaterThan(70));
      expect(sizes[2], lessThan(55));
      // And the near icon should be visibly larger than the far one.
      expect(sizes[0], greaterThan(sizes[2]));
    });

    testWidgets('magnification relaxes back to baseSize on exit',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassDock(items: makeItems(), baseSize: 50),
        ),
      );
      await tester.pumpAndSettle();

      final dockTopLeft = tester.getTopLeft(find.byType(GlassDock));
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: dockTopLeft);
      addTearDown(gesture.removePointer);
      await tester.pump();

      await gesture.moveTo(dockTopLeft + const Offset(37, 10));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(
        tester
            .widgetList<GlassIconButton>(find.byType(GlassIconButton))
            .first
            .size,
        greaterThan(50),
      );

      await gesture.moveTo(const Offset(-500, -500));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      for (final size in tester
          .widgetList<GlassIconButton>(find.byType(GlassIconButton))
          .map((w) => w.size)) {
        expect(size, 50);
      }
    });
  });
}
