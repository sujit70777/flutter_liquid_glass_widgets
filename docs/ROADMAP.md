# Roadmap: 0.26.x → 1.0.0

> Last updated: 2026-07-30

This document tracks the planned work to get `liquid_glass_widgets` to a stable
1.0.0 release. The guiding principle is: **fewer, better widgets that map 1:1
to real iOS 26 components** — nothing half-baked, nothing Material-flavoured.

---

## Current Status (0.26.0)

> Honest scored audit against the 1.0.0 entry criteria. Updated 2026-08-01.

**Overall: ~82–85% of the way to 1.0.0.** The rendering engine, physics,
theming infrastructure, Material decoupling, accessibility, and RTL layout
are all complete and production-quality. What remains is test coverage,
Dartdoc completeness, and documentation polish.

| Criterion | Status | Notes |
|---|---|---|
| No known P0/P1 bugs | ✅ Clear | No open crash reports |
| Dartdoc complete on all public API | ✅ Done | 100% documented. `public_member_api_docs` enforced permanently (0.28.1) |
| Test coverage ≥ 90% | ✅ Done | Achieved ~92% line coverage (physical ceiling) |
| Example app demos every widget | ⚠️ Likely partial | Not verified against current widget catalogue |
| No `Icons.*` (Material) in `lib/` | ✅ Done | Zero hits — fully `CupertinoIcons` |
| No hardcoded `Colors.*` in `lib/` | ✅ Done | All replaced with `CupertinoColors` or explicit hex `Color` literals |
| `material.dart` imports in `lib/` | ✅ **Done (0.26.0)** | **36 → 0 files.** `GlassScaffold` → `CupertinoPageScaffold`; `glass_brightness.dart` rewritten to use `CupertinoTheme.of().brightness` which correctly inherits `ThemeMode` via Flutter's `MaterialBasedCupertinoThemeData` bridge. Zero `material.dart` imports remain. |
| Light mode + dark mode acceptable | ✅ Done | `GlassTheme.brightnessOf` shipped in 0.18.6, simplified cascade in 0.26.0 |
| RTL layout verified | ✅ **Done (0.28.0)** | `EdgeInsetsDirectional` / `AlignmentDirectional` audit complete. 8 new RTL tests pass. |
| Keyboard / Tab focus / Enter-Space activation | ✅ **Done (0.27.0)** | `GlassFocusRegion` (interactive + observe modes), iOS 26 focus ring, semantics on all 12 widget families, `GlassInteractionStateMixin` |
| Platform testing matrix complete | ⚠️ Partial | iOS + Android confirmed; Web, Windows, macOS need explicit QA |
| `docs/PLATFORM_SUPPORT.md` exists | ✅ Done | Shipped 2026-07-30 — all platforms, shader tiers, known bugs documented |
| CHANGELOG complete with migration guides | ⚠️ Likely partial | Not audited against 0.20–0.25 changes |
| README widget table accurate | ⚠️ Likely stale | Written for 0.15.x era, not audited since |

### 🔴 Biggest Blocker: Accessibility & Keyboard Support

Only **17 of 70** widget files have any `Semantics`, `semanticsLabel`, or
`excludeSemantics` usage. The 1.0.0 criterion requires every interactive widget
to support Tab focus traversal and Enter/Space activation for macOS/iPadOS
keyboard users. This affects:

`GlassButton`, `GlassSwitch`, `GlassSlider`, `GlassSegmentedControl`,
`GlassMenu`, `GlassSheet`, `GlassDialog`, `GlassActionSheet`, `GlassPicker`,
`GlassTextField`, `GlassSearchBar`, `GlassChip`, `GlassListTile`, and more.

**Estimated effort:** 4–6 weeks of focused work.

### ~~🔴 Second Blocker: RTL Layout~~ ✅ Done (0.28.0)

All directional padding/alignment primitives migrated to `EdgeInsetsDirectional`
and `AlignmentDirectional`. 8 new RTL layout audit tests pass. Zero regressions.

### Realistic Timeline to 1.0.0

