/// Bridges [GlassAdaptiveScope] diagnostics to a Dart VM service extension.
///
/// **Scope of what this ships:** this registers query-able *data*
/// (`ext.flutter_liquid_glass_widgets.adaptiveScope`) that a Flutter
/// DevTools extension panel would call via `callServiceExtension`. It does
/// **not** include a DevTools UI panel — a real panel is a separate
/// `extension/devtools/` web app that has to be built and verified against
/// a live DevTools session (VM service protocol, `postMessage` extension
/// API), which isn't something that can be responsibly shipped without that
/// live verification. This file is the safe, independently-testable half:
/// the data source such a panel would read from.
///
/// Not part of the main `liquid_glass_widgets.dart` barrel — import it
/// explicitly, since registering a VM service extension is a deliberate,
/// app-wide opt-in:
///
/// ```dart
/// import 'package:flutter_liquid_glass_widgets/glass_devtools_bridge.dart';
///
/// GlassAdaptiveScope(
///   onDiagnostic: GlassDevToolsBridge.record,
///   child: MyApp(),
/// )
/// ```
///
/// Once registered, the current quality-tier state is queryable from any VM
/// service client (including `dart:developer`-aware tooling, not just a
/// purpose-built DevTools panel) via
/// `ext.flutter_liquid_glass_widgets.adaptiveScope`.
library;

import 'dart:developer' as developer;

import 'package:meta/meta.dart';

import 'widgets/shared/glass_adaptive_scope.dart';

/// See the library-level doc comment above.
abstract final class GlassDevToolsBridge {
  static bool _registered = false;
  static GlassAdaptiveDiagnostic? _last;

  /// Records [diagnostic] as the latest known adaptive-quality state and
  /// registers the service extension on first use.
  ///
  /// Pass this directly as `GlassAdaptiveScope.onDiagnostic`.
  static void record(GlassAdaptiveDiagnostic diagnostic) {
    _last = diagnostic;
    if (_registered) return;
    _registered = true;
    developer.registerExtension(
      'ext.flutter_liquid_glass_widgets.adaptiveScope',
      _handleQuery,
    );
  }

  static Future<developer.ServiceExtensionResponse> _handleQuery(
    String method,
    Map<String, String> parameters,
  ) async {
    return developer.ServiceExtensionResponse.result(debugEncode(_last));
  }

  /// JSON-encodes [diagnostic] the way the registered extension responds.
  ///
  /// Exposed for tests and for anyone building a DevTools panel against
  /// this bridge — a plain function, independent of VM service registration.
  @visibleForTesting
  static String debugEncode(GlassAdaptiveDiagnostic? diagnostic) {
    if (diagnostic == null) return '{"available":false}';
    final buffer = StringBuffer('{')
      ..write('"available":true,')
      ..write('"from":"${diagnostic.from.name}",')
      ..write('"to":"${diagnostic.to.name}",')
      ..write('"reason":"${diagnostic.reason.name}",')
      ..write('"phase":"${diagnostic.phase.name}"');
    if (diagnostic.p75Ms != null) {
      buffer.write(',"p75Ms":${diagnostic.p75Ms}');
    }
    if (diagnostic.p95Ms != null) {
      buffer.write(',"p95Ms":${diagnostic.p95Ms}');
    }
    if (diagnostic.framesMeasured != null) {
      buffer.write(',"framesMeasured":${diagnostic.framesMeasured}');
    }
    buffer.write('}');
    return buffer.toString();
  }

  /// Invokes the exact function registered as the VM service extension
  /// handler, without needing a live VM service connection — this is what
  /// [record] wires up to `ext.flutter_liquid_glass_widgets.adaptiveScope`.
  @visibleForTesting
  static Future<developer.ServiceExtensionResponse> debugHandleQuery() =>
      _handleQuery('ext.flutter_liquid_glass_widgets.adaptiveScope', const {});

  /// The most recently recorded diagnostic, if any. Exposed for tests.
  @visibleForTesting
  static GlassAdaptiveDiagnostic? get debugLast => _last;
}
