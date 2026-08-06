/// Demo for the Phase 6 long-tail widgets: GlassAvatar, GlassRatingBar,
/// GlassTimeline, GlassSkeletonLoader.
///
/// Run standalone:
///   flutter run -t example/lib/demos/glass_new_components_demo.dart
library;

import 'package:flutter/cupertino.dart';

import 'package:flutter_liquid_glass_widgets/liquid_glass_widgets.dart';

import 'package:liquid_glass_widgets_example/theme/app_theme.dart';

class GlassNewComponentsDemo extends StatefulWidget {
  const GlassNewComponentsDemo({super.key});

  @override
  State<GlassNewComponentsDemo> createState() =>
      _GlassNewComponentsDemoState();
}

class _GlassNewComponentsDemoState extends State<GlassNewComponentsDemo> {
  double _rating = 3.5;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/wallpaper_dark.jpg', fit: BoxFit.cover),
          Container(color: CupertinoColors.black.withValues(alpha: 0.25)),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Long-tail Components',
                    style: AppType.display(isDark: true, size: 26, color: CupertinoColors.white),
                  ),
                  const SizedBox(height: 24),

                  const _Label('GlassAvatar'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const GlassAvatar(
                        backgroundColor: CupertinoColors.systemBlue,
                        child: Text('JD'),
                      ),
                      const SizedBox(width: 12),
                      GlassAvatar(
                        radius: 24,
                        backgroundColor: CupertinoColors.systemPurple,
                        child: const Icon(CupertinoIcons.person_fill),
                      ),
                      const SizedBox(width: 12),
                      const GlassAvatar(radius: 24),
                    ],
                  ),
                  const SizedBox(height: 28),

                  const _Label('GlassRatingBar'),
                  const SizedBox(height: 10),
                  GlassRatingBar(
                    value: _rating,
                    allowHalfRating: true,
                    onChanged: (v) => setState(() => _rating = v),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_rating.toStringAsFixed(1)} / 5',
                    style: TextStyle(
                      color: CupertinoColors.white.withValues(alpha: 0.7),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 28),

                  const _Label('GlassSkeletonLoader'),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const GlassSkeletonLoader.circle(diameter: 44),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            GlassSkeletonLoader.text(width: 160),
                            SizedBox(height: 8),
                            GlassSkeletonLoader.text(width: 110),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  const _Label('GlassTimeline'),
                  const SizedBox(height: 10),
                  GlassTimeline(
                    items: [
                      GlassTimelineItem(
                        title: 'Order placed',
                        time: '9:41 AM',
                        icon: CupertinoIcons.cart,
                      ),
                      GlassTimelineItem(
                        title: 'Shipped',
                        subtitle: 'Via Express Courier',
                        time: 'Yesterday',
                        icon: CupertinoIcons.cube_box,
                      ),
                      GlassTimelineItem(
                        title: 'Out for delivery',
                        time: 'Today',
                        icon: CupertinoIcons.car_detailed,
                        color: CupertinoColors.activeOrange,
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: CupertinoColors.white.withValues(alpha: 0.55),
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
      ),
    );
  }
}
