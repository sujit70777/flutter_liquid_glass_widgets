import 'package:flutter/cupertino.dart';

import '../../src/renderer/liquid_glass_renderer.dart';
import '../../theme/glass_theme_data.dart';
import '../../types/glass_quality.dart';
import '../shared/adaptive_liquid_glass_layer.dart';

/// A circular avatar with a liquid glass rim, showing an image, custom
/// content (e.g. initials), or a fallback icon.
///
/// ```dart
/// // Image avatar
/// GlassAvatar(image: NetworkImage(user.photoUrl))
///
/// // Initials fallback
/// GlassAvatar(
///   child: Text('JD'),
///   backgroundColor: CupertinoColors.systemBlue,
/// )
///
/// // Icon fallback (default when neither image nor child is given)
/// GlassAvatar(radius: 28)
/// ```
///
/// Combine with [GlassBadge.dot] for an online/status indicator.
class GlassAvatar extends StatelessWidget {
  /// Creates a glass avatar.
  const GlassAvatar({
    super.key,
    this.image,
    this.child,
    this.radius = 24,
    this.backgroundColor,
    this.foregroundColor,
    this.borderWidth = 1.5,
    this.settings,
    this.quality,
  });

  /// Image shown as the avatar's content. Ignored if [child] is provided.
  final ImageProvider? image;

  /// Custom content (e.g. initials `Text`), shown instead of [image].
  ///
  /// Falls back to a person icon when both this and [image] are null.
  final Widget? child;

  /// Radius of the avatar circle.
  final double radius;

  /// Fill color behind [child] / the fallback icon. Ignored when [image] is
  /// set. Defaults to the theme's primary glow color.
  final Color? backgroundColor;

  /// Color of the fallback icon / a text [child] that doesn't set its own
  /// color.
  final Color? foregroundColor;

  /// Width of the glass rim.
  final double borderWidth;

  /// Custom glass settings for the rim.
  final LiquidGlassSettings? settings;

  /// Rendering quality for the glass effect.
  final GlassQuality? quality;

  @override
  Widget build(BuildContext context) {
    final themeData = GlassThemeData.of(context);
    final glowColors = themeData.glowColorsFor(context);
    final bgColor = backgroundColor ??
        glowColors.primary ??
        CupertinoColors.systemGrey3.resolveFrom(context);
    final fgColor = foregroundColor ?? CupertinoColors.white;
    final diameter = radius * 2;

    Widget content;
    if (child != null) {
      content = DefaultTextStyle(
        style: TextStyle(
          color: fgColor,
          fontSize: radius * 0.7,
          fontWeight: FontWeight.w600,
        ),
        child: Center(child: child),
      );
    } else if (image == null) {
      content = Icon(
        CupertinoIcons.person_fill,
        color: fgColor,
        size: radius,
      );
    } else {
      content = const SizedBox.shrink();
    }

    return AdaptiveLiquidGlassLayer(
      settings: settings ??
          const LiquidGlassSettings(
            thickness: 14.0,
            blur: 3.0,
            refractiveIndex: 1.1,
            saturation: 1.1,
          ),
      quality: quality,
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: image == null ? bgColor : null,
          image: image == null
              ? null
              : DecorationImage(image: image!, fit: BoxFit.cover),
          border: Border.all(
            color: CupertinoColors.white.withValues(alpha: 0.35),
            width: borderWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withValues(alpha: 0.15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: content,
      ),
    );
  }
}
