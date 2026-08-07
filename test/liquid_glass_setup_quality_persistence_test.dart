// Coverage for LiquidGlassWidgets.wrap()'s qualityPersistence wiring and
// LiquidGlassWidgets.initialize()'s optional persisted-read await.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_liquid_glass_widgets/liquid_glass_widgets.dart';

class _FakeQualityStore extends GlassQualityStore {
  _FakeQualityStore({GlassQuality? initial}) : _stored = initial;

  GlassQuality? _stored;
  final List<GlassQuality> writes = [];

  @override
  Future<GlassQuality?> read() async => _stored;

  @override
  Future<void> write(GlassQuality quality) async {
    _stored = quality;
    writes.add(quality);
  }
}

void main() {
  group('LiquidGlassWidgets.wrap — qualityPersistence', () {
    testWidgets('seeds initialQuality from a resolved persisted value',
        (tester) async {
      final persistence =
          GlassQualityPersistence(_FakeQualityStore(initial: GlassQuality.minimal));
      await persistence.ready; // guarantee resolvedQualityOrNull is populated

      final wrapped = LiquidGlassWidgets.wrap(
        child: const SizedBox.shrink(),
        adaptiveQuality: true,
        qualityPersistence: persistence,
      );
      await tester.pumpWidget(MaterialApp(home: wrapped));
      await tester.pump();

      final scope = tester.widget<GlassAdaptiveScope>(
        find.byType(GlassAdaptiveScope),
      );
      expect(scope.initialQuality, GlassQuality.minimal);
    });

    testWidgets(
        'falls back to normal behavior when nothing was ever persisted',
        (tester) async {
      final persistence = GlassQualityPersistence(_FakeQualityStore());
      await persistence.ready;

      final wrapped = LiquidGlassWidgets.wrap(
        child: const SizedBox.shrink(),
        adaptiveQuality: true,
        qualityPersistence: persistence,
      );
      await tester.pumpWidget(MaterialApp(home: wrapped));
      await tester.pump();

      final scope = tester.widget<GlassAdaptiveScope>(
        find.byType(GlassAdaptiveScope),
      );
      expect(scope.initialQuality, isNull);
    });

    testWidgets(
        'an explicit adaptiveConfig.initialQuality wins over the persisted value',
        (tester) async {
      final persistence =
          GlassQualityPersistence(_FakeQualityStore(initial: GlassQuality.minimal));
      await persistence.ready;

      final wrapped = LiquidGlassWidgets.wrap(
        child: const SizedBox.shrink(),
        adaptiveQuality: true,
        adaptiveConfig:
            const GlassAdaptiveScopeConfig(initialQuality: GlassQuality.premium),
        qualityPersistence: persistence,
      );
      await tester.pumpWidget(MaterialApp(home: wrapped));
      await tester.pump();

      final scope = tester.widget<GlassAdaptiveScope>(
        find.byType(GlassAdaptiveScope),
      );
      expect(scope.initialQuality, GlassQuality.premium);
    });

    testWidgets('onQualityChanged persists the new quality to the store',
        (tester) async {
      final store = _FakeQualityStore();
      final persistence = GlassQualityPersistence(store);
      await persistence.ready;

      final wrapped = LiquidGlassWidgets.wrap(
        child: const SizedBox.shrink(),
        adaptiveQuality: true,
        qualityPersistence: persistence,
      );
      await tester.pumpWidget(MaterialApp(home: wrapped));
      await tester.pump();

      final scope = tester.widget<GlassAdaptiveScope>(
        find.byType(GlassAdaptiveScope),
      );
      // Simulate GlassAdaptiveScope settling on a new quality, the same way
      // it would internally after Phase 2/3 — exercises the wrap()-built
      // closure directly rather than the adapter's frame-timing internals.
      scope.onQualityChanged?.call(GlassQuality.standard, GlassQuality.premium);
      await tester.pump();

      expect(store.writes, [GlassQuality.premium]);
    });

    testWidgets(
        'onQualityChanged still calls a user-provided callback alongside persistence',
        (tester) async {
      final persistence = GlassQualityPersistence(_FakeQualityStore());
      await persistence.ready;
      final events = <(GlassQuality, GlassQuality)>[];

      final wrapped = LiquidGlassWidgets.wrap(
        child: const SizedBox.shrink(),
        adaptiveQuality: true,
        adaptiveConfig: GlassAdaptiveScopeConfig(
          onQualityChanged: (from, to) => events.add((from, to)),
        ),
        qualityPersistence: persistence,
      );
      await tester.pumpWidget(MaterialApp(home: wrapped));
      await tester.pump();

      final scope = tester.widget<GlassAdaptiveScope>(
        find.byType(GlassAdaptiveScope),
      );
      scope.onQualityChanged?.call(GlassQuality.minimal, GlassQuality.standard);
      await tester.pump();

      expect(events, [(GlassQuality.minimal, GlassQuality.standard)]);
    });

    testWidgets('qualityPersistence is a no-op when adaptiveQuality is false',
        (tester) async {
      final persistence = GlassQualityPersistence(
        _FakeQualityStore(initial: GlassQuality.minimal),
      );
      await persistence.ready;

      final wrapped = LiquidGlassWidgets.wrap(
        child: const SizedBox.shrink(),
        qualityPersistence: persistence,
      );
      await tester.pumpWidget(MaterialApp(home: wrapped));
      await tester.pump();

      expect(find.byType(GlassAdaptiveScope), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('LiquidGlassWidgets.initialize — qualityPersistence', () {
    testWidgets(
        'awaiting initialize() guarantees the persisted read has resolved',
        (tester) async {
      final store = _FakeQualityStore(initial: GlassQuality.premium);
      final persistence = GlassQualityPersistence(store);

      await tester.runAsync(() async {
        await LiquidGlassWidgets.initialize(
          enablePerformanceMonitor: false,
          qualityPersistence: persistence,
        );
      });

      expect(persistence.resolvedQualityOrNull, GlassQuality.premium);
    });
  });
}
