import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_liquid_glass_widgets/liquid_glass_widgets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SharedPreferencesQualityStore', () {
    test('read() returns null when nothing was ever written', () async {
      const store = SharedPreferencesQualityStore();

      expect(await store.read(), isNull);
    });

    test('round-trips a written quality', () async {
      const store = SharedPreferencesQualityStore();

      await store.write(GlassQuality.premium);

      expect(await store.read(), GlassQuality.premium);
    });

    test('a later write overwrites an earlier one', () async {
      const store = SharedPreferencesQualityStore();

      await store.write(GlassQuality.minimal);
      await store.write(GlassQuality.standard);

      expect(await store.read(), GlassQuality.standard);
    });

    test('read() ignores an unrecognized stored value', () async {
      SharedPreferences.setMockInitialValues({
        'flutter_liquid_glass_widgets.glass_quality': 'ultra_hd',
      });
      const store = SharedPreferencesQualityStore();

      expect(await store.read(), isNull);
    });

    test('separate stores with different keys do not collide', () async {
      const storeA = SharedPreferencesQualityStore(key: 'a');
      const storeB = SharedPreferencesQualityStore(key: 'b');

      await storeA.write(GlassQuality.premium);
      await storeB.write(GlassQuality.minimal);

      expect(await storeA.read(), GlassQuality.premium);
      expect(await storeB.read(), GlassQuality.minimal);
    });
  });
}