| Work Area | Estimated Effort |
|---|---|
| Accessibility / keyboard focus (all interactive widgets) | ✅ Done (0.27.0) |
| RTL audit + golden tests | ✅ Done (0.28.0) |
| Platform testing matrix | 1–2 weeks |
| Dartdoc audit | ✅ Done (0.28.1) |
| `material.dart` decoupling (36 → 0) | ✅ Done (0.26.0) |
| `Colors.*` hardcode cleanup + API polish | ✅ Done (0.26.0) |
| `docs/PLATFORM_SUPPORT.md` | ✅ Done (0.26.0) |
| README, CHANGELOG, pub.dev screenshots | 1 week |
| **Total remaining** | **~3–5 weeks focused / 1–2 months part-time** |

---

## 0.14.x — Stabilisation ✅

0.14.0–0.14.2 shipped, settled, and patch-released. 0.14.2 completed the
initial Material artifact purge (InkWell → GestureDetector, Material icons →
Cupertino). **Done.**

---

## 0.15.0 — API Cleanup (Breaking) ✅

A focused breaking release that removes Material-leaning and thin-wrapper
widgets before the API surface gets cemented at 1.0.

### Widgets to Delete

| Widget | Reason |
|---|---|
| `GlassWizard` | Material vertical stepper concept. Apple uses navigation stacks or horizontal pagers for multi-step flows — not numbered circles connected by lines. |
| `GlassSideBar` | Simplified drawer / navigation rail. A real iPadOS sidebar is `UISplitViewController` with adaptive column widths, swipe-to-collapse, and deep navigation state. This widget is a static `Column` in a `SizedBox(width: 280)` — shipping it implies iPad-readiness it doesn't have. |
| `GlassSnackBar` | Literally documented as "Alias for GlassToast to match Material Design naming." Remove the alias, keep `GlassToast`. |
| `GlassPanel` | Thin convenience wrapper — identical to `GlassContainer` except `padding: 24` instead of `16` and `borderRadius: 20` instead of `12`. Not worth the API surface. Users can pass those two values to `GlassCard` or `GlassContainer`. |

### Deprecations

| Symbol | Notes |
|---|---|
| `GlassBackdropScope` | Deprecated in 0.14.0 (now a no-op). Kept as deprecated until 1.0.0 per the published deprecation timeline. Will be deleted in 1.0.0. |

### Exports & Tests

- Remove deleted widgets from `liquid_glass_widgets.dart` barrel exports.
- Delete associated test files and golden image files.
- Update example app to remove any demos referencing deleted widgets.
- Update README widget catalogue.

### What Stays (and Why)

Every remaining widget should map to a recognisable iOS 26 component:

