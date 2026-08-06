import 'dart:math' as math;

import 'package:flutter_liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:liquid_glass_widgets_example/constants/glass_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:liquid_glass_widgets_example/demos/android_showcase_demo.dart';
import 'package:liquid_glass_widgets_example/apple_messages/apple_messages_demo.dart';
import 'package:liquid_glass_widgets_example/apple_music/apple_music_demo.dart';
import 'package:liquid_glass_widgets_example/apple_news/apple_news_demo.dart';
import 'package:liquid_glass_widgets_example/apple_podcasts/apple_podcasts_demo.dart';
import 'package:liquid_glass_widgets_example/apple_lockscreen/keypad_lock_screen_demo.dart';
import 'package:liquid_glass_widgets_example/demos/nav_bar_patterns_demo.dart';
import 'package:liquid_glass_widgets_example/demos/glass_calendar_picker_demo.dart';
import 'package:liquid_glass_widgets_example/demos/glass_chart_demo.dart';
import 'package:liquid_glass_widgets_example/demos/glass_command_palette_demo.dart';
import 'package:liquid_glass_widgets_example/demos/glass_dock_demo.dart';
import 'package:liquid_glass_widgets_example/demos/glass_menu_demo.dart';
import 'package:liquid_glass_widgets_example/demos/glass_new_components_demo.dart';
import 'package:liquid_glass_widgets_example/demos/glass_modal_sheet_demo.dart';
import 'package:liquid_glass_widgets_example/demos/video_player_demo.dart';
import 'package:liquid_glass_widgets_example/demos/text_field_demo.dart';
import 'package:liquid_glass_widgets_example/demos/bottom_bar_tab_width_demo.dart';
import 'package:liquid_glass_widgets_example/demos/collapse_bar_demo.dart';
import 'package:liquid_glass_widgets_example/demos/buttons_and_shadows_demo.dart';
import 'package:liquid_glass_widgets_example/demos/content_aware_brightness_demo.dart';
import 'package:liquid_glass_widgets_example/demos/indicator_parity_demo.dart';

import 'package:liquid_glass_widgets_example/demos/google_maps_demo.dart'
    show PlatformViewDemo;
import 'package:liquid_glass_widgets_example/pages/containers_page.dart';
import 'package:liquid_glass_widgets_example/pages/feedback_page.dart';
import 'package:liquid_glass_widgets_example/pages/input_page.dart';
import 'package:liquid_glass_widgets_example/pages/interactive_page.dart';
import 'package:liquid_glass_widgets_example/pages/overlays_page.dart';
import 'package:liquid_glass_widgets_example/pages/surfaces_page.dart';
import 'package:liquid_glass_widgets_example/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();
  runApp(LiquidGlassWidgets.wrap(child: const AppleLiquidGlassShowcaseApp()));
}

class AppleLiquidGlassShowcaseApp extends StatefulWidget {
  const AppleLiquidGlassShowcaseApp({super.key});

  @override
  State<AppleLiquidGlassShowcaseApp> createState() =>
      _AppleLiquidGlassShowcaseAppState();
}

