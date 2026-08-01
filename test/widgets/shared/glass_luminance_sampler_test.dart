// Behavior tests for GlassLuminanceSampler and the underlying
// GlassContentAwareScopeState.luminanceAt query it wraps:
//   - null with no enclosing GlassContentAwareScope
//   - null before any capture has completed
//   - a sensible average luminance once a capture completes, even with zero
//     GlassContentAwareBrightness consumers registered (on-demand queries
//     must keep sampling alive on their own)
//   - null for a rect outside the sampled content region

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_liquid_glass_widgets/liquid_glass_widgets.dart';

/// Runs one deterministic sample to completion (mirrors the helper in
/// glass_content_aware_scope_test.dart — toImage only completes under a real
/// event loop).
Future<void> _settleSample(
  WidgetTester tester,
  GlassContentAwareScopeState scope,
) {
  return tester.runAsync(() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await scope.sampleNow();
  });
}

void main() {
  testWidgets('returns null with no enclosing GlassContentAwareScope',
      (tester) async {
    late BuildContext capturedContext;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        capturedContext = context;
        return const SizedBox();
      }),
    ));

    expect(
      GlassLuminanceSampler.sampleLuminance(
        capturedContext,
        const Rect.fromLTWH(0, 0, 10, 10),
      ),
      isNull,
    );
  });

  testWidgets('returns null before any capture has completed',
      (tester) async {
    late BuildContext innerContext;
    await tester.pumpWidget(MaterialApp(
      home: GlassContentAwareScope(
        child: GlassContentAwareContent(
          child: Builder(builder: (context) {
            innerContext = context;
            return const ColoredBox(color: Color(0xFF000000));
          }),
        ),
      ),
    ));

    expect(
      GlassLuminanceSampler.sampleLuminance(
        innerContext,
        const Rect.fromLTWH(0, 0, 10, 10),
      ),
      isNull,
    );
  });

  testWidgets(
      'returns the sampled luminance once a capture completes, with no '
      'GlassContentAwareBrightness consumer registered', (tester) async {
    late BuildContext innerContext;
    await tester.pumpWidget(MaterialApp(
      home: GlassContentAwareScope(
        child: GlassContentAwareContent(
          child: Builder(builder: (context) {
            innerContext = context;
            return const ColoredBox(color: Color(0xFF000000));
          }),
        ),
      ),
    ));

    final rect = const Rect.fromLTWH(0, 0, 20, 20);

    // First call: no capture yet, but requests one.
    expect(GlassLuminanceSampler.sampleLuminance(innerContext, rect), isNull);

    final scopeState = tester.state<GlassContentAwareScopeState>(
        find.byType(GlassContentAwareScope));
    await _settleSample(tester, scopeState);
    await tester.pump();

    final luminance =
        GlassLuminanceSampler.sampleLuminance(innerContext, rect);
    expect(luminance, isNotNull);
    expect(luminance, closeTo(0.0, 0.05)); // black content
  });

  testWidgets('returns null for a rect outside the sampled content region',
      (tester) async {
    late BuildContext innerContext;
    await tester.pumpWidget(MaterialApp(
      home: GlassContentAwareScope(
        child: GlassContentAwareContent(
          child: Builder(builder: (context) {
            innerContext = context;
            return const SizedBox(
              width: 100,
              height: 100,
              child: ColoredBox(color: Color(0xFF000000)),
            );
          }),
        ),
      ),
    ));

    final farAwayRect = const Rect.fromLTWH(10000, 10000, 10, 10);
    GlassLuminanceSampler.sampleLuminance(innerContext, farAwayRect);

    final scopeState = tester.state<GlassContentAwareScopeState>(
        find.byType(GlassContentAwareScope));
    await _settleSample(tester, scopeState);
    await tester.pump();

    expect(
      GlassLuminanceSampler.sampleLuminance(innerContext, farAwayRect),
      isNull,
    );
  });
}
