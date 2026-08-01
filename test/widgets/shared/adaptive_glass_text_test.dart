// Behavior tests for AdaptiveGlassText's three GlassA11yMode behaviors:
//   - auto (default, no GlassA11yScope needed): flips lightColor/darkColor
//     to track the sampled backdrop, exactly like GlassContentAwareBrightness
//   - warnOnly: keeps a static ambient-resolved color, but logs a contrast
//     warning in debug builds when it fails against the sampled backdrop
//   - off: a static ambient-resolved color, no sampling/registration at all

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_liquid_glass_widgets/liquid_glass_widgets.dart';

Future<void> _settleSample(
  WidgetTester tester,
  GlassContentAwareScopeState scope,
) {
  return tester.runAsync(() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await scope.sampleNow();
  });
}

Color? _textColor(WidgetTester tester) =>
    tester.widget<Text>(find.text('Settings')).style?.color;

Widget _pipeline({
  required Widget content,
  required Widget text,
  GlassA11yMode? mode,
}) {
  final stack = Stack(
    children: [
      Positioned.fill(child: GlassContentAwareContent(child: content)),
      Positioned(left: 0, top: 0, child: text),
    ],
  );
  // GlassA11yScope installs its own GlassContentAwareScope internally, so
  // only wrap explicitly when testing AdaptiveGlassText with no scope at all.
  return MaterialApp(
    home: mode == null
        ? GlassContentAwareScope(child: stack)
        : GlassA11yScope(mode: mode, child: stack),
  );
}

void main() {
  group('GlassA11yMode.auto', () {
    const text = AdaptiveGlassText(
      'Settings',
      lightColor: Color(0xFF000000),
      darkColor: Color(0xFFFFFFFF),
    );

    testWidgets('is the default with no GlassA11yScope ancestor',
        (tester) async {
      await tester.pumpWidget(_pipeline(
        content: const ColoredBox(color: Color(0xFF000000)),
        text: text,
      ));
      expect(_textColor(tester), const Color(0xFF000000)); // starts light

      final scopeState = tester.state<GlassContentAwareScopeState>(
          find.byType(GlassContentAwareScope));
      await _settleSample(tester, scopeState);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(_textColor(tester), const Color(0xFFFFFFFF)); // flipped dark
    });

    testWidgets('flips explicitly under GlassA11yScope(mode: auto)',
        (tester) async {
      await tester.pumpWidget(_pipeline(
        content: const ColoredBox(color: Color(0xFF000000)),
        text: text,
        mode: GlassA11yMode.auto,
      ));

      final scopeState = tester.state<GlassContentAwareScopeState>(
          find.byType(GlassContentAwareScope));
      await _settleSample(tester, scopeState);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(_textColor(tester), const Color(0xFFFFFFFF));
    });
  });

  group('GlassA11yMode.off', () {
    testWidgets('renders a static ambient color and never flips',
        (tester) async {
      const text = AdaptiveGlassText(
        'Settings',
        lightColor: Color(0xFF111111),
        darkColor: Color(0xFFEEEEEE),
      );
      await tester.pumpWidget(_pipeline(
        content: const ColoredBox(color: Color(0xFF000000)),
        text: text,
        mode: GlassA11yMode.off,
      ));
      expect(_textColor(tester), const Color(0xFF111111));

      final scopeState = tester.state<GlassContentAwareScopeState>(
          find.byType(GlassContentAwareScope));
      await _settleSample(tester, scopeState);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Dark content behind it would flip an `auto` text dark; `off` never
      // registers, so it stays put.
      expect(_textColor(tester), const Color(0xFF111111));
    });
  });

  group('GlassA11yMode.warnOnly', () {
    testWidgets('renders the same static color as off', (tester) async {
      // High-contrast pairing so this test (about color inertia, not the
      // contrast check itself) doesn't also trip the warning diagnostic.
      const text = AdaptiveGlassText(
        'Settings',
        lightColor: Color(0xFF000000),
        darkColor: Color(0xFFFFFFFF),
      );
      await tester.pumpWidget(_pipeline(
        content: const ColoredBox(color: Color(0xFFFFFFFF)),
        text: text,
        mode: GlassA11yMode.warnOnly,
      ));
      expect(_textColor(tester), const Color(0xFF000000));

      final scopeState = tester.state<GlassContentAwareScopeState>(
          find.byType(GlassContentAwareScope));
      await _settleSample(tester, scopeState);
      await tester.pump();

      expect(_textColor(tester), const Color(0xFF000000));
    });

    testWidgets(
        'logs a contrast warning when the static color fails against the '
        'sampled backdrop', (tester) async {
      // Near-black text over near-black content: contrast ratio ~1:1, well
      // under the 4.5:1 default minimum.
      const text = AdaptiveGlassText(
        'Settings',
        lightColor: Color(0xFF050505),
        darkColor: Color(0xFFFFFFFF),
      );
      await tester.pumpWidget(_pipeline(
        content: const ColoredBox(color: Color(0xFF000000)),
        text: text,
        mode: GlassA11yMode.warnOnly,
      ));

      FlutterErrorDetails? captured;
      final original = FlutterError.onError;
      FlutterError.onError = (details) => captured = details;

      try {
        final scopeState = tester.state<GlassContentAwareScopeState>(
            find.byType(GlassContentAwareScope));
        await _settleSample(tester, scopeState);
        await tester.pump();

        expect(captured, isNotNull);
        expect(captured!.exception.toString(), contains('insufficient contrast'));
      } finally {
        FlutterError.onError = original;
      }
    });

    testWidgets('does not warn when the static color has sufficient contrast',
        (tester) async {
      const text = AdaptiveGlassText(
        'Settings',
        lightColor: Color(0xFF000000), // black on white: high contrast
        darkColor: Color(0xFFFFFFFF),
      );
      await tester.pumpWidget(_pipeline(
        content: const ColoredBox(color: Color(0xFFFFFFFF)),
        text: text,
        mode: GlassA11yMode.warnOnly,
      ));

      FlutterErrorDetails? captured;
      final original = FlutterError.onError;
      FlutterError.onError = (details) => captured = details;

      try {
        final scopeState = tester.state<GlassContentAwareScopeState>(
            find.byType(GlassContentAwareScope));
        await _settleSample(tester, scopeState);
        await tester.pump();

        expect(captured, isNull);
      } finally {
        FlutterError.onError = original;
      }
    });
  });
}
