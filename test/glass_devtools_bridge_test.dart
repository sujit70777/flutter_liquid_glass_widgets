import 'package:flutter_liquid_glass_widgets/glass_devtools_bridge.dart';
import 'package:flutter_liquid_glass_widgets/types/glass_quality.dart';
import 'package:flutter_liquid_glass_widgets/types/glass_quality_change_reason.dart';
import 'package:flutter_liquid_glass_widgets/utils/glass_quality_adapter.dart';
import 'package:flutter_liquid_glass_widgets/widgets/shared/glass_adaptive_scope.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GlassDevToolsBridge.debugEncode', () {
    test('encodes "unavailable" when there is no diagnostic yet', () {
      expect(GlassDevToolsBridge.debugEncode(null), '{"available":false}');
    });

    test('encodes required fields', () {
      const diagnostic = GlassAdaptiveDiagnostic(
        from: GlassQuality.standard,
        to: GlassQuality.premium,
        reason: GlassQualityChangeReason.warmupComplete,
        phase: AdaptivePhase.runtime,
      );

      final json = GlassDevToolsBridge.debugEncode(diagnostic);

      expect(json, contains('"available":true'));
      expect(json, contains('"from":"standard"'));
      expect(json, contains('"to":"premium"'));
      expect(json, contains('"reason":"warmupComplete"'));
      expect(json, contains('"phase":"runtime"'));
    });

    test('includes optional timing fields when present', () {
      const diagnostic = GlassAdaptiveDiagnostic(
        from: GlassQuality.premium,
        to: GlassQuality.standard,
        reason: GlassQualityChangeReason.thermalDegradation,
        phase: AdaptivePhase.runtime,
        p75Ms: 12.5,
        p95Ms: 24.75,
        framesMeasured: 90,
      );

      final json = GlassDevToolsBridge.debugEncode(diagnostic);

      expect(json, contains('"p75Ms":12.5'));
      expect(json, contains('"p95Ms":24.75'));
      expect(json, contains('"framesMeasured":90'));
    });

    test('omits optional fields when null', () {
      const diagnostic = GlassAdaptiveDiagnostic(
        from: GlassQuality.minimal,
        to: GlassQuality.standard,
        reason: GlassQualityChangeReason.warmupComplete,
        phase: AdaptivePhase.warmup,
      );

      final json = GlassDevToolsBridge.debugEncode(diagnostic);

      expect(json, isNot(contains('p75Ms')));
      expect(json, isNot(contains('p95Ms')));
      expect(json, isNot(contains('framesMeasured')));
    });
  });

  group('GlassDevToolsBridge.record', () {
    test('records the diagnostic and the service extension handler reflects it',
        () {
      const diagnostic = GlassAdaptiveDiagnostic(
        from: GlassQuality.standard,
        to: GlassQuality.minimal,
        reason: GlassQualityChangeReason.thermalDegradation,
        phase: AdaptivePhase.runtime,
        p95Ms: 30.0,
        framesMeasured: 60,
      );

      GlassDevToolsBridge.record(diagnostic);

      expect(GlassDevToolsBridge.debugLast, diagnostic);
    });

    test('debugHandleQuery returns the handler\'s response for the current state',
        () async {
      const diagnostic = GlassAdaptiveDiagnostic(
        from: GlassQuality.minimal,
        to: GlassQuality.premium,
        reason: GlassQualityChangeReason.warmupComplete,
        phase: AdaptivePhase.runtime,
        p75Ms: 8.0,
        framesMeasured: 30,
      );
      GlassDevToolsBridge.record(diagnostic);

      final response = await GlassDevToolsBridge.debugHandleQuery();

      expect(response.result, GlassDevToolsBridge.debugEncode(diagnostic));
      expect(response.errorCode, isNull);
    });
  });
}
