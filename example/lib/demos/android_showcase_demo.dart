/// Android Showcase — a handful of recognizably-Android UI patterns
/// (Quick Settings toggles, notification shade, Material 3 nav bar, FAB)
/// rendered in the liquid glass aesthetic, alongside this example app's
/// Apple-app recreations. Not a recreation of one specific Android app —
/// Android's design language is more about system patterns (Quick Settings,
/// notification shade, Material You) than any one app, so this showcases
/// those patterns instead.
library;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;

import 'package:liquid_glass_widgets_example/theme/app_theme.dart';

class AndroidShowcaseTab extends StatefulWidget {
  const AndroidShowcaseTab({super.key});

  @override
  State<AndroidShowcaseTab> createState() => _AndroidShowcaseTabState();
}

class _QuickToggle {
  const _QuickToggle(this.icon, this.label, this.color);
  final IconData icon;
  final String label;
  final Color color;
}

class _AndroidShowcaseTabState extends State<AndroidShowcaseTab> {
  final Set<int> _enabled = {0, 2};
  int _navIndex = 0;

  static const _toggles = [
    _QuickToggle(Icons.wifi, 'Wi-Fi', AuroraColors.cyan),
    _QuickToggle(Icons.bluetooth, 'Bluetooth', AuroraColors.violet),
    _QuickToggle(Icons.airplanemode_active, 'Airplane', AuroraColors.amber),
    _QuickToggle(Icons.flashlight_on, 'Flashlight', AuroraColors.emerald),
    _QuickToggle(Icons.do_not_disturb_on, 'Focus', AuroraColors.magenta),
    _QuickToggle(Icons.screen_rotation, 'Auto-rotate', AuroraColors.indigo),
  ];

  static const _navItems = [
    (Icons.home_filled, 'Home'),
    (Icons.explore, 'Explore'),
    (Icons.favorite, 'Saved'),
    (Icons.person, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ANDROID · MATERIAL',
                      style: AppType.eyebrow(isDark: isDark)),
                  const SizedBox(height: 10),
                  Text('System UI',
                      style: AppType.display(isDark: isDark, size: 32)),
                  const SizedBox(height: 6),
                  Text(
                    'Quick Settings, notifications, and Material 3 nav — '
                    'the same shader glass, a different platform language.',
                    style: AppType.body(isDark: isDark, size: 15),
                  ),
                  const SizedBox(height: 28),

                  Text('Quick Settings',
                      style: AppType.heading(isDark: isDark, size: 17)),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _toggles.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.95,
                    ),
                    itemBuilder: (context, index) {
                      final toggle = _toggles[index];
                      final on = _enabled.contains(index);
                      return GestureDetector(
                        onTap: () => setState(() {
                          if (on) {
                            _enabled.remove(index);
                          } else {
                            _enabled.add(index);
                          }
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          decoration: auroraPanelDecoration(
                            isDark: isDark,
                            radius: 18,
                            tint: on ? toggle.color : null,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                toggle.icon,
                                color: on
                                    ? toggle.color
                                    : AuroraColors.textTertiary(isDark),
                                size: 26,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                toggle.label,
                                style: AppType.label(isDark: isDark, size: 11),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 28),

                  Text('Notifications',
                      style: AppType.heading(isDark: isDark, size: 17)),
                  const SizedBox(height: 12),
                  _NotificationCard(
                    isDark: isDark,
                    color: AuroraColors.cyan,
                    icon: Icons.chat_bubble,
                    app: 'Messenger',
                    title: '2 new messages',
                    body: 'Sam: Are we still on for the demo tomorrow?',
                    time: 'now',
                  ),
                  const SizedBox(height: 10),
                  _NotificationCard(
                    isDark: isDark,
                    color: AuroraColors.emerald,
                    icon: Icons.system_update,
                    app: 'System',
                    title: 'Update available',
                    body: 'A software update is ready to install.',
                    time: '12m',
                  ),
                  const SizedBox(height: 28),

                  Text('Material 3 Nav Bar',
                      style: AppType.heading(isDark: isDark, size: 17)),
                  const SizedBox(height: 12),
                  Container(
                    decoration: auroraPanelDecoration(
                      isDark: isDark,
                      radius: 24,
                      tint: AuroraColors.violet,
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        for (var i = 0; i < _navItems.length; i++)
                          GestureDetector(
                            onTap: () => setState(() => _navIndex = i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: i == _navIndex
                                    ? AuroraColors.violet
                                        .withValues(alpha: 0.25)
                                    : null,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _navItems[i].$1,
                                    size: 22,
                                    color: i == _navIndex
                                        ? AuroraColors.violet
                                        : AuroraColors.textTertiary(isDark),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _navItems[i].$2,
                                    style: AppType.label(
                                      isDark: isDark,
                                      size: 10,
                                      color: i == _navIndex
                                          ? AuroraColors.violet
                                          : AuroraColors.textTertiary(isDark),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.isDark,
    required this.color,
    required this.icon,
    required this.app,
    required this.title,
    required this.body,
    required this.time,
  });

  final bool isDark;
  final Color color;
  final IconData icon;
  final String app;
  final String title;
  final String body;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: auroraPanelDecoration(isDark: isDark, radius: 18, tint: color),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AuroraIconChip(icon: icon, color: color, size: 34),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        app,
                        style: AppType.label(isDark: isDark, size: 12),
                      ),
                    ),
                    Text(
                      time,
                      style: AppType.body(isDark: isDark, size: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  title,
                  style: AppType.heading(isDark: isDark, size: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: AppType.body(isDark: isDark, size: 12.5),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
