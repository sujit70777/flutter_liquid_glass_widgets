import 'package:flutter/cupertino.dart';
import 'package:flutter_liquid_glass_widgets/theme/glass_theme.dart';
import 'package:flutter_liquid_glass_widgets/theme/glass_theme_data.dart';
import 'package:flutter_liquid_glass_widgets/theme/glass_theme_presets.dart';
import 'package:flutter_liquid_glass_widgets/widgets/containers/glass_card.dart';
import 'package:flutter_test/flutter_test.dart';

import '../shared/test_helpers.dart';

void main() {
  group('GlassThemePresets', () {
    test('frostedDark forces dark brightness for both variants', () {
      final theme = GlassThemePresets.frostedDark;
      expect(theme.brightness, Brightness.dark);
      expect(theme.light, theme.dark);
      expect(theme.light.settings?.blur, 10.0);
    });

    test('clearLight forces light brightness for both variants', () {
      final theme = GlassThemePresets.clearLight;
      expect(theme.brightness, Brightness.light);
      expect(theme.light, theme.dark);
      expect(theme.light.settings?.blur, 2.0);
    });

    test('tintedBrand sets the glow palette primary color on both variants',
        () {
      const brand = Color(0xFFFF5500);
      final theme = GlassThemePresets.tintedBrand(brand);

      expect(theme.light.glowColors?.primary, brand);
      expect(theme.dark.glowColors?.primary, brand);
    });

    test('tintedBrand does not force a fixed brightness (follows ambient)',
        () {
      final theme = GlassThemePresets.tintedBrand(const Color(0xFF00AAFF));
      expect(theme.brightness, isNull);
    });

    test('tintedBrand tints glassColor away from the untinted default', () {
      const brand = Color(0xFF00FF00);
      final theme = GlassThemePresets.tintedBrand(brand);

      expect(
        theme.light.settings?.glassColor,
        isNot(GlassThemeVariant.light.settings?.glassColor),
      );
      expect(
        theme.dark.settings?.glassColor,
        isNot(GlassThemeVariant.dark.settings?.glassColor),
      );
    });

    testWidgets('frostedDark renders without error under GlassTheme',
        (tester) async {
      await tester.pumpWidget(
        GlassTheme(
          data: GlassThemePresets.frostedDark,
          child: createTestApp(child: const GlassCard(child: SizedBox())),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(GlassCard), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tintedBrand renders without error under GlassTheme',
        (tester) async {
      await tester.pumpWidget(
        GlassTheme(
          data: GlassThemePresets.tintedBrand(const Color(0xFF7C4DFF)),
          child: createTestApp(child: const GlassCard(child: SizedBox())),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(GlassCard), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
