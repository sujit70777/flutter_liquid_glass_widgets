/// "Aurora Glass" — the example app's own visual identity.
///
/// A distinct design language for the shell around the widget catalog and
/// this repo's own demos (Command Palette, Dock, Calendar, Chart,
/// Long-tail Components) — separate from the Apple-app *recreations*
/// (Music/Messages/Podcasts/News/Lock Screen), which intentionally stay
/// pixel-faithful to their real-world counterparts and are untouched here.
library;

import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

/// The app's color palette. A restrained "violet → cyan → magenta" aurora
/// system used consistently instead of a different saturated gradient per
/// card — the thing that reads as "designed" rather than "demo".
abstract final class AuroraColors {
  /// Near-black canvas base.
  static const Color ink = Color(0xFF07050D);

  /// Slightly lifted surface, for glass panel fills.
  static const Color surface = Color(0xFF0F0B1A);

  static const Color violet = Color(0xFF7C3AED);
  static const Color indigo = Color(0xFF6366F1);
  static const Color cyan = Color(0xFF06B6D4);
  static const Color skyBlue = Color(0xFF38BDF8);
  static const Color magenta = Color(0xFFEC4899);
  static const Color amber = Color(0xFFF59E0B);
  static const Color emerald = Color(0xFF10B981);

  /// Primary brand gradient — hero text, primary CTAs, active states.
  static const List<Color> aurora = [violet, skyBlue, magenta];

  /// Muted line color for hairline borders on glass panels.
  static Color hairline(bool isDark) =>
      isDark ? CupertinoColors.white.withValues(alpha: 0.10) : CupertinoColors.black.withValues(alpha: 0.08);

  /// Primary text color per brightness.
  static Color textPrimary(bool isDark) =>
      isDark ? const Color(0xFFF5F3FA) : const Color(0xFF141019);

  /// Secondary/muted text color per brightness.
  static Color textSecondary(bool isDark) => isDark
      ? CupertinoColors.white.withValues(alpha: 0.62)
      : CupertinoColors.black.withValues(alpha: 0.56);

  /// Tertiary/caption text color per brightness.
  static Color textTertiary(bool isDark) => isDark
      ? CupertinoColors.white.withValues(alpha: 0.40)
      : CupertinoColors.black.withValues(alpha: 0.36);
}

/// Typography — Space Grotesk for display/headings (geometric, distinctive),
/// Inter for body/UI (clean, highly legible), a mono face for small
/// eyebrow/category labels (a crafted, technical accent).
abstract final class AppType {
  static TextStyle display({
    required bool isDark,
    double size = 34,
    FontWeight weight = FontWeight.w700,
    double letterSpacing = -0.8,
    Color? color,
  }) =>
      GoogleFonts.spaceGrotesk(
        fontSize: size,
        fontWeight: weight,
        letterSpacing: letterSpacing,
        height: 1.05,
        color: color ?? AuroraColors.textPrimary(isDark),
      );

  static TextStyle heading({
    required bool isDark,
    double size = 20,
    FontWeight weight = FontWeight.w600,
    Color? color,
  }) =>
      GoogleFonts.spaceGrotesk(
        fontSize: size,
        fontWeight: weight,
        letterSpacing: -0.3,
        color: color ?? AuroraColors.textPrimary(isDark),
      );

  static TextStyle body({
    required bool isDark,
    double size = 15,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double height = 1.4,
  }) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: weight,
        height: height,
        color: color ?? AuroraColors.textSecondary(isDark),
      );

  static TextStyle label({
    required bool isDark,
    double size = 13,
    FontWeight weight = FontWeight.w600,
    Color? color,
  }) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: weight,
        color: color ?? AuroraColors.textPrimary(isDark),
      );

  /// Small uppercase "eyebrow" label in a mono face — the crafted, technical
  /// accent used above section headings and on category chips.
  static TextStyle eyebrow({
    required bool isDark,
    double size = 11,
    Color? color,
  }) =>
      GoogleFonts.jetBrainsMono(
        fontSize: size,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.6,
        color: color ?? AuroraColors.textTertiary(isDark),
      );
}

/// Reusable "glass panel" decoration: a colorful tinted fill with a real
/// elevation shadow, so cards stay visible in both light and dark mode
/// (a flat 6%-alpha tint on a near-white light background was invisible)
/// and read as lifted glass rather than a flat rectangle.
BoxDecoration auroraPanelDecoration({
  required bool isDark,
  double radius = 20,
  Color? tint,
}) {
  final accent = tint ?? AuroraColors.violet;
  if (isDark) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      color: Color.alphaBlend(
        accent.withValues(alpha: 0.14),
        AuroraColors.surface,
      ),
      border: Border.all(color: accent.withValues(alpha: 0.32)),
      boxShadow: [
        BoxShadow(
          color: accent.withValues(alpha: 0.16),
          blurRadius: 26,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: CupertinoColors.black.withValues(alpha: 0.45),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }
  return BoxDecoration(
    borderRadius: BorderRadius.circular(radius),
    color: Color.alphaBlend(
      accent.withValues(alpha: 0.16),
      CupertinoColors.white,
    ),
    border: Border.all(color: accent.withValues(alpha: 0.38)),
    boxShadow: [
      BoxShadow(
        color: accent.withValues(alpha: 0.22),
        blurRadius: 22,
        offset: const Offset(0, 10),
      ),
      BoxShadow(
        color: CupertinoColors.black.withValues(alpha: 0.08),
        blurRadius: 10,
        offset: const Offset(0, 3),
      ),
    ],
  );
}

/// A small colored icon chip used inside catalog cards, instead of tinting
/// the whole card.
class AuroraIconChip extends StatelessWidget {
  const AuroraIconChip({
    super.key,
    required this.icon,
    required this.color,
    this.size = 40,
  });

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.32),
        color: color.withValues(alpha: 0.16),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Icon(icon, color: color, size: size * 0.52),
    );
  }
}
