import 'package:shared_preferences/shared_preferences.dart';

import '../../types/glass_quality.dart';
import 'quality_store.dart';

/// Default [GlassQualityStore] backing `GlassQualityPersistence.auto()`.
///
/// Persists the settled [GlassQuality] as its enum name (e.g. `"standard"`)
/// under a single [SharedPreferences] key.
class SharedPreferencesQualityStore extends GlassQualityStore {
  const SharedPreferencesQualityStore({
    this.key = 'flutter_liquid_glass_widgets.glass_quality',
  });

  /// The `SharedPreferences` key the quality is stored under.
  final String key;

  @override
  Future<GlassQuality?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(key);
    if (name == null) return null;
    for (final quality in GlassQuality.values) {
      if (quality.name == name) return quality;
    }
    // Unknown/stale value (e.g. from a future enum member) — ignore it
    // rather than throwing, so Phase 2 just re-benchmarks normally.
    return null;
  }

  @override
  Future<void> write(GlassQuality quality) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, quality.name);
  }
}