| Widget | iOS 26 Equivalent | Notes |
|---|---|---|
| **Structural** | | |
| `GlassPage` | Full-screen glass page root | ✅ Solid |
| `GlassScaffold` | `CupertinoPageScaffold` + glass | ✅ New in 0.14, solid |
| `GlassAppBar` | `UINavigationBar` (transparent) | ✅ Name is Flutter-discoverable, implementation is iOS 26 |
| `GlassTabBar` | `UITabBarController` (unified) | ✅ One widget: `.bottom()`, `.searchable()`, default inline |
| `GlassSegmentedControl` | `UISegmentedControl` | ✅ `GlassSegmentedControl.scrollable()` covers filter chips |
| `GlassBottomBar` | `@Deprecated` → `GlassTabBar.bottom()` | Thin shim, removed in 2.0 |
| `GlassSearchableBottomBar` | `@Deprecated` → `GlassTabBar.searchable()` | Thin shim, removed in 2.0 |
| `GlassToolbar` | `UIToolbar` | ✅ Solid |
| **Containers** | | |
| `GlassContainer` | Base glass surface | ✅ Core primitive |
| `GlassCard` | Grouped inset card | ✅ `GlassContainer` with card defaults |
| `GlassListTile` | `UICollectionViewListCell` | ✅ Name is Flutter-discoverable |
| `GlassDivider` | `UITableView` separator | ✅ Solid |
| `GlassStepper` | `UIStepper` (−/+ control) | ✅ Direct 1:1 iOS mapping |
| **Interactive** | | |
| `GlassButton` | Various button styles | ✅ Core, heavily tested |
| `GlassIconButton` | `UIBarButtonItem` | ✅ Solid |
| `GlassSegmentedControl` | `UISegmentedControl` | ✅ Direct mapping |
| `GlassSwitch` | `UISwitch` | ✅ Direct mapping |
| `GlassSlider` | `UISlider` | ✅ Direct mapping |
| `GlassChip` | Filter pill / tag | ✅ Common in iOS apps (Photos tags, App Store) |
| `GlassBadge` | Notification badge | ✅ Direct mapping (`UITabBarItem.badgeValue`) |
| `GlassButtonGroup` | Grouped button bar | ✅ iOS toolbar button groups |
| `GlassPullDownButton` | `UIMenu` pull-down | ✅ Direct iOS 16+ mapping |
| `GlassPageControl` | `UIPageControl` | ✅ Direct mapping — dot indicators for paged content |
| **Input** | | |
| `GlassTextField` | `UITextField` | ✅ Solid, community-tested |
| `GlassTextArea` | Multi-line `UITextView` | ✅ Solid |
| `GlassSearchBar` | `UISearchBar` | ✅ Solid |
| `GlassPasswordField` | Secure `UITextField` | ✅ Convenience, solid |
| `GlassFormField` | Label + error text wrapper | ✅ Simple utility, no glass — just layout |
| `GlassPicker` | `UIPickerView` | ✅ Direct mapping |
| **Feedback** | | |
| `GlassProgressIndicator` | `UIProgressView` / `UIActivityIndicatorView` | ✅ Direct mapping |
| **Overlays** | | |
| `GlassDialog` | `UIAlertController` (.alert) | ✅ Solid |
| `GlassActionSheet` | `UIAlertController` (.actionSheet) | ✅ Direct mapping |
| `GlassSheet` | `UISheetPresentationController` | ✅ Solid |
| `GlassModalSheet` | Modal sheet variant | ✅ Solid, documented guide |
| `GlassMenu` | `UIMenu` / context menu | ✅ Solid, liquid morph engine |
| `GlassMenuItem` / `GlassMenuDivider` / `GlassMenuLabel` | Menu item types | ✅ Support widgets for `GlassMenu` |
| `GlassToast` | Notification pill / HUD | ✅ Widely understood cross-platform term |
| **Shared / Infra** | | |
| `AdaptiveGlass` | Quality-adaptive glass renderer | ✅ Core infra |
| `AdaptiveLiquidGlassLayer` | Layer wrapper | ✅ Core infra |
| `GlassIsolationScope` | Z-order isolation | ✅ Core infra |
| `GlassAccessibilityScope` | Accessibility config | ✅ Core infra |
| `GlassAdaptiveScope` | Device capability adaptation | ✅ Core infra |
| `GlassMotionScope` | Reduce-motion support | ✅ Core infra |
| `GlassScrollEdgeEffect` | iOS 26 `.scrollEdgeEffectStyle(.soft)` | ✅ Core infra |
| `LiquidGlassScope` | Refraction/background source config | ✅ Core infra |

---

## 0.18.0 — `GlassTabBar` Unification (All-in-One)

The defining architectural change before 1.0. Ships everything in one release:

### What Ships

1. **Internal `pill_internal.dart` merge** — `bottom_bar_internal.dart` +
   `tab_bar_internal.dart` merged into one engine with a `placement` flag.
   Prerequisite for everything else.

2. **Expanded `GlassTab`** — gains `activeIcon`, `glowColor` fields from
   `GlassBottomBarTab`. `GlassBottomBarTab` becomes `@Deprecated` typedef.

3. **`GlassTabBar` named constructors** — `.bottom()` (current `GlassBottomBar`
   behaviour) and `.searchable()` (current `GlassSearchableBottomBar`). Default
   constructor retains current inline tab bar behaviour.

4. **Deprecation shims** — `GlassBottomBar` and `GlassSearchableBottomBar`
   become zero-logic `StatelessWidget` wrappers forwarding to
   `GlassTabBar.bottom()` / `.searchable()`. Kept through 1.x, removed in 2.0.

5. **`GlassSegmentedControl.scrollable()`** — handles scrollable horizontal chip rows.
   Promoted from `GlassTabBar(isScrollable: true)`. That flag is deprecated.

