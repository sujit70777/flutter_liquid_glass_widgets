/// GlassCommandPalette Demo — Spotlight/Raycast-style ⌘K / Ctrl+K overlay.
///
/// Wraps the page in [GlassCommandPaletteScope] so the global shortcut works
/// live, and also exposes a button for [GlassCommandPalette.show] directly.
/// Selecting a command logs it below so the callback wiring is visible.
///
/// Run standalone:
///   flutter run -t example/lib/demos/glass_command_palette_demo.dart
library;

import 'package:flutter/cupertino.dart';

import 'package:flutter_liquid_glass_widgets/liquid_glass_widgets.dart';

import 'package:liquid_glass_widgets_example/theme/app_theme.dart';

class GlassCommandPaletteDemo extends StatefulWidget {
  const GlassCommandPaletteDemo({super.key});

  @override
  State<GlassCommandPaletteDemo> createState() =>
      _GlassCommandPaletteDemoState();
}

class _GlassCommandPaletteDemoState extends State<GlassCommandPaletteDemo> {
  final List<String> _log = [];

  void _run(String label) {
    setState(() => _log.insert(0, label));
  }

  List<GlassCommand> get _commands => [
        GlassCommand(
          id: 'new-file',
          label: 'New File',
          icon: const Icon(CupertinoIcons.doc),
          shortcutLabel: '⌘N',
          onSelect: () => _run('New File'),
        ),
        GlassCommand(
          id: 'open-file',
          label: 'Open File…',
          icon: const Icon(CupertinoIcons.folder),
          shortcutLabel: '⌘O',
          onSelect: () => _run('Open File…'),
        ),
        GlassCommand(
          id: 'toggle-theme',
          label: 'Toggle Theme',
          icon: const Icon(CupertinoIcons.moon_stars),
          subtitle: 'Switch between light and dark appearance',
          keywords: const ['dark mode', 'light mode', 'appearance'],
          onSelect: () => _run('Toggle Theme'),
        ),
        GlassCommand(
          id: 'search-docs',
          label: 'Search Documentation',
          icon: const Icon(CupertinoIcons.search),
          keywords: const ['help', 'docs'],
          onSelect: () => _run('Search Documentation'),
        ),
        GlassCommand(
          id: 'share',
          label: 'Share…',
          icon: const Icon(CupertinoIcons.share),
          shortcutLabel: '⌘⇧S',
          onSelect: () => _run('Share…'),
        ),
        GlassCommand(
          id: 'delete',
          label: 'Delete',
          icon: const Icon(CupertinoIcons.trash),
          onSelect: () => _run('Delete'),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return GlassCommandPaletteScope(
      commands: _commands,
      child: CupertinoPageScaffold(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/wallpaper.jpg', fit: BoxFit.cover),
            Container(color: CupertinoColors.black.withValues(alpha: 0.25)),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                    'GlassCommandPalette',
                    style: AppType.display(isDark: true, size: 26, color: CupertinoColors.white),
                  ),
                    const SizedBox(height: 6),
                    Text(
                      'Press ⌘K (macOS/web) or Ctrl+K to open it anywhere on '
                      'this page — or use the button below. Type to filter, '
                      '↑/↓ to move, Enter to activate, Esc to dismiss.',
                      style: TextStyle(
                        color: CupertinoColors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    GlassButton.custom(
                      onTap: () => GlassCommandPalette.show(
                        context,
                        commands: _commands,
                      ),
                      shape: const LiquidRoundedRectangle(borderRadius: 14),
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(CupertinoIcons.command,
                                color: CupertinoColors.white, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Open Command Palette',
                              style: TextStyle(
                                color: CupertinoColors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_log.isNotEmpty) ...[
                      Text(
                        'Activated',
                        style: TextStyle(
                          color: CupertinoColors.white.withValues(alpha: 0.5),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _log.length,
                          itemBuilder: (context, index) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              '• ${_log[index]}',
                              style: const TextStyle(
                                color: CupertinoColors.white,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
