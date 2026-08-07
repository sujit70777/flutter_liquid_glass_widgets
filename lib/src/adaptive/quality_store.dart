import '../../types/glass_quality.dart';

/// A pluggable backend for persisting `GlassAdaptiveScope`'s settled
/// [GlassQuality] across app cold starts.
///
/// Implement this to back `GlassQualityPersistence` with any storage layer
/// (Hive, a database, a platform channel, ...). Most apps don't need a custom
/// implementation — `GlassQualityPersistence.auto` ships a `shared_preferences`
/// -backed one out of the box.
abstract class GlassQualityStore {
  const GlassQualityStore();

  /// Reads the previously-persisted quality, or `null` if none has been
  /// saved yet (e.g. first launch).
  Future<GlassQuality?> read();

  /// Persists [quality] as the new settled value.
  Future<void> write(GlassQuality quality);
}
