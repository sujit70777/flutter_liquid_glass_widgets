# Flutter Liquid Glass Widgets

A Flutter widget library that brings Apple's iOS 26 "Liquid Glass" look to your app — frosted, refractive glass surfaces with real blur, jelly-like physics animations, and dynamic lighting. Drop it into any Flutter app on any platform; no native code required.

## Attribution

This package is a fork of [`liquid_glass_widgets`](https://github.com/sdegenaar/liquid_glass_widgets) by [Sebastian Degenaar](https://github.com/sdegenaar), which is in turn built on [`liquid_glass_renderer`](https://github.com/whynotmake-it/flutter_liquid_glass/tree/main/packages/liquid_glass_renderer) by [whynotmake.it](https://github.com/whynotmake-it). Both are MIT-licensed; their original license and copyright notices are preserved throughout this repository. See [`lib/src/renderer/RENDERER_ATTRIBUTION.md`](lib/src/renderer/RENDERER_ATTRIBUTION.md) for renderer-specific vendoring details.

[![pub package](https://img.shields.io/pub/v/flutter_liquid_glass_widgets.svg?label=pub.dev&labelColor=333940&logo=dart)](https://pub.dev/packages/flutter_liquid_glass_widgets)
[![pub points](https://img.shields.io/pub/points/flutter_liquid_glass_widgets?label=pub%20points&labelColor=333940)](https://pub.dev/packages/flutter_liquid_glass_widgets/score)
[![likes](https://img.shields.io/pub/likes/flutter_liquid_glass_widgets?label=likes&labelColor=333940)](https://pub.dev/packages/flutter_liquid_glass_widgets/score)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)


https://github.com/user-attachments/assets/2fe28f46-96ad-459d-b816-e6d6001d90de

*[Wanderlust](example/showcase/) — a luxury travel showcase built entirely with `flutter_liquid_glass_widgets`*


## Contents

- [Installation](#installation)
- [Quick Start](#quick-start)
- [Examples](#examples)
- [Glass vs Content](#glass-vs-content) — quick rules for what should be glass
- [Widget Categories](#widget-categories)
- [Theming](#theming)
- [Platform Support](#platform-support)
- [Glass Quality Modes](#glass-quality-modes)
- [GlassScaffold & GlassPage](#glassscaffold--glasspage)
- [Performance Tips](#performance-tips)
- [Accessibility](#accessibility)
- [Testing](#testing)
- [More Docs](#more-docs)


## Features

- **Comprehensive glass widget library** — containers, interactive controls, inputs, feedback, overlays, and navigation surfaces (see [Widget Categories](#widget-categories))
- **Real frosted glass** — native two-pass Gaussian blur + shader refraction on Impeller; lightweight shader on Skia/Web
- **Works everywhere** — iOS, Android, macOS, Web, Windows, Linux; rendering path chosen automatically
- **Adaptive quality** *(experimental)* — `GlassAdaptiveScope` benchmarks the device and adjusts quality in real time
- **Minimal dependencies** — only `equatable`, `flutter_shaders`, and `logging` beyond the Flutter SDK
- **One-line setup** — `LiquidGlassWidgets.wrap(child: myApp)` handles accessibility, adaptive quality, and global theming
- **Content-aware brightness** — glass bars flip between light/dark icons based on what's scrolling behind them
- **Gyroscope lighting** — `GlassMotionScope` drives specular highlights from any `Stream<double>`
- **WCAG-compliant by default** — Reduce Motion and Reduce Transparency are respected automatically


## Installation

```yaml
dependencies:
  flutter_liquid_glass_widgets: ^0.0.1
```

```bash
flutter pub get
```

> Requires Flutter ≥ 3.41.0 (Dart ≥ 3.5.0). Recommended: Flutter 3.41+ for the best Impeller rendering quality.


## Quick Start

**Step 1.** Call `initialize()` in `main()`. **Step 2.** Wrap your app with `LiquidGlassWidgets.wrap()`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_liquid_glass_widgets/liquid_glass_widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();

  runApp(LiquidGlassWidgets.wrap(child: const MyApp()));
}
```

Then use `GlassScaffold` on each screen — it handles background, status bar, z-ordering, and edge fading automatically:

```dart
GlassScaffold(
  background: Image.asset('assets/wallpaper.jpg', fit: BoxFit.cover),
  statusBarStyle: GlassStatusBarStyle.auto,
  appBar: GlassAppBar(title: const Text('My App')),
  body: Center(child: GlassCard(child: Text('Hello, Glass!'))),
)
```

> Accessibility is on by default — the library reads Reduce Motion and Reduce Transparency automatically. See [Accessibility](#accessibility).

### Which widget do I need?

| Scenario | Widget |
|---|---|
| Screen with app bar and/or tab bar | **`GlassScaffold`** — start here |
| Custom layout without a standard scaffold | **`GlassPage`** — lower-level building block |
| Standalone glass card/panel in an existing layout | **`GlassCard` / `GlassContainer`** |
| Localised group of glass elements | **`AdaptiveLiquidGlassLayer`** |

### Optional: quality & theming

```dart
runApp(LiquidGlassWidgets.wrap(
  child: const MyApp(),
  adaptiveQuality: true,          // auto-benchmarks device, degrades gracefully
  theme: GlassThemeData.simple(   // optional app-wide glass defaults
    blur: 10,
    thickness: 30,
    quality: GlassQuality.standard,
  ),
));
```

Both parameters are optional — omit them and the library uses sensible defaults.


## Examples

Each example below is a complete, runnable app.

### [Wanderlust](example/showcase/) — Luxury Travel Showcase

Full-bleed imagery, parallax scroll, hero transitions, concierge chat. **This is the app shown in the video above.**

```bash
cd example/showcase && flutter pub get && flutter run
```

### [Apple Music Demo](example/lib/apple_music/)

`GlassTabBar.searchable()`, a floating playback pill, iOS 26 navigation model.

```bash
cd example && flutter pub get && flutter run -t lib/apple_music/apple_music_demo.dart
```

### [Apple Messages Demo](example/lib/apple_messages/)

The **Liquid Morph Engine** via `GlassMenu`. Tap the menu or **Edit** button to see the teardrop open/close physics live.

```bash
cd example && flutter pub get && flutter run -t lib/apple_messages/apple_messages_demo.dart
```

### [Apple News Demo](example/lib/apple_news/)

`GlassTabBar.searchable()` with a morphing search pill, category chips, hero cards.

```bash
cd example && flutter pub get && flutter run -t lib/apple_news/apple_news_demo.dart
```

<img width="390" height="844" alt="Apple News Demo" src="https://raw.githubusercontent.com/sujit70777/flutter_liquid_glass_widgets/main/docs/assets/apple_news_demo.jpg" />

### [Widget Showcase](example/) — Full Component Library

Every glass widget, organised by category, with live settings you can copy into your app.

```bash
cd example && flutter pub get && flutter run
```

<img width="390" height="847" alt="Widget Showcase" src="https://raw.githubusercontent.com/sujit70777/flutter_liquid_glass_widgets/main/docs/assets/showcase.jpg" />

### [Component Demos](example/lib/demos/) — Copy-Pasteable Examples

One widget, one file, runnable standalone (run from `example/`):

| Demo | Run command |
|---|---|
| `glass_menu_demo.dart` — all 9 menu alignments | `flutter run -t lib/demos/glass_menu_demo.dart` |
| `glass_tab_bar_scrollable_demo.dart` | `flutter run -t lib/demos/glass_tab_bar_scrollable_demo.dart` |
| `glass_modal_sheet_demo.dart` — peek/half/full states | `flutter run -t lib/demos/glass_modal_sheet_demo.dart` |
| `glass_bottom_bar_demo.dart` — magic-lens masking | `flutter run -t lib/demos/glass_bottom_bar_demo.dart` |
| `bottom_bar_tab_width_demo.dart` | `flutter run -t lib/demos/bottom_bar_tab_width_demo.dart` |
| `searchable_bar_demo.dart` | `flutter run -t lib/demos/searchable_bar_demo.dart` |
| `shape_debug_demo.dart` — GlassButton shapes | `flutter run -t lib/demos/shape_debug_demo.dart` |
| `quality_comparison_demo.dart` | `flutter run -t lib/demos/quality_comparison_demo.dart` |
| `nav_bar_patterns_demo.dart` — GlassScaffold layouts | `flutter run -t lib/demos/nav_bar_patterns_demo.dart` |
| `content_aware_brightness_demo.dart` | `flutter run -t lib/demos/content_aware_brightness_demo.dart` |
| `indicator_parity_demo.dart` — pinch/expansion/tint sliders | `flutter run -t lib/demos/indicator_parity_demo.dart` |


## Glass vs Content

Glass is for navigation, not content: nav bars, tab bars, sheets, buttons. Content underneath (lists, cards, article tiles) stays opaque.

| ✅ Use glass for | ❌ Keep opaque |
|---|---|
| Navigation bars, tab bars, toolbars | List cells, table rows |
| Floating action buttons | Full-screen backgrounds |
| Sheets, popovers, menus | Scrollable content cards |
| Toggles, sliders, segmented controls | Article tiles, media players |

`GlassCard` / `GlassContainer` / `GlassGroupedSection` are base surfaces, not wrappers for other glass controls:

| ✅ Place inside | ❌ Don't place inside |
|---|---|
| `Text`, `Icon`, `ListTile`, `CupertinoListTile`, `GlassListTile`, `GlassDivider` | `GlassSegmentedControl`, `GlassSlider`, `GlassSwitch`, `GlassButton`, `GlassChip`, `GlassIconButton`, other glass widgets |

`GlassContainer` sets `avoidsRefraction: true` on children so nested glass doesn't refract through it — interactive glass controls already have their own surface via `backgroundColor`/`indicatorColor`, so no outer container is needed.


## Widget Categories

### Containers
`GlassCard` · `GlassContainer`\* · `GlassAvatar` · `GlassChart` · `GlassDivider` · `GlassGroupedSection` · `GlassListTile` · `GlassStepper` · `GlassTimeline`

\* Low-level building block — most apps should use `GlassCard` or `GlassGroupedSection` instead.

### Interactive
`GlassButton` · `GlassIconButton` · `GlassChip` · `GlassSwitch` · `GlassSlider` · `GlassSegmentedControl` · `GlassPullDownButton` · `GlassButtonGroup` · `GlassBadge` · `GlassPageControl` · `LiquidGlassScope`

### Input
`GlassTextField` · `GlassTextArea` · `GlassPasswordField` · `GlassSearchBar` · `GlassPicker` · `GlassCalendarPicker` · `GlassRatingBar` · `GlassFormField`

### Feedback
`GlassProgressIndicator` · `GlassSkeletonLoader` · `GlassToast`

### Overlays
`GlassDialog` · `GlassSheet` · `GlassModalSheet` · `showGlassActionSheet` · `GlassMenu` · `GlassMenuItem` · `GlassMenuDivider` · `GlassMenuLabel` · `GlassPopover` · `GlassCommandPalette` (⌘K / Ctrl+K, fuzzy search)

### Surfaces
`GlassScaffold` · `GlassAppBar` · `GlassTabBar` (`.bottom` / `.inline` / `.searchable`) · `GlassToolbar` · `GlassLargeTitle` · `GlassDock` · `GlassIsolationScope` · `GlassContentAwareScope` · `GlassContentAwareContent` · `GlassContentAwareBrightness`

### Accessibility
`GlassA11yScope` · `AdaptiveGlassText` · `GlassLuminanceSampler` · `GlassAccessibilityScope` · `GlassContrastRule` (optional [`flutter_a11y_lens`](https://pub.dev/packages/flutter_a11y_lens) bridge)

### Theming & Performance
`GlassTheme` · `GlassThemeData` · `GlassThemePresets` (`.frostedDark` / `.clearLight` / `.tintedBrand`) · `GlassInteractionSettings` · `GlassAdaptiveScope` · `GlassPerformanceMonitor`


## Theming

Pass a `theme:` to `LiquidGlassWidgets.wrap()` — every glass widget inherits it, no per-widget config needed:

```dart
runApp(LiquidGlassWidgets.wrap(
  child: const MyApp(),
  theme: GlassThemeData(
    light: GlassThemeVariant(
      settings: GlassThemeSettings(thickness: 30, blur: 6),
      quality: GlassQuality.standard,
    ),
    dark: GlassThemeVariant(
      settings: GlassThemeSettings(thickness: 40, blur: 8),
      quality: GlassQuality.standard,
    ),
  ),
));
```

Or the shorthand for a single quality:

```dart
runApp(LiquidGlassWidgets.wrap(
  child: const MyApp(),
  theme: GlassThemeData.simple(blur: 10, thickness: 30, quality: GlassQuality.standard),
));
```

Override order (highest wins): widget `settings:` param → `GlassPage(themeOverride: ...)` → `GlassTheme` / `wrap(theme:...)`.

For a subtree with different glass settings, wrap it in `GlassTheme`:

```dart
GlassTheme(
  data: GlassThemeData.simple(blur: 4, quality: GlassQuality.minimal),
  child: MyListSection(),
)
```

`GlassGlowColors` controls the interaction glow on surfaces like `GlassBottomBar`:

```dart
GlassThemeVariant(
  glowColors: GlassGlowColors(primary: Colors.blue, glowBlurRadius: 12, glowSpreadRadius: 0.2, glowOpacity: 0.8),
)
```


## Platform Support

| Platform | Renderer | Notes |
|---|---|---|
| iOS | Impeller (Metal) | Full shader pipeline, chromatic aberration |
| Android | Impeller (Vulkan) | Full shader pipeline, chromatic aberration |
| macOS | Impeller (Metal) | Full shader pipeline, chromatic aberration |
| Web | CanvasKit | Lightweight fragment shader |
| Windows | Skia | Lightweight fragment shader |
| Linux | Skia | Lightweight fragment shader |

Detected automatically — no configuration required.


## Glass Quality Modes

Every glass widget accepts `quality:`. If in doubt, leave it unset — `standard` is the default and right for almost every case.

| Quality | Use for | Notes |
|---|---|---|
| `standard` *(default)* | Scrollable content, lists, most UI | iOS 26-accurate, works on every platform |
| `premium` | Static, non-scrolling surfaces (hero sections, feature cards) | Impeller only — full shader pipeline + chromatic aberration. Falls back to `standard` on Skia/Web. May misrender inside `ListView`/`CustomScrollView` |
| `minimal` | Old/low-end devices, background panels, GPU budget management | Zero shader cost — `BackdropFilter` blur + saturation matrix + specular rim stroke |

```dart
GlassCard(quality: GlassQuality.minimal, child: const Text('No shader overhead'))
```

`GlassScaffold` automatically promotes app bars and bottom bars to `premium`. `GlassThemeVariant.minimal` applies `minimal` globally via theme.


## GlassScaffold & GlassPage

**`GlassScaffold`** is the recommended way to build any screen — it replaces the manual assembly of `GlassPage` + `Scaffold` + `GlassScrollEdgeEffect` + `Stack`:

```dart
GlassScaffold(
  background: Image.asset('assets/wallpaper.jpg', fit: BoxFit.cover),
  statusBarStyle: GlassStatusBarStyle.light,
  appBar: GlassAppBar(
    title: const Text('Messages'),
    trailing: GlassButton(icon: const Icon(CupertinoIcons.compose), onTap: () {}),
  ),
  bottomBar: GlassTabBar.bottom(
    selectedIndex: 0,
    onTabSelected: (_) {},
    tabs: const [
      GlassTab(icon: Icon(Icons.home), label: 'Home'),
      GlassTab(icon: Icon(Icons.search), label: 'Search'),
    ],
  ),
  body: CustomScrollView(slivers: [...]),
)
```

It handles background + glass layering, bar z-ordering, edge fading, safe-area padding, bar isolation, and status bar styling for you. See `example/lib/demos/nav_bar_patterns_demo.dart` for more patterns.

**`GlassPage`** is the lower-level widget `GlassScaffold` uses internally — reach for it only when you need a custom layout `GlassScaffold` doesn't support:

```dart
GlassPage(
  background: Image.asset('assets/wallpaper.jpg', fit: BoxFit.cover),
  edgeToEdge: true,
  statusBarStyle: GlassStatusBarStyle.auto,
  child: Scaffold(
    appBar: GlassAppBar(title: const Text('Home')),
    body: MyContent(),
  ),
)
```

> **`edgeToEdge` on Android:** content draws under the nav bar — wrap your `Scaffold` body in `SafeArea` (or use `extendBody: true` and pad the bottom).

### Content-aware brightness

Bars auto-adapt icon/label color to the content scrolling behind them:

```dart
GlassScaffold(
  contentAwareBrightness: true,
  bottomBar: GlassTabBar.bottom(
    adaptiveBrightness: true,
    tabs: [...],
    selectedIndex: _index,
    onTabSelected: (i) => setState(() => _index = i),
  ),
  body: CustomScrollView(slivers: [...]),
)
```

Uses WCAG contrast ratios with dual-threshold hysteresis to avoid flicker on borderline content. See `example/lib/demos/content_aware_brightness_demo.dart`.

### Specular sharpness

```dart
GlassCard(
  settings: LiquidGlassSettings(specularSharpness: GlassSpecularSharpness.sharp),
  child: ...,
)
```

`soft` (frosted/matte) · `medium` (default, matches iOS 26) · `sharp` (mirror-like).


## Performance Tips

1. `LiquidGlassWidgets.initialize()` at startup — pre-caches shaders, no white flash on first render
2. `LiquidGlassWidgets.wrap(adaptiveQuality: true)` for automatic per-device quality tuning
3. `standard` quality for scrollable content
4. `premium` quality only for fixed surfaces (app bars, bottom bars, hero sections)
5. `minimal` quality for shader-dense screens (background panels, list cards) — keep `standard`/`premium` only on the focal element
6. Accessibility fallbacks are zero-cost — Reduce Transparency bypasses the shader entirely

### Persisting adaptive quality across cold starts

`GlassAdaptiveScope` caches its settled quality within a process, but re-benchmarks on every cold start unless you persist it yourself:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getString('glass_quality');
  final initial = saved != null ? GlassQuality.values.byName(saved) : null;

  await LiquidGlassWidgets.initialize();

  runApp(LiquidGlassWidgets.wrap(
    child: const MyApp(),
    adaptiveQuality: true,
    adaptiveConfig: GlassAdaptiveScopeConfig(
      initialQuality: initial,
      allowStepUp: true,
      onQualityChanged: (_, to) => prefs.setString('glass_quality', to.name),
    ),
  ));
}
```

`GlassAdaptiveScope` is `@experimental` — see [`docs/ADAPTIVE_QUALITY.md`](docs/ADAPTIVE_QUALITY.md) for threshold details and how to report your device's numbers.

### GPU budget monitoring

`GlassPerformanceMonitor` watches raster frame durations on `premium` surfaces and throws a `FlutterError` with actionable guidance if frames run over budget for 60 consecutive frames. Auto-enabled in debug/profile, zero-cost in release:

```dart
await LiquidGlassWidgets.initialize(enablePerformanceMonitor: false); // opt out

GlassPerformanceMonitor.rasterBudget = const Duration(microseconds: 8333); // 120 fps
GlassPerformanceMonitor.sustainedFrameThreshold = 120;
```


## Accessibility

Every glass widget respects the user's system accessibility settings automatically — no setup required.

| System Setting | Effect |
|---|---|
| **Reduce Motion** | Spring/jelly animations snap instantly to target |
| **Reduce Transparency / High Contrast** | Glass shader replaced with a plain frosted `BackdropFilter` panel |

To override system defaults (testing, demos, per-subtree customisation):

```dart
GlassAccessibilityScope(
  reduceTransparency: true,
  child: GlassSettingsPreview(),
)
```

To opt out of the automatic system bridge entirely (games, creative tools):

```dart
runApp(LiquidGlassWidgets.wrap(child: const MyApp(), respectSystemAccessibility: false));
```

Priority order (highest wins): explicit `GlassAccessibilityScope` in the tree → system `MediaQuery` flags → `wrap(respectSystemAccessibility: false)`.


## Testing

```bash
flutter test                              # all tests
flutter test --exclude-tags golden        # exclude golden tests
flutter test --tags golden                # macOS golden tests (require Impeller)
```


## More Docs

- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) — rendering pipeline, Liquid Morph Engine internals, custom refraction
- [`docs/LIQUID_MORPH_ENGINE.md`](docs/LIQUID_MORPH_ENGINE.md) — integrate the morph engine into your own widgets
- [`docs/ADAPTIVE_QUALITY.md`](docs/ADAPTIVE_QUALITY.md) — adaptive quality thresholds and calibration
- [`docs/PLATFORM_SUPPORT.md`](docs/PLATFORM_SUPPORT.md) — per-platform rendering details


## Dependencies

Minimal runtime dependencies beyond the Flutter SDK: `equatable`, `flutter_shaders`, and `logging`.

The glass rendering pipeline builds on the open-source work of [whynotmake-it](https://github.com/whynotmake-it) — their [`liquid_glass_renderer`](https://github.com/whynotmake-it/flutter_liquid_glass/tree/main/packages/liquid_glass_renderer) (MIT) has been vendored and extended with bug fixes, performance improvements, and shader optimisations.


## Contributing

Contributions are welcome. For major changes, open an issue first to discuss your proposal.


## License

MIT — see the [LICENSE](LICENSE) file for details.


## Links

- [pub.dev](https://pub.dev/packages/flutter_liquid_glass_widgets)
- [Repository](https://github.com/sujit70777/flutter_liquid_glass_widgets)
- [Issue Tracker](https://github.com/sujit70777/flutter_liquid_glass_widgets/issues)
