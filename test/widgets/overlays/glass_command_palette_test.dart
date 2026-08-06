import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_liquid_glass_widgets/types/glass_command.dart';
import 'package:flutter_liquid_glass_widgets/widgets/overlays/glass_command_palette.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../shared/test_helpers.dart';

void main() {
  setUp(GlassCommandPalette.debugResetRecents);

  List<String> selected = [];
  List<GlassCommand> makeCommands() {
    selected = [];
    return [
      GlassCommand(
        id: 'new-file',
        label: 'New File',
        keywords: const ['create'],
        onSelect: () => selected.add('new-file'),
      ),
      GlassCommand(
        id: 'open-file',
        label: 'Open File',
        onSelect: () => selected.add('open-file'),
      ),
      GlassCommand(
        id: 'toggle-theme',
        label: 'Toggle Theme',
        keywords: const ['dark mode', 'appearance'],
        onSelect: () => selected.add('toggle-theme'),
      ),
    ];
  }

  group('GlassCommandPalette', () {
    testWidgets('renders every command when the query is empty',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(child: GlassCommandPalette(commands: makeCommands())),
      );
      await tester.pumpAndSettle();

      expect(find.text('New File'), findsOneWidget);
      expect(find.text('Open File'), findsOneWidget);
      expect(find.text('Toggle Theme'), findsOneWidget);
    });

    testWidgets('fuzzy-filters commands as the query changes',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(child: GlassCommandPalette(commands: makeCommands())),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(CupertinoTextField), 'theme');
      await tester.pumpAndSettle();

      expect(find.text('Toggle Theme'), findsOneWidget);
      expect(find.text('New File'), findsNothing);
      expect(find.text('Open File'), findsNothing);
    });

    testWidgets('matches against keywords, not just the label',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(child: GlassCommandPalette(commands: makeCommands())),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(CupertinoTextField), 'dark mode');
      await tester.pumpAndSettle();

      expect(find.text('Toggle Theme'), findsOneWidget);
      expect(find.text('New File'), findsNothing);
    });

    testWidgets('shows the empty state when nothing matches', (tester) async {
      await tester.pumpWidget(
        createTestApp(child: GlassCommandPalette(commands: makeCommands())),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(CupertinoTextField), 'zzz-no-match');
      await tester.pumpAndSettle();

      expect(find.text('No results'), findsOneWidget);
    });

    testWidgets('tapping a command activates it', (tester) async {
      await tester.pumpWidget(
        createTestApp(child: GlassCommandPalette(commands: makeCommands())),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open File'));
      await tester.pumpAndSettle();

      expect(selected, ['open-file']);
    });

    testWidgets('Enter activates the first (highlighted) result',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(child: GlassCommandPalette(commands: makeCommands())),
      );
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(selected, ['new-file']);
    });

    testWidgets('ArrowDown moves the highlight before Enter activates it',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(child: GlassCommandPalette(commands: makeCommands())),
      );
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(selected, ['open-file']);
    });

    testWidgets('ArrowUp wraps around to the last result', (tester) async {
      await tester.pumpWidget(
        createTestApp(child: GlassCommandPalette(commands: makeCommands())),
      );
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(selected, ['toggle-theme']);
    });

    testWidgets('typing narrows results and resets the highlight to 0',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(child: GlassCommandPalette(commands: makeCommands())),
      );
      await tester.pumpAndSettle();

      // Move highlight to the last item, then narrow the query so only one
      // result remains — Enter should activate that remaining result, not
      // whatever numeric index was highlighted before filtering.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.enterText(find.byType(CupertinoTextField), 'theme');
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(selected, ['toggle-theme']);
    });

    testWidgets('recently activated commands are surfaced first next time',
        (tester) async {
      final commands = makeCommands();
      Widget openButton() => Builder(
            builder: (context) => TextButton(
              onPressed: () =>
                  GlassCommandPalette.show(context, commands: commands),
              child: const Text('Open'),
            ),
          );

      // Each show() presents a genuinely fresh palette (a new dialog route
      // -> new State), matching real usage — unlike pumping the same widget
      // twice, which Flutter would just update in place.
      await tester.pumpWidget(createTestApp(child: openButton()));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Toggle Theme'));
      await tester.pumpAndSettle();

      expect(selected, ['toggle-theme']);

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // 'Toggle Theme' (just activated) now renders before 'New File'.
      final themeCenter = tester.getCenter(find.text('Toggle Theme'));
      final newFileCenter = tester.getCenter(find.text('New File'));
      expect(themeCenter.dy, lessThan(newFileCenter.dy));
    });

    testWidgets('show() presents the palette as a modal', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) => TextButton(
              onPressed: () => GlassCommandPalette.show(
                context,
                commands: makeCommands(),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(GlassCommandPalette), findsOneWidget);
      expect(find.text('New File'), findsOneWidget);
    });

    testWidgets('Escape dismisses a palette presented via show()',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) => TextButton(
              onPressed: () => GlassCommandPalette.show(
                context,
                commands: makeCommands(),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.byType(GlassCommandPalette), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(find.byType(GlassCommandPalette), findsNothing);
    });
  });

  group('GlassCommandPaletteScope', () {
    testWidgets('⌘K opens the palette', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassCommandPaletteScope(
            commands: makeCommands(),
            child: const SizedBox.expand(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyK);
      await tester.pumpAndSettle();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyK);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);

      expect(find.byType(GlassCommandPalette), findsOneWidget);
    });

    testWidgets('Ctrl+K opens the palette', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassCommandPaletteScope(
            commands: makeCommands(),
            child: const SizedBox.expand(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyK);
      await tester.pumpAndSettle();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyK);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);

      expect(find.byType(GlassCommandPalette), findsOneWidget);
    });
  });
}
