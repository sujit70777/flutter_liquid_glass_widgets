import '../../types/glass_quality.dart';
import 'quality_store.dart';
import 'shared_preferences_quality_store.dart';

/// Zero-config persistence for `GlassAdaptiveScope`'s settled [GlassQuality]
/// across app cold starts.
///
/// Without this, `GlassAdaptiveScope` re-runs its ~3-second warm-up benchmark
/// on every cold start, so a device that settled at `minimal` yesterday shows
/// degraded quality for 3 seconds again today before stepping back down.
///
/// ## Usage
///
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   final persistence = GlassQualityPersistence.auto();
///
///   // Optional but recommended: guarantees the read completes before the
///   // first frame, so the very first cold start after this call also skips
///   // the warm-up jank instead of only subsequent ones.
///   await LiquidGlassWidgets.initialize(qualityPersistence: persistence);
///
///   runApp(LiquidGlassWidgets.wrap(
///     child: const MyApp(),
///     adaptiveQuality: true,
///     qualityPersistence: persistence,
///   ));
/// }
/// ```
///
/// Passing the same [GlassQualityPersistence] instance to only `wrap()` still
/// works — the read is kicked off eagerly at construction time and is, in
/// practice, resolved well before the first frame (shader pre-warming in
/// `initialize()` alone typically takes longer than a `SharedPreferences`
/// read). It just isn't a hard guarantee the way awaiting it in `initialize()`
/// is.
class GlassQualityPersistence {
  /// Creates persistence backed by a custom [store]. Most apps should use
  /// [GlassQualityPersistence.auto] instead.
  GlassQualityPersistence(this.store) {
    _readFuture = store.read().then((quality) {
      _hasResolved = true;
      _resolvedQuality = quality;
      return quality;
    });
  }

  /// Zero-config persistence backed by [SharedPreferencesQualityStore].
  factory GlassQualityPersistence.auto({
    String key = 'flutter_liquid_glass_widgets.glass_quality',
  }) =>
      GlassQualityPersistence(SharedPreferencesQualityStore(key: key));

  /// The storage backend this persistence reads from and writes to.
  final GlassQualityStore store;

  late final Future<GlassQuality?> _readFuture;
  bool _hasResolved = false;
  GlassQuality? _resolvedQuality;

  /// Completes with the persisted quality (or `null` if none was saved yet).
  ///
  /// Await this in [LiquidGlassWidgets.initialize] to guarantee the very
  /// first cold start after adding persistence also skips the warm-up
  /// benchmark, instead of only subsequent launches.
  Future<GlassQuality?> get ready => _readFuture;

  /// The persisted quality, if the read has already resolved by the time
  /// this is accessed; `null` otherwise (including "not saved yet").
  ///
  /// Used by [LiquidGlassWidgets.wrap] as a best-effort `initialQuality`
  /// seed when the read wasn't explicitly awaited via [ready].
  GlassQuality? get resolvedQualityOrNull =>
      _hasResolved ? _resolvedQuality : null;

  /// Persists [quality] as the new settled value. Intended to be called from
  /// `GlassAdaptiveScope.onQualityChanged`; [LiquidGlassWidgets.wrap] wires
  /// this automatically when [GlassQualityPersistence] is passed to it.
  Future<void> persist(GlassQuality quality) => store.write(quality);
}
