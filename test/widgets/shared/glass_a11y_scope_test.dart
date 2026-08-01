// Behavior tests for GlassA11yScope:
//   - maybeOf returns null with no ancestor scope (callers treat that as
//     GlassA11yMode.auto with the default 4.5 minimum contrast)
//   - mode / minimumContrast propagate to descendants
//   - the scope installs a GlassContentAwareScope for descendants
//   - a nested GlassContentAwareScope shadows the auto-installed one
//   - GlassA11yScopeData value equality

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_liquid_glass_widgets/liquid_glass_widgets.dart';

void main() {
  testWidgets('maybeOf returns null with no ancestor scope', (tester) async {
    late BuildContext capturedContext;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        capturedContext = context;
        return const SizedBox();
      }),
    ));

    expect(GlassA11yScope.maybeOf(capturedContext), isNull);
  });

  testWidgets('mode and minimumContrast propagate to descendants',
      (tester) async {
    late BuildContext capturedContext;
    await tester.pumpWidget(MaterialApp(
      home: GlassA11yScope(
        mode: GlassA11yMode.warnOnly,
        minimumContrast: 7.0,
        child: Builder(builder: (context) {
          capturedContext = context;
          return const SizedBox();
        }),
      ),
    ));

    final data = GlassA11yScope.maybeOf(capturedContext);
    expect(data, isNotNull);
    expect(data!.mode, GlassA11yMode.warnOnly);
    expect(data.minimumContrast, 7.0);
  });

  testWidgets('defaults to GlassA11yMode.auto and 4.5 minimum contrast',
      (tester) async {
    late BuildContext capturedContext;
    await tester.pumpWidget(MaterialApp(
      home: GlassA11yScope(
        child: Builder(builder: (context) {
          capturedContext = context;
          return const SizedBox();
        }),
      ),
    ));

    final data = GlassA11yScope.maybeOf(capturedContext)!;
    expect(data.mode, GlassA11yMode.auto);
    expect(data.minimumContrast, 4.5);
  });

  testWidgets('installs a GlassContentAwareScope for descendants',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: GlassA11yScope(
        child: Builder(builder: (context) {
          expect(GlassContentAwareScope.maybeOf(context), isNotNull);
          return const SizedBox();
        }),
      ),
    ));
  });

  testWidgets('a nested GlassContentAwareScope shadows the auto-installed one',
      (tester) async {
    late GlassContentAwareScopeState innerScope;
    await tester.pumpWidget(MaterialApp(
      home: GlassA11yScope(
        child: GlassContentAwareScope(
          child: Builder(builder: (context) {
            innerScope = GlassContentAwareScope.maybeOf(context)!;
            return const SizedBox();
          }),
        ),
      ),
    ));

    final scopes = tester
        .stateList<GlassContentAwareScopeState>(
            find.byType(GlassContentAwareScope))
        .toList();
    expect(scopes, hasLength(2)); // the auto-installed one + the nested one
    expect(innerScope, scopes.last); // nearest ancestor wins
  });

  test('GlassA11yScopeData has value equality', () {
    const a = GlassA11yScopeData(mode: GlassA11yMode.auto, minimumContrast: 4.5);
    const b = GlassA11yScopeData(mode: GlassA11yMode.auto, minimumContrast: 4.5);
    const c = GlassA11yScopeData(mode: GlassA11yMode.off, minimumContrast: 4.5);
    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(a, isNot(c));
  });
}
