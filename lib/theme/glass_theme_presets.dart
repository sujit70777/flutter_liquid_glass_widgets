import 'package:flutter/widgets.dart';

import 'glass_theme_data.dart';
import 'glass_theme_settings.dart';

/// Ready-made [GlassThemeData] presets covering the entire glass widget
/// catalog at once — drop one in via [GlassTheme] instead of tuning
/// [LiquidGlassSettings] per widget.
///
/// ```dart
/// GlassTheme(
///   data: GlassThemePresets.frostedDark,
///   child: MyApp(),
/// )
/// ```
abstract final class GlassThemePresets {
  /// Deep, heavily-frosted dark glass. Forces a dark appearance regardless
  /// of system/app brightness — for immersive, media-heavy screens (photo
  /// viewers, video players, media players) where the chrome should always
  /// read as dark glass over content.
  static GlassThemeData get frostedDark => const GlassThemeData(
        light: _frostedDarkVariant,
        dark: _frostedDarkVariant,
        brightness: Brightness.dark,
      );

  static const GlassThemeVariant _frostedDarkVariant = GlassThemeVariant(
    settings: GlassThemeSettings(
      thickness: 22.0,
      blur: 10.0,
      glassColor: Color.fromRGBO(20, 20, 30, 0.35),
      lightAngle: 2.356, // 0.75 * pi — matches the library's default 135°
      lightIntensity: 0.55,
      ambientStrength: 0.0,
      refractiveIndex: 1.25,
      saturation: 1.15,
      chromaticAberration: 0.015,
    ),
    glowColors: GlassGlowColors.fallback,
  );

  /// Bright, minimally-frosted clear glass. Forces a light appearance
  /// regardless of system/app brightness — for airy, content-forward
  /// screens (onboarding, marketing surfaces) where glass should read as
  /// transparent rather than frosted.
  static GlassThemeData get clearLight => const GlassThemeData(
        light: _clearLightVariant,
        dark: _clearLightVariant,
        brightness: Brightness.light,
      );

  static const GlassThemeVariant _clearLightVariant = GlassThemeVariant(
    settings: GlassThemeSettings(
      thickness: 8.0,
      blur: 2.0,
      glassColor: Color.fromRGBO(255, 255, 255, 0.10),
      lightAngle: 2.356,
      lightIntensity: 1.0,
      ambientStrength: 0.2,
      refractiveIndex: 1.15,
      saturation: 1.05,
      chromaticAberration: 0.01,
    ),
    glowColors: GlassGlowColors.fallback,
  );

  /// Tints every glass surface's rim and every widget's glow palette
  /// (buttons, badges, sliders, switches, ...) toward [brandColor] — the
  /// fastest way to make the whole kit read as *your* app rather than a
  /// generic demo. Unlike [frostedDark]/[clearLight], this follows the
  /// ambient light/dark mode rather than forcing one.
  static GlassThemeData tintedBrand(Color brandColor) {
    final glowColors = GlassGlowColors.fallback.copyWith(primary: brandColor);
    return GlassThemeData(
      light: GlassThemeVariant.light.copyWith(
        settings: GlassThemeVariant.light.settings?.copyWith(
          glassColor: Color.alphaBlend(
            brandColor.withValues(alpha: 0.14),
            GlassThemeVariant.light.settings!.glassColor!,
          ),
        ),
        glowColors: glowColors,
      ),
      dark: GlassThemeVariant.dark.copyWith(
        settings: GlassThemeVariant.dark.settings?.copyWith(
          glassColor: Color.alphaBlend(
            brandColor.withValues(alpha: 0.18),
            GlassThemeVariant.dark.settings!.glassColor!,
          ),
        ),
        glowColors: glowColors,
      ),
    );
  }
}
