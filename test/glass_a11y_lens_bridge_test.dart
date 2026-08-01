// Behavior tests for GlassContrastRule (lib/glass_a11y_lens_bridge.dart):
//   - flags Text over a glass surface whose color fails contrast against
//     the sampled backdrop
//   - does not flag Text with sufficient contrast
//   - ignores Text with no glass ancestor at all (ContrastRule's territory)
//   - produces no violations before any capture has completed (never
//     guesses, mirroring ContrastRule skipping text with no solid ancestor)

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_a11y_lens/a11y_lens.dart';
import 'package:flutter_liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:flutter_liquid_glass_widgets/glass_a11y_lens_bridge.dart';

const _shape = LiquidRoundedSuperellipse(borderRadius: 16);
const _settings = LiquidGlassSettings(
  thickness: 20,
  blur: 2,
  glassColor: Color(0x3DFFFFFF),
  lightIntensity: 0.6,
  saturation: 1.5,
);

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
  testWidgets('flags Text over glass whose color fails the sampled contrast',
      (tester) async {
    late BuildContext rootContext;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        rootContext = context;
        return GlassContentAwareScope(
          child: Stack(
            children: [
              Positioned.fill(
                child: GlassContentAwareContent(
                  child: const ColoredBox(color: Color(0xFF000000)),
                ),
              ),
              Positioned(
                left: 0,
                top: 0,
                child: AdaptiveGlass(
                  shape: _shape,
                  settings: _settings,
                  quality: GlassQuality.standard,
                  // Near-black text over near-black content: fails contrast.
                  child: const Text(
                    'Settings',
                    style: TextStyle(color: Color(0xFF050505)),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    ));

    final scopeState = tester.state<GlassContentAwareScopeState>(
        find.byType(GlassContentAwareScope));

    // GlassContrastRule has no capture to read on its very first run — that
    // run is what *requests* one (see GlassLuminanceSampler). In real usage
    // A11yLensOverlay calls check() every frame, so this warm-up happens
    // for free; here it needs to be explicit.
    A11yReport.generate(
      rootContext,
      rules: const [GlassContrastRule()],
      semanticsRules: const [],
    );
    await _settleSample(tester, scopeState);
    await tester.pump();

    final report = A11yReport.generate(
      rootContext,
      rules: const [GlassContrastRule()],
      semanticsRules: const [],
    );

    expect(report.violations, hasLength(1));
    expect(report.violations.single.ruleId, 'glass-contrast');
    expect(report.violations.single.severity, A11ySeverity.error);
  });

  testWidgets('does not flag Text with sufficient contrast', (tester) async {
    late BuildContext rootContext;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        rootContext = context;
        return GlassContentAwareScope(
          child: Stack(
            children: [
              Positioned.fill(
                child: GlassContentAwareContent(
                  child: const ColoredBox(color: Color(0xFFFFFFFF)),
                ),
              ),
              Positioned(
                left: 0,
                top: 0,
                child: AdaptiveGlass(
                  shape: _shape,
                  settings: _settings,
                  quality: GlassQuality.standard,
                  child: const Text(
                    'Settings',
                    style: TextStyle(color: Color(0xFF000000)),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    ));

    final scopeState = tester.state<GlassContentAwareScopeState>(
        find.byType(GlassContentAwareScope));

    // GlassContrastRule has no capture to read on its very first run — that
    // run is what *requests* one (see GlassLuminanceSampler). In real usage
    // A11yLensOverlay calls check() every frame, so this warm-up happens
    // for free; here it needs to be explicit.
    A11yReport.generate(
      rootContext,
      rules: const [GlassContrastRule()],
      semanticsRules: const [],
    );
    await _settleSample(tester, scopeState);
    await tester.pump();

    final report = A11yReport.generate(
      rootContext,
      rules: const [GlassContrastRule()],
      semanticsRules: const [],
    );

    expect(report.violations, isEmpty);
  });

  testWidgets('ignores Text with no glass ancestor', (tester) async {
    late BuildContext rootContext;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        rootContext = context;
        return GlassContentAwareScope(
          child: Stack(
            children: [
              Positioned.fill(
                child: GlassContentAwareContent(
                  child: const ColoredBox(color: Color(0xFF000000)),
                ),
              ),
              // Plain Text, no AdaptiveGlass/LiquidGlassLayer ancestor at all.
              const Positioned(
                left: 0,
                top: 0,
                child: Text(
                  'Settings',
                  style: TextStyle(color: Color(0xFF050505)),
                ),
              ),
            ],
          ),
        );
      }),
    ));

    final scopeState = tester.state<GlassContentAwareScopeState>(
        find.byType(GlassContentAwareScope));

    // GlassContrastRule has no capture to read on its very first run — that
    // run is what *requests* one (see GlassLuminanceSampler). In real usage
    // A11yLensOverlay calls check() every frame, so this warm-up happens
    // for free; here it needs to be explicit.
    A11yReport.generate(
      rootContext,
      rules: const [GlassContrastRule()],
      semanticsRules: const [],
    );
    await _settleSample(tester, scopeState);
    await tester.pump();

    final report = A11yReport.generate(
      rootContext,
      rules: const [GlassContrastRule()],
      semanticsRules: const [],
    );

    expect(report.violations, isEmpty);
  });

  testWidgets('produces no violations before any capture has completed',
      (tester) async {
    late BuildContext rootContext;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        rootContext = context;
        return GlassContentAwareScope(
          child: Stack(
            children: [
              Positioned.fill(
                child: GlassContentAwareContent(
                  child: const ColoredBox(color: Color(0xFF000000)),
                ),
              ),
              Positioned(
                left: 0,
                top: 0,
                child: AdaptiveGlass(
                  shape: _shape,
                  settings: _settings,
                  quality: GlassQuality.standard,
                  child: const Text(
                    'Settings',
                    style: TextStyle(color: Color(0xFF050505)),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    ));

    // No sample has been run yet.
    final report = A11yReport.generate(
      rootContext,
      rules: const [GlassContrastRule()],
      semanticsRules: const [],
    );

    expect(report.violations, isEmpty);
  });

  test('exposes a stable id and description', () {
    const rule = GlassContrastRule();
    expect(rule.id, 'glass-contrast');
    expect(rule.description, isNotEmpty);
  });
}