6. ~~**Always-visible resting glass**~~ — *Omitted: Native iOS 26 uses a flat translucent pill at rest to save GPU cycles, blooming into glass only during interactions. Our existing implementation using `indicatorColor` already handles this correctly. Forcing the Impeller glass shader to run permanently at rest was deemed a performance waste and a deviation from native behaviour.*

### Breaking Changes

- **Visual:** All resting-state goldens regenerate (glass pill now visible at rest)
- **Semantic:** `indicatorColor` changes from solid-pill fill to glass tint
- **Deprecations:** `GlassBottomBar`, `GlassSearchableBottomBar`,
  `GlassBottomBarTab`, `GlassTabBar(isScrollable: true)` — all still work, IDE warnings only

### Migration

```dart
// BEFORE
GlassBottomBar(tabs: [...], ...)           → GlassTabBar.bottom(tabs: [...], ...)
GlassSearchableBottomBar(tabs: [...], ...) → GlassTabBar.searchable(tabs: [...], ...)
GlassBottomBarTab(label: 'Home', icon: ...)→ GlassTab(label: 'Home', icon: ...)
GlassTabBar(isScrollable: true, ...)       → GlassSegmentedControl.scrollable(segments: [...], ...)
```

---

## 0.18.x → 0.19.x — Hardening

Focus areas to address before 1.0. These are not all confirmed — they will be
refined based on 0.18.x feedback and community requests.

### Material Artifact Purge (continued from 0.14.2)

0.14.2 replaced `InkWell` → iOS-style opacity highlight and swapped Material
icons to Cupertino equivalents in `GlassListTile`, `GlassActionSheet`, and
`GlassStepper`. Remaining items:

- [ ] **Hardcoded colour audit** — Multiple widgets hardcode colours instead of
  resolving from theme:
  - `GlassSwitch` defaults `activeColor` to `Colors.green` (iOS uses system
    green, which is theme-aware)
  - `GlassFormField` uses `Colors.redAccent.shade100` for errors (iOS uses
    system red)
  - `GlassDialog` uses `Colors.red` for destructive actions
  - `GlassMenuDivider` uses hardcoded `Color(0xFFEF5350)` for destructive items
  - All should resolve from `GlassThemeData.glowColors` or
    `CupertinoColors.systemRed` / `.systemGreen`

> **Update 2026-07-30:** The structural / optical hardcode audit is **complete**.
> Barrier colours (`Colors.black54`) now resolve to `GlassDefaults.barrierColor`.
> Drag-handle specular tints use `CupertinoColors` + `GlassDefaults.specularLightAlpha/specularDarkAlpha`.
> `GlassProgressIndicator` system blue is now `CupertinoColors.activeBlue.resolveFrom(context)` (correctly adaptive in dark mode).
> Three widget files (`glass_progress_indicator.dart`, `glass_sheet.dart`, `adaptive_glass.dart`) are now fully decoupled from `package:flutter/material.dart`.
> Renderer and math anchor constants whitelisted with explicit `// Whitelisted:` comments.
> `dart analyze lib/` → **No issues**. `flutter test` → **2450 passed, 0 failed**.

### Light Mode / Theming Gap ✅ Resolved (infrastructure complete)

The library is no longer broken in light mode. A comprehensive content colour
audit across 0.15.0 and 0.15.1 replaced all hardcoded `Colors.white` /
`Colors.black` with brightness-aware `CupertinoColors` / `CupertinoTheme`
resolution. Light-mode drop shadows, frosted-white standard glass, and
brightness-aware `GlassSearchBar` / `GlassTextField` defaults were all shipped.

