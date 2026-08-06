import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../src/renderer/liquid_glass_renderer.dart';
import '../../theme/glass_theme.dart';
import '../../types/glass_command.dart';
import '../../types/glass_quality.dart';
import '../../utils/glass_fuzzy_match.dart';
import '../containers/glass_card.dart';
import '../input/glass_search_bar.dart';
import '../shared/adaptive_liquid_glass_layer.dart';
import 'glass_menu_item.dart';

/// A Spotlight/Raycast-style command palette in liquid glass.
///
/// Present it with [GlassCommandPalette.show], or wrap your app in
/// [GlassCommandPaletteScope] to bind a global ⌘K / Ctrl+K shortcut. Typing
/// fuzzy-filters [commands] by [GlassCommand.label] and
/// [GlassCommand.keywords]; arrow keys move the highlight, Enter activates
/// it, and Escape (or a tap outside) dismisses the palette. When the query
/// is empty, the most recently activated commands are surfaced first.
///
/// ```dart
/// GlassCommandPalette.show(
///   context,
///   commands: [
///     GlassCommand(
///       id: 'new-file',
///       label: 'New File',
///       icon: const Icon(CupertinoIcons.doc),
///       shortcutLabel: '⌘N',
///       onSelect: () => createNewFile(),
///     ),
///     GlassCommand(
///       id: 'toggle-theme',
///       label: 'Toggle Theme',
///       keywords: const ['dark mode', 'light mode', 'appearance'],
///       onSelect: () => toggleTheme(),
///     ),
///   ],
/// );
/// ```
class GlassCommandPalette extends StatefulWidget {
  /// Creates a command palette. Typically not constructed directly — use
  /// [GlassCommandPalette.show].
  const GlassCommandPalette({
    super.key,
    required this.commands,
    this.placeholder = 'Search…',
    this.emptyResultsBuilder,
    this.maxHeight = 420,
    this.maxWidth = 560,
    this.settings,
    this.quality,
  });

  /// The commands available for search and activation.
  final List<GlassCommand> commands;

  /// Placeholder text for the search field.
  final String placeholder;

  /// Builder for the "no matches" state. Defaults to a centered caption.
  final WidgetBuilder? emptyResultsBuilder;

  /// Maximum height of the results list area.
  final double maxHeight;

  /// Maximum width of the palette surface.
  final double maxWidth;

  /// Custom glass settings for the palette surface.
  final LiquidGlassSettings? settings;

  /// Rendering quality for the glass effect.
  final GlassQuality? quality;

  /// Ids of recently activated commands, most-recent first, shared by every
  /// [GlassCommandPalette] in the process — this is what "recent commands
  /// surfaced first" is keyed against. Capped at 10 entries.
  static final List<String> _recentIds = <String>[];

  /// Clears the recent-commands list shared across every palette instance.
  ///
  /// Exposed for tests, which would otherwise leak recency state (a static,
  /// process-lifetime list) across test cases; production code never needs
  /// this.
  @visibleForTesting
  static void debugResetRecents() => _recentIds.clear();

  /// Presents the palette as a modal overlay above [context].
  ///
  /// Returns a future that completes when the palette is dismissed, either
  /// by activating a command, pressing Escape, or tapping outside (when
  /// [barrierDismissible] is true).
  static Future<void> show(
    BuildContext context, {
    required List<GlassCommand> commands,
    String placeholder = 'Search…',
    WidgetBuilder? emptyResultsBuilder,
    double maxHeight = 420,
    double maxWidth = 560,
    LiquidGlassSettings? settings,
    GlassQuality? quality,
    bool barrierDismissible = true,
  }) {
    return showCupertinoDialog<void>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => GlassCommandPalette(
        commands: commands,
        placeholder: placeholder,
        emptyResultsBuilder: emptyResultsBuilder,
        maxHeight: maxHeight,
        maxWidth: maxWidth,
        settings: settings,
        quality: quality,
      ),
    );
  }

  @override
  State<GlassCommandPalette> createState() => _GlassCommandPaletteState();
}

