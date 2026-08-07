import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_liquid_glass_widgets/liquid_glass_widgets.dart';

// ---------------------------------------------------------------------------
// RTL Layout Audit Tests
//
// Verifies that widgets updated in the RTL audit (0.28.0) use directional
// padding/alignment primitives and mirror correctly under TextDirection.rtl.
// ---------------------------------------------------------------------------

/// Minimal LTR wrapper — no extra Padding injected by scaffolds.
Widget _ltrBare(Widget child) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: MediaQuery(
      data: const MediaQueryData(),
      child: child,
    ),
  );
}

/// Minimal RTL wrapper.
Widget _rtlBare(Widget child) {
  return Directionality(
    textDirection: TextDirection.rtl,
    child: MediaQuery(
      data: const MediaQueryData(),
      child: child,
    ),
  );
}

/// Resolve a geometry to physical insets.
EdgeInsets _resolve(EdgeInsetsGeometry geo, TextDirection dir) =>
    geo.resolve(dir);

void main() {
  // =========================================================================
  // GlassDivider — indent / endIndent directional mapping
  // =========================================================================

  group('GlassDivider — RTL indent mapping', () {
    testWidgets('padding is EdgeInsetsDirectional, not EdgeInsets',
        (tester) async {
      await tester.pumpWidget(
        _ltrBare(const Center(child: GlassDivider(indent: 24, endIndent: 8))),
      );
      // ExcludeSemantics → Padding → SizedBox → Center → Container
      final padding = tester.widget<Padding>(
        find
            .descendant(
              of: find.byType(GlassDivider),
              matching: find.byType(Padding),
            )
            .first,
      );
      expect(
        padding.padding,
        isA<EdgeInsetsDirectional>(),
        reason: 'GlassDivider should use EdgeInsetsDirectional for RTL support',
      );
    });

    testWidgets('indent maps to physical left in LTR', (tester) async {
      await tester.pumpWidget(
        _ltrBare(const Center(child: GlassDivider(indent: 24, endIndent: 8))),
      );
      final padding = tester.widget<Padding>(
        find
            .descendant(
              of: find.byType(GlassDivider),
              matching: find.byType(Padding),
            )
            .first,
      );
      final insets = _resolve(padding.padding, TextDirection.ltr);
      expect(insets.left, 24, reason: 'start(24) → left in LTR');
      expect(insets.right, 8, reason: 'end(8) → right in LTR');
    });

    testWidgets('indent maps to physical right in RTL', (tester) async {
      await tester.pumpWidget(
        _rtlBare(const Center(child: GlassDivider(indent: 24, endIndent: 8))),
      );
      final padding = tester.widget<Padding>(
        find
            .descendant(
              of: find.byType(GlassDivider),
              matching: find.byType(Padding),
            )
            .first,
      );
      final insets = _resolve(padding.padding, TextDirection.rtl);
      expect(insets.right, 24,
          reason: 'start(24) → right in RTL (leading side)');
      expect(insets.left, 8, reason: 'end(8) → left in RTL (trailing side)');
    });

    testWidgets('vertical divider top/bottom are unaffected by text direction',
        (tester) async {
      await tester.pumpWidget(
        _rtlBare(
          const SizedBox(
              height: 100,
              child: GlassDivider.vertical(indent: 10, endIndent: 5)),
        ),
      );
      final padding = tester.widget<Padding>(
        find
            .descendant(
              of: find.byType(GlassDivider),
              matching: find.byType(Padding),
            )
            .first,
      );
      final insets = _resolve(padding.padding, TextDirection.rtl);
      expect(insets.top, 10, reason: 'indent → top for vertical divider');
      expect(insets.bottom, 5,
          reason: 'endIndent → bottom for vertical divider');
    });
  });

  // =========================================================================
  // GlassGroupedSection — header / footer insets
  // =========================================================================

  group('GlassGroupedSection — RTL header padding', () {
    testWidgets('header start=16 → left=16 in LTR', (tester) async {
      await tester.pumpWidget(
        _ltrBare(
          GlassGroupedSection(
            header: const Text('Header'),
            children: const [SizedBox.shrink()],
          ),
        ),
      );
      final headerPadding =
          tester.widgetList<Padding>(find.byType(Padding)).firstWhere(
                (p) => tester
                    .widgetList(find.descendant(
                      of: find.byWidget(p),
                      matching: find.byType(DefaultTextStyle),
                    ))
                    .isNotEmpty,
              );
      final insets = _resolve(headerPadding.padding, TextDirection.ltr);
      expect(insets.left, 16);
      expect(insets.right, 16);
    });

    testWidgets('header start=16 → right=16 in RTL', (tester) async {
      await tester.pumpWidget(
        _rtlBare(
          GlassGroupedSection(
            header: const Text('رأس'),
            children: const [SizedBox.shrink()],
          ),
        ),
      );
      final headerPadding =
          tester.widgetList<Padding>(find.byType(Padding)).firstWhere(
                (p) => tester
                    .widgetList(find.descendant(
                      of: find.byWidget(p),
                      matching: find.byType(DefaultTextStyle),
                    ))
                    .isNotEmpty,
              );
      final insets = _resolve(headerPadding.padding, TextDirection.rtl);
      // start=16 (logical leading) → physical right in RTL
      expect(insets.right, 16);
      expect(insets.left, 16);
    });
  });

  // =========================================================================
  // GlassAppBar — title alignment
  // =========================================================================

  group('GlassAppBar — RTL title alignment', () {
    testWidgets('non-centered title uses AlignmentDirectional.centerStart',
        (tester) async {
      await tester.pumpWidget(
        _ltrBare(
          const GlassAppBar(
            title: Text('Title'),
            centerTitle: false,
          ),
        ),
      );
      final aligns = tester.widgetList<Align>(find.byType(Align));
      final hasDirectionalAlign = aligns.any(
        (a) => a.alignment == AlignmentDirectional.centerStart,
      );
      expect(
        hasDirectionalAlign,
        isTrue,
        reason: 'GlassAppBar title should use AlignmentDirectional.centerStart',
      );
    });

    testWidgets('centered title uses Center (directional-safe)',
        (tester) async {
      await tester.pumpWidget(
        _ltrBare(
          const GlassAppBar(title: Text('Title')),
        ),
      );
      expect(find.byType(Center), findsWidgets);
    });
  });

  // =========================================================================
  // GlassLargeTitle — scaling alignment
  //
  // Smoke test for the Transform.scale anchor fix. Full RTL padding coverage
  // lives in test/widgets/surfaces/glass_large_title_test.dart.
  // =========================================================================

  group('GlassLargeTitle — RTL scaling alignment', () {
    testWidgets('title scales from AlignmentDirectional.bottomStart',
        (tester) async {
      final controller = GlassLargeTitleController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _rtlBare(
          CustomScrollView(
            controller: controller.scrollController,
            slivers: [
              GlassLargeTitle(text: 'Title', controller: controller),
            ],
          ),
        ),
      );
      final transforms = tester.widgetList<Transform>(find.byType(Transform));
      final hasDirectionalAlign = transforms
          .any((t) => t.alignment == AlignmentDirectional.bottomStart);
      expect(
        hasDirectionalAlign,
        isTrue,
        reason: 'GlassLargeTitle rubber-band scale must anchor to '
            'AlignmentDirectional.bottomStart — not Alignment.bottomLeft — '
            'so the title stretches from the leading edge in both LTR and RTL.',
      );
    });
  });
}
