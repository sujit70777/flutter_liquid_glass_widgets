import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_liquid_glass_widgets/liquid_glass_widgets.dart';

// ---------------------------------------------------------------------------
// Fake store
// ---------------------------------------------------------------------------

class _FakeQualityStore extends GlassQualityStore {
  _FakeQualityStore({GlassQuality? initial}) : _stored = initial;

  GlassQuality? _stored;
  int readCount = 0;
  final List<GlassQuality> writes = [];

  @override
  Future<GlassQuality?> read() async {
    readCount++;
    return _stored;
  }

  @override
  Future<void> write(GlassQuality quality) async {
    _stored = quality;
    writes.add(quality);
  }
}

void main() {
  group('GlassQualityPersistence', () {
    test('kicks off a read immediately at construction', () async {
      final store = _FakeQualityStore(initial: GlassQuality.premium);
      final persistence = GlassQualityPersistence(store);

      expect(store.readCount, 1);
      expect(await persistence.ready, GlassQuality.premium);
    });

    test('resolvedQualityOrNull is null before the read resolves', () {
      final store = _FakeQualityStore(initial: GlassQuality.premium);
      final persistence = GlassQualityPersistence(store);

      expect(persistence.resolvedQualityOrNull, isNull);
    });

    test('resolvedQualityOrNull reflects the stored value once ready',
        () async {
      final store = _FakeQualityStore(initial: GlassQuality.minimal);
      final persistence = GlassQualityPersistence(store);

      await persistence.ready;

      expect(persistence.resolvedQualityOrNull, GlassQuality.minimal);
    });

    test('resolvedQualityOrNull is null when nothing was ever saved',
        () async {
      final store = _FakeQualityStore();
      final persistence = GlassQualityPersistence(store);

      await persistence.ready;

      expect(persistence.resolvedQualityOrNull, isNull);
    });

    test('persist() writes through to the store', () async {
      final store = _FakeQualityStore();
      final persistence = GlassQualityPersistence(store);
      await persistence.ready;

      await persistence.persist(GlassQuality.standard);

      expect(store.writes, [GlassQuality.standard]);
    });

    test('a second read after persist() sees the newly written value',
        () async {
      final store = _FakeQualityStore(initial: GlassQuality.minimal);
      final persistence = GlassQualityPersistence(store);
      await persistence.ready;

      await persistence.persist(GlassQuality.premium);

      final laterPersistence = GlassQualityPersistence(store);
      expect(await laterPersistence.ready, GlassQuality.premium);
    });
  });
}