class _GlassCommandPaletteState extends State<GlassCommandPalette> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  late List<GlassCommand> _results;
  late List<GlobalKey> _itemKeys;
  int _highlighted = 0;

  @override
  void initState() {
    super.initState();
    _setResults(_ordered(widget.commands));
    _controller.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onQueryChanged);
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Recent-first ordering used when the query is empty: known recent ids
  /// (most-recent first), then the rest in their original declaration order.
  List<GlassCommand> _ordered(List<GlassCommand> commands) {
    final byId = {for (final c in commands) c.id: c};
    final recent = [
      for (final id in GlassCommandPalette._recentIds)
        if (byId[id] != null) byId[id]!,
    ];
    final recentIdSet = recent.map((c) => c.id).toSet();
    final rest = commands.where((c) => !recentIdSet.contains(c.id));
    return [...recent, ...rest];
  }

  void _setResults(List<GlassCommand> results) {
    _results = results;
    _itemKeys = List.generate(results.length, (_) => GlobalKey());
    _highlighted = 0;
  }

  void _onQueryChanged() {
    final query = _controller.text.trim();
    setState(() {
      if (query.isEmpty) {
        _setResults(_ordered(widget.commands));
        return;
      }
      final scored = <(GlassCommand, double)>[];
      for (final command in widget.commands) {
        final target = ([command.label, ...command.keywords]).join(' ');
        final score = glassFuzzyScore(query, target);
        if (score != null) scored.add((command, score));
      }
      scored.sort((a, b) => b.$2.compareTo(a.$2));
      _setResults([for (final entry in scored) entry.$1]);
    });
  }

  void _moveHighlight(int delta) {
    if (_results.isEmpty) return;
    setState(() {
      _highlighted = (_highlighted + delta) % _results.length;
      if (_highlighted < 0) _highlighted += _results.length;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final itemContext = _itemKeys[_highlighted].currentContext;
      if (itemContext != null) {
        Scrollable.ensureVisible(
          itemContext,
          alignment: 0.5,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _activateHighlighted() {
    if (_results.isEmpty || _highlighted >= _results.length) return;
    _select(_results[_highlighted]);
  }

  void _select(GlassCommand command) {
    GlassCommandPalette._recentIds
      ..remove(command.id)
      ..insert(0, command.id);
    if (GlassCommandPalette._recentIds.length > 10) {
      GlassCommandPalette._recentIds.removeLast();
    }
    Navigator.of(context).maybePop();
    command.onSelect();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveSettings = widget.settings ?? const LiquidGlassSettings();
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
            _moveHighlight(1),
        const SingleActivator(LogicalKeyboardKey.arrowUp): () =>
            _moveHighlight(-1),
        const SingleActivator(LogicalKeyboardKey.enter): _activateHighlighted,
        const SingleActivator(LogicalKeyboardKey.numpadEnter):
            _activateHighlighted,
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            Navigator.of(context).maybePop(),
      },
      child: Align(
        alignment: const Alignment(0, -0.3),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: widget.maxWidth),
          child: GlassCard(
            useOwnLayer: true,
            settings: widget.settings,
            quality: widget.quality,
            padding: const EdgeInsets.all(8),
            child: AdaptiveLiquidGlassLayer(
              settings: effectiveSettings,
              quality: widget.quality,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                    child: GlassSearchBar(
                      controller: _controller,
                      focusNode: _focusNode,
                      placeholder: widget.placeholder,
                      autofocus: true,
                      quality: widget.quality,
                      onSubmitted: (_) => _activateHighlighted(),
                    ),
                  ),
                  Flexible(
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(maxHeight: widget.maxHeight),
                      child: _results.isEmpty
                          ? _EmptyResults(builder: widget.emptyResultsBuilder)
                          : ListView.builder(
                              controller: _scrollController,
                              shrinkWrap: true,
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              itemCount: _results.length,
                              itemBuilder: (context, index) {
                                final command = _results[index];
                                return GlassMenuItem(
                                  key: _itemKeys[index],
                                  title: command.label,
                                  subtitle: command.subtitle,
                                  icon: command.icon,
                                  trailing: command.shortcutLabel == null
                                      ? null
                                      : _ShortcutHint(
                                          label: command.shortcutLabel!),
                                  isPressed: index == _highlighted,
                                  onTap: () => _select(command),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults({this.builder});

  final WidgetBuilder? builder;

  @override
  Widget build(BuildContext context) {
    if (builder != null) return builder!(context);
    final isDark = GlassTheme.brightnessOf(context) == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Center(
        child: Text(
          'No results',
          style: TextStyle(
            color: isDark
                ? const Color(0x99FFFFFF)
                : const Color(0x99000000),
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

class _ShortcutHint extends StatelessWidget {
  const _ShortcutHint({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = GlassTheme.brightnessOf(context) == Brightness.dark;
    return Text(
      label,
      style: TextStyle(
        color: isDark ? const Color(0x66FFFFFF) : const Color(0x66000000),
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

/// Binds a global keyboard shortcut (⌘K on macOS/web, Ctrl+K elsewhere by
/// default) that presents a [GlassCommandPalette] over [child].
///
/// Wrap your app (or a screen) in this to get the shortcut without wiring up
/// a trigger button:
///
/// ```dart
/// GlassCommandPaletteScope(
///   commands: myCommands,
///   child: MyApp(),
/// )
/// ```
///
/// Both the ⌘K and Ctrl+K activators are bound by default regardless of
/// platform (harmless on platforms where one doesn't apply); pass
/// [shortcuts] to override with your own set of activators.
class GlassCommandPaletteScope extends StatelessWidget {
  /// Creates a scope that binds a global shortcut to open the palette.
  const GlassCommandPaletteScope({
    super.key,
    required this.child,
    required this.commands,
    this.shortcuts,
    this.placeholder = 'Search…',
    this.maxHeight = 420,
    this.maxWidth = 560,
    this.settings,
    this.quality,
  });

  /// The subtree the shortcut is scoped to.
  final Widget child;

  /// The commands available for search and activation.
  final List<GlassCommand> commands;

  /// Overrides the default ⌘K / Ctrl+K activators.
  final Set<ShortcutActivator>? shortcuts;

  /// Placeholder text for the search field.
  final String placeholder;

  /// Maximum height of the results list area.
  final double maxHeight;

  /// Maximum width of the palette surface.
  final double maxWidth;

  /// Custom glass settings for the palette surface.
  final LiquidGlassSettings? settings;

  /// Rendering quality for the glass effect.
  final GlassQuality? quality;

  static const Set<ShortcutActivator> _defaultShortcuts = {
    SingleActivator(LogicalKeyboardKey.keyK, meta: true),
    SingleActivator(LogicalKeyboardKey.keyK, control: true),
  };

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return CallbackShortcuts(
          bindings: {
            for (final activator in shortcuts ?? _defaultShortcuts)
              activator: () => GlassCommandPalette.show(
                    context,
                    commands: commands,
                    placeholder: placeholder,
                    maxHeight: maxHeight,
                    maxWidth: maxWidth,
                    settings: settings,
                    quality: quality,
                  ),
          },
          // CallbackShortcuts never requests focus itself (by design — see
          // its docs) — it only sees key events that bubble up from
          // whatever descendant currently holds focus. Claim focus here by
          // default so the shortcut works even before the user has
          // interacted with anything (e.g. a text field) that would
          // otherwise hold it; skipTraversal keeps this invisible to Tab
          // navigation, and any descendant's own autofocus/tap-to-focus
          // still overrides it normally.
          child: Focus(
            autofocus: true,
            skipTraversal: true,
            child: child,
          ),
        );
      },
    );
  }
}