class _AppleLiquidGlassShowcaseAppState
    extends State<AppleLiquidGlassShowcaseApp> {
  /// Global brightness toggle — shared via [_BrightnessScope].
  Brightness _brightness = Brightness.dark;

  void _toggleBrightness() {
    setState(() {
      _brightness =
          _brightness == Brightness.dark ? Brightness.light : Brightness.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _brightness == Brightness.dark;

    return _BrightnessScope(
      brightness: _brightness,
      toggleBrightness: _toggleBrightness,
      child: CupertinoApp(
        title: 'Liquid Glass Widgets',
        theme: CupertinoThemeData(
          brightness: _brightness,
        ),
        // Demo pages use Material widgets (Scaffold, showModalBottomSheet)
        // that require these localizations. Not needed for glass widgets.
        localizationsDelegates: const [
          DefaultMaterialLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
        // Provide a matching Material Theme for any Scaffold widgets in demo pages.
        builder: (context, child) => Theme(
          data: isDark
              ? ThemeData.dark(useMaterial3: true)
              : ThemeData.light(useMaterial3: true),
          child: child!,
        ),
        home: const ShowcaseHomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

/// Inherited widget exposing the current [Brightness] and a toggle callback
/// to any descendant widget in the example app.
class _BrightnessScope extends InheritedWidget {
  const _BrightnessScope({
    required this.brightness,
    required this.toggleBrightness,
    required super.child,
  });

  final Brightness brightness;
  final VoidCallback toggleBrightness;

  static _BrightnessScope of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_BrightnessScope>()!;
  }

  @override
  bool updateShouldNotify(_BrightnessScope oldWidget) =>
      brightness != oldWidget.brightness;
}

// =============================================================================
// Home Page — GlassBottomBar as hero + content tabs
// =============================================================================

class ShowcaseHomePage extends StatefulWidget {
  const ShowcaseHomePage({super.key});

  @override
  State<ShowcaseHomePage> createState() => _ShowcaseHomePageState();
}

class _ShowcaseHomePageState extends State<ShowcaseHomePage> {
  int _selectedTab = 0;
  Widget? _activeDestination;

  void _openDestination(Widget destination) {
    setState(() => _activeDestination = destination);
  }

  void _closeDestination() {
    setState(() => _activeDestination = null);
  }

  static const _tabs = [
    GlassTab(
      label: 'Explore',
      icon: Icon(CupertinoIcons.wand_stars),
      activeIcon: Icon(CupertinoIcons.wand_stars),
    ),
    GlassTab(
      label: 'Widgets',
      icon: Icon(CupertinoIcons.hexagon),
      activeIcon: Icon(CupertinoIcons.hexagon_fill),
    ),
    GlassTab(
      label: 'Android',
      icon: Icon(Icons.android_outlined, size: 26),
      activeIcon: Icon(Icons.android, size: 26),
    ),
    GlassTab(
      // Kept as the Apple logo, unlike the other three — this tab is
      // specifically the Apple-app recreation gallery, so it's the one
      // icon that's more accurate unchanged than swapped.
      label: 'IOS',
      icon: Icon(Icons.apple_outlined, size: 30),
      activeIcon: Icon(Icons.apple, size: 30),
    ),
    GlassTab(
      label: 'Examples',
      icon: Icon(CupertinoIcons.square_stack_3d_up),
      activeIcon: Icon(CupertinoIcons.square_stack_3d_up_fill),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scope = _BrightnessScope.of(context);
    final isDark = scope.brightness == Brightness.dark;
    final destination = _activeDestination;

    return DestinationScope(
      open: _openDestination,
      close: _closeDestination,
      hasActiveDestination: destination != null,
      child: GlassScaffold(
        background: const ShowcaseBackground(),
        statusBarStyle:
            isDark ? GlassStatusBarStyle.light : GlassStatusBarStyle.dark,
        settings: RecommendedGlassSettings.standard,
        topEdgeFade: true,
        bottomBar: GlassTabBar.bottom(
          selectedIndex: _selectedTab,
          onTabSelected: (i) => setState(() {
            _selectedTab = i;
            // Switching tabs always returns to that tab's grid — the bottom
            // bar is the only navigation control, so it must always be able
            // to get you back to a known place.
            _activeDestination = null;
          }),
          interactionBehavior: GlassInteractionBehavior.full,
          selectedIconColor: AuroraColors.violet,
          iconSize: 28,
          labelFontSize: 10,
          iconLabelSpacing: 0,
          // Wider bar (less inset from the screen edges) with softened
          // rounded-rectangle corners instead of a full pill/capsule shape,
          // on both the bar itself and the per-tab selection indicator.
          horizontalPadding: 10,
          barBorderRadius: 26,
          indicatorBorderRadius: 18,
          settings: const LiquidGlassSettings(
            glassColor: Color.fromRGBO(255, 255, 255, 0.08),
            thickness: 30,
            blur: 3,
            chromaticAberration: .01,
            lightAngle: GlassDefaults.lightAngle,
            lightIntensity: .5,
            ambientStrength: 0,
            refractiveIndex: 1.2,
            saturation: 1.2,
            specularSharpness: GlassSpecularSharpness.medium,
          ),
          tabs: _tabs,
        ),
        body: Stack(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: destination != null
                  ? KeyedSubtree(
                      key: const ValueKey('destination'),
                      child: destination,
                    )
                  : switch (_selectedTab) {
                      0 => const _ExploreTab(key: ValueKey('explore')),
                      1 => const _WidgetsTab(key: ValueKey('widgets')),
                      2 => const AndroidShowcaseTab(key: ValueKey('android')),
                      3 => const _DemosTab(key: ValueKey('demos')),
                      _ => const _ExamplesTab(key: ValueKey('examples')),
                    },
            ),
            // Minimal floating back control — not a nav bar, just a small
            // glass square — the only way back from a destination besides
            // tapping a different tab.
            if (destination != null)
              Positioned(
                top: 8,
                left: 12,
                child: SafeArea(
                  bottom: false,
                  child: GlassIconButton(
                    icon: const Icon(CupertinoIcons.xmark),
                    shape: GlassIconButtonShape.roundedSquare,
                    size: 38,
                    onPressed: _closeDestination,
                  ),
                ),
              ),
            // Light/dark toggle — floating top-right, always visible.
            Positioned(
              top: 8,
              right: 12,
              child: SafeArea(
                bottom: false,
                child: GlassIconButton(
                  icon: Icon(
                    isDark ? CupertinoIcons.sun_max : CupertinoIcons.moon,
                  ),
                  shape: GlassIconButtonShape.roundedSquare,
                  size: 38,
                  onPressed: scope.toggleBrightness,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Explore Tab — hero overview
// =============================================================================

class _ExploreTab extends StatelessWidget {
  const _ExploreTab({super.key});

  /// Every card on the Explore tab, in one shuffled deck. Seeded so the
  /// order is fixed for the app's lifetime rather than re-shuffling (and
  /// visibly jumping around) on every rebuild.
  static final List<Widget> _exploreCards = () {
    final cards = <Widget>[
      // _SmallDemoCard(
      //   title: 'Messages',
      //   icon: CupertinoIcons.chat_bubble_2_fill,
      //   color: const Color(0xFF34C759),
      //   destination: const MessagesScreen(),
      // ),
      _SmallDemoCard(
        title: 'Surfaces',
        icon: CupertinoIcons.rectangle_3_offgrid_fill,
        color: AuroraColors.violet,
        destination: const SurfacesPage(),
      ),
      _SmallDemoCard(
        title: 'Interactive',
        icon: CupertinoIcons.hand_point_right_fill,
        color: AuroraColors.magenta,
        destination: const InteractivePage(),
      ),
      _SmallDemoCard(
        title: 'Feedback',
        icon: CupertinoIcons.hourglass,
        color: AuroraColors.amber,
        destination: const FeedbackPage(),
      ),
      _SmallDemoCard(
        title: 'Input',
        icon: CupertinoIcons.keyboard,
        color: AuroraColors.cyan,
        destination: const InputPage(),
      ),
      _SmallDemoCard(
        title: 'Overlays',
        icon: CupertinoIcons.square_stack_fill,
        color: AuroraColors.indigo,
        destination: const OverlaysPage(),
      ),
      _SmallDemoCard(
        title: 'Containers',
        icon: CupertinoIcons.square_stack_3d_up_fill,
        color: AuroraColors.emerald,
        destination: const ContainersPage(),
      ),
    ];
    cards.shuffle(math.Random(7));
    return cards;
  }();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Builder(builder: (context) {
                    final isDark = CupertinoTheme.of(context).brightness ==
                        Brightness.dark;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FLUTTER WIDGET KIT · OPEN SOURCE',
                          style: AppType.eyebrow(isDark: isDark),
                        ),
                        const SizedBox(height: 10),
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: AuroraColors.aurora,
                          ).createShader(bounds),
                          child: Text(
                            'Liquid Glass',
                            style: AppType.display(
                              isDark: isDark,
                              size: 40,
                              color: CupertinoColors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Real shader-based blur & refraction for Flutter — '
                          'not a BackdropFilter trick.',
                          style: AppType.body(isDark: isDark, size: 16),
                        ),
                      ],
                    );
                  }),
                  SizedBox(height: 32),

                  Text(
                    'Jump In',
                    style: AppType.heading(
                      isDark: CupertinoTheme.of(context).brightness ==
                          Brightness.dark,
                      size: 21,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Every card on this page in one unshuffled deck — pairs
                  // rendered two-up, in a fixed shuffled order (seeded, so
                  // it doesn't reshuffle on every rebuild).
                  for (var i = 0; i < _exploreCards.length; i += 2) ...[
                    if (i > 0) SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(child: _exploreCards[i]),
                        SizedBox(width: 14),
                        Expanded(
                          child: i + 1 < _exploreCards.length
                              ? _exploreCards[i + 1]
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ],

                  SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Widgets Tab — full catalog
// =============================================================================

class _WidgetsTab extends StatelessWidget {
  const _WidgetsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Widgets',
                    style: AppType.display(
                      isDark: CupertinoTheme.of(context).brightness ==
                          Brightness.dark,
                      size: 32,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Browse the full widget catalog.',
                    style: AppType.body(
                      isDark: CupertinoTheme.of(context).brightness ==
                          Brightness.dark,
                    ),
                  ),
                  SizedBox(height: 24),

                  // Row 1: Containers + Interactive
                  Row(
                    children: [
                      Expanded(
                        child: _SmallDemoCard(
                          title: 'Containers',
                          icon: CupertinoIcons.square_stack_3d_up_fill,
                          color: const Color(0xFF007AFF),
                          destination: const ContainersPage(),
                        ),
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: _SmallDemoCard(
                          title: 'Interactive',
                          icon: CupertinoIcons.hand_point_right_fill,
                          color: const Color(0xFFFF9500),
                          destination: const InteractivePage(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14),

                  // Row 2: Feedback + Overlays
                  Row(
                    children: [
                      Expanded(
                        child: _SmallDemoCard(
                          title: 'Feedback',
                          icon: CupertinoIcons.hourglass,
                          color: const Color(0xFF34C759),
                          destination: const FeedbackPage(),
                        ),
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: _SmallDemoCard(
                          title: 'Overlays',
                          icon: CupertinoIcons.square_stack_fill,
                          color: const Color(0xFFAF52DE),
                          destination: const OverlaysPage(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14),

                  // Row 3: Surfaces + Input
                  Row(
                    children: [
                      Expanded(
                        child: _SmallDemoCard(
                          title: 'Surfaces',
                          icon: CupertinoIcons.rectangle_3_offgrid_fill,
                          color: const Color(0xFF5AC8FA),
                          destination: const SurfacesPage(),
                        ),
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: _SmallDemoCard(
                          title: 'Input',
                          icon: CupertinoIcons.keyboard,
                          color: const Color(0xFFFF2D55),
                          destination: const InputPage(),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Demos Tab — full-screen app demos
// =============================================================================

class _DemosTab extends StatelessWidget {
  const _DemosTab({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Demos',
                    style: AppType.display(
                      isDark: CupertinoTheme.of(context).brightness ==
                          Brightness.dark,
                      size: 32,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Polished Apple app reproductions.',
                    style: AppType.body(
                      isDark: CupertinoTheme.of(context).brightness ==
                          Brightness.dark,
                    ),
                  ),
                  SizedBox(height: 24),

                  // Large featured card
                  _LargeDemoCard(
                    title: 'Apple Music',
                    subtitle:
                        'Searchable bottom bar, play pill, tab navigation',
                    icon: CupertinoIcons.music_note_2,
                    gradient: const [
                      Color(0xFF8B0000),
                      Color(0xFFFA2D48),
                    ],
                    destination: const AppleMusicHomeScreen(),
                  ),
                  SizedBox(height: 14),

                  _LargeDemoCard(
                    title: 'Messages',
                    subtitle: 'Conversations, edit menus & filter controls',
                    icon: CupertinoIcons.chat_bubble_2_fill,
                    gradient: const [
                      Color(0xFF0A4D20),
                      Color(0xFF34C759),
                    ],
                    destination: const MessagesScreen(),
                  ),
                  SizedBox(height: 14),

                  _LargeDemoCard(
                    title: 'Podcasts',
                    subtitle:
                        'Mini-player, now playing sheet & scroll collapse',
                    icon: CupertinoIcons.mic_fill,
                    gradient: const [
                      Color(0xFF4A1A6B),
                      Color(0xFFA855F7),
                    ],
                    destination: const ApplePodcastsHomeScreen(),
                  ),
                  SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: _SmallDemoCard(
                          title: 'News',
                          icon: CupertinoIcons.news,
                          color: const Color(0xFFFF3B30),
                          destination: const AppleNewsHomeScreen(),
                        ),
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: _SmallDemoCard(
                          title: 'Lock Screen',
                          icon: CupertinoIcons.lock_fill,
                          color: const Color(0xFF5856D6),
                          destination: const KeypadLockScreenDemo(),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Examples Tab — Widget patterns & component reference
// =============================================================================

class _ExamplesTab extends StatelessWidget {
  const _ExamplesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Examples',
                    style: AppType.display(
                      isDark: CupertinoTheme.of(context).brightness ==
                          Brightness.dark,
                      size: 32,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Widget modes & configuration reference.',
                    style: AppType.body(
                      isDark: CupertinoTheme.of(context).brightness ==
                          Brightness.dark,
                    ),
                  ),
                  SizedBox(height: 24),

                  // Row 1: Nav Patterns + Context Menus
                  Row(
                    children: [
                      Expanded(
                        child: _SmallDemoCard(
                          title: 'Nav Patterns',
                          icon: CupertinoIcons.rectangle_split_3x1,
                          color: const Color(0xFF007AFF),
                          destination: const NavBarPatternsDemo(),
                        ),
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: _SmallDemoCard(
                          title: 'Menus',
                          icon: CupertinoIcons.ellipsis_circle_fill,
                          color: const Color(0xFFFF9500),
                          destination: const MenuDemoPage(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14),

                  // Large card: Modal Sheets
                  _LargeDemoCard(
                    title: 'Modal Sheets',
                    subtitle:
                        'Standard, peek, Apple Maps & smart silence modes',
                    icon: CupertinoIcons.rectangle_on_rectangle,
                    gradient: const [
                      Color(0xFF0E4D92),
                      Color(0xFF5AC8FA),
                    ],
                    destination: const ShowcaseApp(),
                  ),
                  SizedBox(height: 14),

                  // Row 2: Text Fields + Video Player
                  Row(
                    children: [
                      Expanded(
                        child: _SmallDemoCard(
                          title: 'Text Fields',
                          icon: CupertinoIcons.textbox,
                          color: const Color(0xFF34C759),
                          destination: const TextFieldDemo(),
                        ),
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: _SmallDemoCard(
                          title: 'Video Player',
                          icon: CupertinoIcons.play_circle_fill,
                          color: const Color(0xFFFF2D55),
                          destination: const VideoGlassDemoPage(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14),

                  // Row 3: Tab Widths
                  Row(
                    children: [
                      Expanded(
                        child: _SmallDemoCard(
                          title: 'Tab Widths',
                          icon: CupertinoIcons.slider_horizontal_3,
                          color: const Color(0xFFAF52DE),
                          destination: const TabWidthDemoPage(),
                        ),
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: _SmallDemoCard(
                          title: 'Platform View',
                          icon: CupertinoIcons.map_fill,
                          color: const Color(0xFF5AC8FA),
                          destination: const PlatformViewDemo(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14),

                  // Row 4: Collapse Bar
                  Row(
                    children: [
                      Expanded(
                        child: _SmallDemoCard(
                          title: 'Collapse Bar',
                          icon: CupertinoIcons.arrow_down_right_circle_fill,
                          color: const Color(0xFF30D158),
                          destination: const CollapseBarDemoPage(),
                        ),
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: _SmallDemoCard(
                          title: 'Command Palette',
                          icon: CupertinoIcons.command,
                          color: const Color(0xFF64D2FF),
                          destination: const GlassCommandPaletteDemo(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14),

                  _LargeDemoCard(
                    title: 'Buttons & Shadows',
                    subtitle: 'Glass elevations and GPU SDF shadows',
                    icon: CupertinoIcons.layers_fill,
                    gradient: const [
                      Color(0xFFFFB340), // Vibrant Amber
                      Color(0xFFE58600), // Deep Orange
                    ],
                    destination: const ShadowClippingDemoPage(),
                  ),
                  SizedBox(height: 14),

                  _LargeDemoCard(
                    title: 'Adaptive Brightness',
                    subtitle:
                        'Content-aware light/dark bar adaptation on scroll',
                    icon: CupertinoIcons.sun_dust_fill,
                    gradient: const [
                      Color(0xFF1C1C2E),
                      Color(0xFF5AC8FA),
                    ],
                    destination: const ContentAwareBrightnessDemo(),
                  ),
                  SizedBox(height: 14),

                  _LargeDemoCard(
                    title: 'Indicator Parity',
                    subtitle:
                        'All 5 pill widgets — live pinch / expansion / aberration tuner',
                    icon: CupertinoIcons.dial_fill,
                    gradient: const [
                      Color(0xFF5E3AFF),
                      Color(0xFF0A84FF),
                    ],
                    destination: const IndicatorParityDemoPage(),
                  ),
                  SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: _SmallDemoCard(
                          title: 'Dock',
                          icon: CupertinoIcons.rectangle_grid_1x2,
                          color: const Color(0xFF32D74B),
                          destination: const GlassDockDemo(),
                        ),
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: _SmallDemoCard(
                          title: 'Calendar',
                          icon: CupertinoIcons.calendar,
                          color: const Color(0xFFFF453A),
                          destination: const GlassCalendarPickerDemo(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: _SmallDemoCard(
                          title: 'Chart',
                          icon: CupertinoIcons.chart_bar_alt_fill,
                          color: const Color(0xFF0A84FF),
                          destination: const GlassChartDemo(),
                        ),
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: _SmallDemoCard(
                          title: 'Long-tail Components',
                          icon: CupertinoIcons.square_grid_2x2,
                          color: const Color(0xFFBF5AF2),
                          destination: const GlassNewComponentsDemo(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14),

                  SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Shared Widgets
// =============================================================================

/// Opens [destination] in place, inside the persistent bottom-tab-bar shell
/// — never a pushed full-screen route with its own back-arrow bar. Every
/// catalog page, Apple-app recreation, and widget demo goes through this one
/// function, so the whole app's navigation model lives in one place: see
/// [DestinationScope].
void _openDemo(BuildContext context, Widget destination) {
  DestinationScope.of(context).open(destination);
}

/// Provides in-place "destination" navigation to the whole app: opening a
/// catalog page/demo swaps it into the body of the persistent
/// [ShowcaseHomePage] shell rather than pushing a new route, so the bottom
/// tab bar (and the floating back control) never disappear.
class DestinationScope extends InheritedWidget {
  const DestinationScope({
    super.key,
    required this.open,
    required this.close,
    required this.hasActiveDestination,
    required super.child,
  });

  final ValueChanged<Widget> open;
  final VoidCallback close;
  final bool hasActiveDestination;

  static DestinationScope of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<DestinationScope>();
    assert(scope != null, 'No DestinationScope found in context');
    return scope!;
  }

  @override
  bool updateShouldNotify(DestinationScope oldWidget) =>
      hasActiveDestination != oldWidget.hasActiveDestination;
}

/// Small demo card — glass panel with an accent icon chip, "Aurora Glass"
/// pattern (restrained tint, not a full-bleed saturated fill).
class _SmallDemoCard extends StatelessWidget {
  const _SmallDemoCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.destination,
  });

  final String title;
  final IconData icon;
  final Color color;
  final Widget destination;

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => _openDemo(context, destination),
      child: Container(
        height: 104,
        decoration:
            auroraPanelDecoration(isDark: isDark, radius: 18, tint: color),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AuroraIconChip(icon: icon, color: color, size: 34),
            const Spacer(),
            Text(
              title,
              style: AppType.label(isDark: isDark, size: 14.5),
            ),
          ],
        ),
      ),
    );
  }
}

/// Large demo card — glass panel with an accent icon chip and a subtle
/// gradient-tinted top hairline instead of a full-bleed saturated fill.
class _LargeDemoCard extends StatelessWidget {
  const _LargeDemoCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.destination,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final Widget destination;

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final accent = gradient.first;
    return GestureDetector(
      onTap: () => _openDemo(context, destination),
      child: Container(
        height: 124,
        decoration:
            auroraPanelDecoration(isDark: isDark, radius: 22, tint: accent),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: AppType.heading(isDark: isDark, size: 19)),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppType.body(isDark: isDark, size: 13, height: 1.3),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            AuroraIconChip(icon: icon, color: accent, size: 52),
          ],
        ),
      ),
    );
  }
}