**Resources:**
- [iOS 26 Liquid Glass: Comprehensive Reference](https://medium.com/@madebyluddy/overview-37b3685227aa)
  — Material variants (`.regular`/`.clear`), hierarchy rules ("glass cannot
  sample glass"), accessibility modes, specular highlights, and adaptive shadow
  principles. Key validation against our implementation:
  - ✅ Lensing (not just blur) — our `LiquidGlassRenderer` does true refraction
  - ✅ 135° upper-left key light — both theme variants use `lightAngle: 2.356`
  - ✅ Glass isolation — `GlassIsolationScope` prevents glass-sampling-glass
  - ✅ Navigation-layer-only — all widgets map to iOS navigation-tier components
  - ✅ Adaptive shadows — `GlassShadow` constants with inverse-clipped rendering
  - ✅ Light-mode content colours — all widgets resolve from `CupertinoTheme`
- Apple HIG: Liquid Glass guidelines (WWDC 2025 sessions)

**0.15.0 fixed:**
- `GlassMenuItem`, `GlassMenuDivider`, `GlassMenuLabel` — colours from `CupertinoTheme`
- `GlassDialog`, `GlassActionSheet` — brightness-aware backgrounds and text
- `GlassPage` — safe under pure `CupertinoApp` (no `Theme.of` guard)
- `glassSettings` → `settings` rename across 8 widgets
- Example app migrated from `MaterialApp` to `CupertinoApp`

**0.15.1 fixed:**
- `GlassTextField`, `GlassSearchBar` — default text/icon/glow colours brightness-aware
- `GlassFormField` — label/helper text from `CupertinoColors.label` / `.secondaryLabel`
- `GlassPicker` — value text and chevron from `CupertinoColors.label`
- `GlassPasswordField` — icons from `CupertinoColors.secondaryLabel`
- `GlassToast` — background and text resolve from brightness
- `GlassChip` — text and icons visible in light mode
- Light-mode drop shadows (inverse-clipped, `GlassShadow` constants)
- Standard quality glass renders as clean frosted white in light mode

**Content colour audit completed across 0.15.0–0.15.1:**
- [x] `GlassTextField` — text/icon/glow colours now brightness-aware
- [x] `GlassToolbar` — title and divider colours from `CupertinoTheme`
- [x] `GlassAppBar` — title text from `CupertinoTheme` (no hardcoded colours)
- [x] `GlassStepper` — labels from `CupertinoTheme`, dividers brightness-aware
- [x] `GlassToast` — background and text resolve from brightness
- [x] `GlassProgressIndicator` — no hardcoded `Colors.white`/`Colors.black`

**0.18.6 fixed:**
- Centralised brightness authority — `GlassTheme.brightnessOf(context)` is now
  the single mandatory call site for all brightness decisions in the library.
- Four-level cascade: `GlassThemeData.brightness` override → explicit Cupertino
  pin → `MaterialApp` `ThemeMode` (the root fix) → OS/device fallback.
- New `GlassThemeData.brightness` field for per-glass-subtree overrides.
- All 26 widget files migrated from ad-hoc `CupertinoTheme` / `MediaQuery`
  brightness lookups to `GlassTheme.brightnessOf`.
- Canonical regression: `GlassBottomTabBar` shadow disappearing when device is
  in Dark Mode but app is pinned to `ThemeMode.light` — fully fixed.
- 39 new tests covering the full cascade including the regression scenario.

**Remaining:**
- [ ] **Light-mode golden tests** — add golden snapshots for key widgets in
  `Brightness.light` to catch regressions.

### Platform Edge Cases / Engine Bugs

- [ ] **CanvasKit Web circular clipping** — `LiquidOval` relies on `ClipRRect(borderRadius: 9999)` inside `_ShapeClip` to work around an iOS PlatformView compositing bug (Flutter #177551). However, on Web (CanvasKit), this massive radius breaks path clipping, causing the interaction `GlassGlow` to spill out as a giant square and destroying the CSS/SVG drop-shadow extraction on `DecoratedBox`.
  - **Proposed fix:** We need a way to branch and use `ClipOval` / `BoxShape.circle` strictly for Web/CanvasKit, or wait for an upstream engine fix for `ClipRRect(9999)` bounds calculation on Web.

- [ ] **`platformViewBackdrop` quality cliff** — When `platformViewBackdrop: true` is set on any
  `AdaptiveGlass`-backed widget (bar body, indicator, extra button), rendering is forced to
  `_FrostedFallback` (a live `BackdropFilter`) regardless of the requested quality tier. This is
  the only technically correct path — the Impeller shader reads a captured backdrop that excludes
  hybrid-composed PlatformViews. However, it creates a silent quality degradation: premium glass
  becomes a standard `BackdropFilter` over a map, and the `isInteractive` blur-omission is
  overridden so the draggable pill also runs a `BackdropFilter` continuously while repositioning
  (GPU-expensive). Two actions needed before 1.0:
  - **API doc:** Add a prominent note to `platformViewBackdrop` dartdoc explaining that quality
    is capped at the frosted fallback when set, and that this is a Flutter engine limitation
    (captured backdrop excludes PlatformViews).
  - **Long-term:** Track Flutter engine progress on making `RepaintBoundary`/`ImageFilter`
    capture include hybrid-composed PlatformViews. When that lands, `platformViewBackdrop` can
    route back to the native shader and this quality cliff disappears.
  - Introduced in: `0.19.2` (PR [#128](https://github.com/sdegenaar/liquid_glass_widgets/pull/128) by [@jfhair](https://github.com/jfhair)).

- ~~**`backerColor` dual-use / API design debt**~~ ✅ **Resolved in 0.19.5** — `platformViewFallbackColor` added (#138, @jfhair). `backerColor` remains the aesthetic backer pad; `platformViewFallbackColor` controls the `uBackgroundFallback` shader uniform for PlatformView fill. Fully backwards-compatible.

### RTL / Internationalisation

Only `GlassTextField` and the shared renderer reference `TextDirection`. No
widget-level RTL testing exists.

- [ ] **RTL layout audit** — verify all widgets using `Row`, `Positioned`,
  `EdgeInsets.only(left:)` work correctly in RTL locales. Replace
  directional padding with `EdgeInsetsDirectional` where appropriate.
- [ ] **RTL golden tests** — at minimum for `GlassListTile`, `GlassAppBar`,
  `GlassTabBar.bottom()`, and `GlassTabBar.searchable()`.

### Quality & Reliability

- [ ] **Test coverage push** — target 90%+ line coverage on all remaining
  public widgets. Currently at ~2219 tests; identify gaps.
- [ ] **Golden test audit** — ensure every widget has at least one golden for
  both Standard and Premium quality modes.
- [ ] **Accessibility audit** — verify every interactive widget has correct
  `Semantics`, focus traversal, and VoiceOver/TalkBack support.
- [ ] **Performance profiling** — document frame budgets for common layouts
  (list of 50 cards, bottom bar + body, modal sheet stack).
- [ ] **Brightness enforcement lint / CI check** — a grep-based CI script (or
  eventually a `custom_lint_builder` rule) that fails the build if any widget
  calls `MediaQuery.platformBrightnessOf` or `CupertinoTheme.of(context).brightness`
  directly, enforcing that all brightness decisions go through
  `GlassTheme.brightnessOf`. The three intentional exceptions in `glass_page.dart`
  and `glass_scaffold.dart` (OS status-bar icon colour) are whitelisted.

### API Polish

- [ ] **Consistent parameter naming** — audit all widgets for naming
  inconsistencies (e.g. `glassSettings` vs `settings`, `useOwnLayer` patterns).
- [ ] **Deprecation sweep** — ensure any deprecated API from 0.12–0.14 is
  either removed or has a clear migration path documented.
- [ ] **Public API freeze** — document the complete public API surface and
  commit to it. No new widget classes after this point, only refinements.

### Documentation

- [ ] **Widget catalogue page** — README or docs/ page with screenshots of
  every widget in both quality modes.
- [ ] **Migration guide** — 0.14 → 0.15 migration guide covering all deleted
  widgets and what to use instead.
- [ ] **Architecture doc update** — update ARCHITECTURE.md for any structural
  changes since it was last written.

### pub.dev Readiness

- [ ] **Screenshots** — add 3–5 screenshots to `pubspec.yaml` for the pub.dev
  listing (bottom bar, glass cards, menu morph, dialog, search bar).
- [ ] **Funding metadata** — add `funding:` to pubspec if applicable.
- [ ] **Analysis score** — ensure 160/160 pub points (no warnings, full
  dartdoc coverage, all platforms declared).

---

## 0.20.0 — Breaking-Change Release ✅

Shipped. `GlassListTile` divider ownership moved to `GlassGroupedSection`.
`GlassBackdropScope` and all pre-0.15 deprecated symbols removed.

---

## 0.21.0 – 0.25.x — Shipped ✅

Five minor versions shipped between the 0.20.0 breaking-change release and the
current 0.25.1. This section acknowledges their existence; full changelogs are
in `CHANGELOG.md`.

Notable work in this range (non-exhaustive):

- **Liquid Morph Engine** (`GlassMenu`) — two-pass GPU pipeline with SDF normal
  pre-computation, true `refract()` call per pixel, dynamic metaball blend
  scaling, bidirectional symmetric smooth-union, and J-curve spring physics.
  Reached performance ceiling of the Flutter/Impeller engine.
- **`GlassPopover`** — iOS 26 popover with arrow, progressive blur ramp, and
  adaptive sizing.
- **`LiquidStretch`** — squash-and-stretch anchor effect matching iOS 26 buttons.
- **Progressive blur** — scroll-edge and popover blur ramp infrastructure.
- **0.19.5:** `platformViewFallbackColor` added (`backerColor` API design fix).
- **0.19.6:** `GlassAppBar` Phase 1 + 2 large-title / search bar controller.
- **0.25.x:** Various stability patches; test count at ~2219+; coverage ceiling
  reached for the Liquid Morph physics engine.

> **Note:** The ROADMAP was last updated in detail up to 0.20.0 and is being
> brought current as of 0.25.1. If you worked on 0.21–0.25 and have additions,
> please update this section or the CHANGELOG.

---
## 0.26.0 — Next Breaking-Change Release (Planned)

No items committed yet. Candidates will be drawn from the API polish and
deprecation work completed during the 0.26.x hardening cycle. Any symbol
deprecated in 0.25.x or earlier that has been stable for at least two minor
versions is eligible for removal here.

---

## 1.0.0 — Stable Release

### Entry Criteria

All of the following must be true before tagging 1.0.0.
Status markers reflect the 0.25.1 audit (2026-07-29).

#### ✅ Done
- [x] No known P0/P1 bugs.
- [x] No Material `Icons.*` in widget implementations.
- [x] Light mode and dark mode produce acceptable visuals for all widgets.
  *(0.18.6 shipped `GlassTheme.brightnessOf` as the single brightness authority;
  all 26+ widget files migrated. Remaining gap: golden coverage in
  `Brightness.light`.)*
- [x] No deprecated symbols from pre-0.15 remain (0.18.0 shims stay through 1.x).

#### ⚠️ Partial / Needs Verification
- [x] All public API dartdoc complete (every public class, method, parameter).
  *100% complete (0.28.1). `public_member_api_docs` lint permanently enabled.
  Internal layout engines moved to `lib/src/` per Dart convention.*
- [x] Test coverage ≥ 90% on public API surface.
  *Achieved ~92% coverage (the physical ceiling excluding GPU/web paths).*
- [ ] Example app demonstrates every widget with working code.
  *Not verified against the current widget catalogue.*
- [ ] Tested on all platforms: iOS (Impeller), Android (Impeller), Android (Skia),
  Web, macOS, Windows.
  *iOS + Android confirmed. Web, Windows, macOS need explicit QA passes.*
- [ ] CHANGELOG documents every breaking change from 0.x with migration guides.
  *Not audited against 0.20–0.25 changes.*
- [ ] README widget table is accurate and complete.
  *Written for 0.15.x era — likely stale.*

#### ❌ Not Done — Blocking

> **Accessibility & Keyboard Support** *(estimated 4–6 weeks)*
>
> Only 17 of 70 widget files have any `Semantics` usage. Every interactive widget
> must support Tab focus traversal and Enter/Space activation before 1.0.
> Affected widgets include `GlassButton`, `GlassSwitch`, `GlassSlider`,
> `GlassSegmentedControl`, `GlassMenu`, `GlassSheet`, `GlassDialog`,
> `GlassActionSheet`, `GlassPicker`, `GlassTextField`, `GlassSearchBar`,
> `GlassChip`, `GlassListTile`, and more.
>
> This is the largest remaining body of work.

- [ ] **Keyboard & focus support** — all interactive widgets support Tab
  focus traversal and Enter/Space activation for macOS/iPadOS keyboard use.
  `FocusNode` handling, `Semantics` wrapping, and activate callbacks required
  across all interactive widgets listed above.

- [x] **RTL layout verified** *(completed 0.28.0)*
  `EdgeInsetsDirectional` / `AlignmentDirectional` audit across all widgets
  with directional padding. 8 new RTL layout audit tests added. Zero regressions.

- [x] **No hardcoded `Colors.*`** — *(shipped 2026-07-30)*
  All 30+ hits resolved. Barrier colours → `GlassDefaults.barrierColor`;
  drag-handle specular tints → `CupertinoColors` + `GlassDefaults` optical
  constants; `GlassProgressIndicator` blue → `CupertinoColors.activeBlue.resolveFrom(context)`.
  Structural `Colors.transparent` and math-anchor hex values whitelisted with
  `// Whitelisted:` comments. `dart analyze` clean; 2450 tests pass.

- [x] **`docs/PLATFORM_SUPPORT.md`** — shipped 2026-07-30.
  Documents per-platform quality tiers, Skia vs Impeller rendering differences,
  Web CanvasKit `LiquidOval` clipping bug, Windows SkSL shader rules, the
  `platformViewBackdrop` quality cliff, the QA status matrix, and issue
  filing guidance.

### Semver Commitment

From 1.0.0 onward:
- **Patch** (1.0.x): Bug fixes only.
- **Minor** (1.x.0): New widgets, new parameters, non-breaking additions.
- **Major** (2.0.0): Breaking changes (widget removal, parameter rename, behaviour change).

---

## Future (Post-1.0)

Ideas for consideration after stable. None of these are committed.

### New Widgets
- [ ] `GlassSplitView` — proper `UISplitViewController` equivalent with
  adaptive columns, swipe-to-collapse, and navigation state. This is the widget
  `GlassSideBar` wanted to be but wasn't ready for.
- [ ] `GlassDatePicker` / `GlassTimePicker` — iOS date/time picker wheels with
  glass treatment.
- [ ] `GlassColorWell` — iOS 26 colour picker pill.
- [ ] `GlassNavigationTransition` — coordinated glass morphing during
  `CupertinoPageRoute` push/pop transitions.

### Enhancements
- [ ] **Scroll-to-minimize** (`GlassBarMinimizeBehavior.onScrollDown`) — tab bar
  shrinks on scroll-down, re-expands on scroll-up. Matches iOS 26
  `tabBarMinimizeBehavior`. High priority post-1.0.
- [x] **Tab bar bottom accessory** — persistent widget (mini player) above
  the tab bar that animates with minimize. Matches iOS 26 `tabViewBottomAccessory`.
  Currently achieved via `GlassScaffold.bodyOverlays` manually.
- [ ] Scroll-driven glass materialisation — app bar surface that transitions
  from transparent to glass on scroll (the feature removed from `GlassAppBar`
  in 0.14.0, done properly as a standalone widget or `GlassScaffold` feature).
- [ ] `GlassToast` queue management — show multiple toasts sequentially
  instead of overlapping.
- [ ] Drag-to-reorder support in `GlassTabBar.bottom()` — long-press to rearrange
  tabs, matching iOS tab bar customisation.
- [ ] `GlassSheet` snap points — configurable detent heights (peek / half /
  full) matching `UISheetPresentationController.Detent`.
- [ ] **`GlassAppBar` Phase 3 compact search icon** — when both
  `GlassLargeTitle.searchBar` and `GlassAppBar.largeTitleController` are in use
  and `searchBarCollapseProgress == 1.0`, the navigation bar should grow slightly
  and show a compact search affordance (a pill or icon button) that re-expands
  the search bar when tapped. This matches iOS 26's `UINavigationItem.searchController`
  end-state in apps like Mail and Contacts.
  **Blocked by:** `GlassAppBar` currently implements `ObstructingPreferredSizeWidget`
  with a fixed `preferredSize`. Phase 3 requires the bar to change height
  dynamically, which touches the layout contract with `Scaffold` /
  `CupertinoPageScaffold`. This needs careful architecture work and its own
  breaking-change release plan. **Phase 1 + 2 (shipped in 0.19.6) deliver 90%
  of the value; Phase 3 is a polish milestone.**

### Ecosystem
- [ ] Dedicated documentation site (GitHub Pages or similar).
- [ ] Figma/Sketch component library matching the widget catalogue.
- [ ] VS Code / IntelliJ snippet pack for common widget patterns.

