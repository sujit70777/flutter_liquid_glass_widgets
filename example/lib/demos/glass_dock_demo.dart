/// GlassDock Demo — macOS-style magnifying dock. Best experienced with a
/// mouse/trackpad on desktop/web; touch platforms render it at rest size
/// with no magnification (MouseRegion.onHover simply never fires for touch).
///
/// Run standalone:
///   flutter run -t example/lib/demos/glass_dock_demo.dart
library;

import 'package:flutter/cupertino.dart';

import 'package:flutter_liquid_glass_widgets/liquid_glass_widgets.dart';

class GlassDockDemo extends StatefulWidget {
  const GlassDockDemo({super.key});

  @override
  State<GlassDockDemo> createState() => _GlassDockDemoState();
}

class _GlassDockDemoState extends State<GlassDockDemo> {
  String _lastTapped = 'None yet';

  @override
  Widget build(BuildContext context) {
    final items = [
      (CupertinoIcons.house_fill, 'Home'),
      (CupertinoIcons.mail_solid, 'Mail'),
      (CupertinoIcons.calendar, 'Calendar'),
      (CupertinoIcons.photo_fill, 'Photos'),
      (CupertinoIcons.music_note, 'Music'),
      (CupertinoIcons.gear_solid, 'Settings'),
    ];

    return CupertinoPageScaffold(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/wallpaper.jpg', fit: BoxFit.cover),
          Container(color: CupertinoColors.black.withValues(alpha: 0.25)),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'GlassDock',
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Move the cursor across the dock. Last tapped: $_lastTapped',
                        style: TextStyle(
                          color: CupertinoColors.white.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: GlassDock(
                    items: [
                      for (final (icon, label) in items)
                        GlassDockItem(
                          icon: Icon(icon, color: CupertinoColors.white),
                          label: label,
                          onTap: () => setState(() => _lastTapped = label),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
