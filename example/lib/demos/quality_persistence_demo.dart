/// Adaptive Quality Persistence Demo
///
/// Showcases [GlassQualityPersistence] — [GlassAdaptiveScope]'s settled
/// [GlassQuality] survives app restarts instead of re-running its ~3-second
/// warm-up benchmark on every cold start.
///
/// A single running demo can't literally kill and relaunch the process, so
/// this proves the same thing a relaunch would: writing a quality to disk,
/// then reading it back through a *brand new* [GlassQualityPersistence]
/// instance — byte-for-byte what `main()` does on a real cold start — and
/// timing how fast that read is versus the ~3000ms benchmark it replaces.
///
/// Run standalone: `flutter run -t lib/demos/quality_persistence_demo.dart`
library;

import 'package:flutter/cupertino.dart';

import 'package:flutter_liquid_glass_widgets/liquid_glass_widgets.dart';

/// Isolated storage key so this demo never collides with the host app's own
/// persisted quality (relevant when embedded in the showcase gallery, which
/// doesn't itself enable adaptiveQuality/persistence).
const _kPersistenceKey =
    'flutter_liquid_glass_widgets.demo.quality_persistence_demo';

final _persistence = GlassQualityPersistence.auto(key: _kPersistenceKey);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize(qualityPersistence: _persistence);
  runApp(LiquidGlassWidgets.wrap(child: const QualityPersistenceDemoApp()));
}

class QualityPersistenceDemoApp extends StatelessWidget {
  const QualityPersistenceDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Quality Persistence',
      theme: const CupertinoThemeData(brightness: Brightness.dark),
      home: const QualityPersistenceDemo(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DEMO PAGE
// ─────────────────────────────────────────────────────────────────────────────

class QualityPersistenceDemo extends StatefulWidget {
  const QualityPersistenceDemo({super.key});

  @override
  State<QualityPersistenceDemo> createState() =>
      _QualityPersistenceDemoState();
}

class _QualityPersistenceDemoState extends State<QualityPersistenceDemo> {
  GlassQuality? _savedOnDisk;
  GlassQuality? _lastColdStartRead;
  Duration? _lastColdStartLatency;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _persistence.ready.then((value) {
      if (mounted) setState(() => _savedOnDisk = value);
    });
  }

  Future<void> _save(GlassQuality quality) async {
    setState(() => _busy = true);
    await _persistence.persist(quality);
    if (!mounted) return;
    setState(() {
      _savedOnDisk = quality;
      _busy = false;
    });
  }

  Future<void> _simulateColdStart() async {
    setState(() => _busy = true);
    // A brand new instance, pointed at the same key, re-reads from disk
    // exactly like a real relaunch's main() would — nothing here is cached
    // or faked.
    final stopwatch = Stopwatch()..start();
    final fresh = GlassQualityPersistence.auto(key: _kPersistenceKey);
    final value = await fresh.ready;
    stopwatch.stop();
    if (!mounted) return;
    setState(() {
      _lastColdStartRead = value;
      _lastColdStartLatency = stopwatch.elapsed;
      _busy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // adaptiveQuality + qualityPersistence scoped to this demo screen only —
    // exactly the one-line API from the README, just called locally instead
    // of at the app root so this file stays standalone-runnable.
    return LiquidGlassWidgets.wrap(
      adaptiveQuality: true,
      qualityPersistence: _persistence,
      child: GlassScaffold(
        background: const ColoredBox(color: Color(0xFF0B0B0F)),
        statusBarStyle: GlassStatusBarStyle.light,
        topEdgeFade: true,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
            children: [
              const Text(
                'Adaptive Quality\nPersistence',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: CupertinoColors.white,
                  letterSpacing: -0.5,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'GlassAdaptiveScope normally re-benchmarks the device for '
                '~3 seconds on every cold start. GlassQualityPersistence.auto() '
                'remembers the settled quality across launches instead.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: CupertinoColors.white.withValues(alpha: 0.65),
                ),
              ),
              const SizedBox(height: 28),

              // ── Live scope status ────────────────────────────────────────
              Builder(builder: (context) {
                final scope = GlassAdaptiveScopeData.maybeOf(context);
                return _StatusCard(
                  title: 'Live GlassAdaptiveScope',
                  rows: [
                    _StatusRow(
                      label: 'Effective quality (this session)',
                      value: scope?.effectiveQuality.name ?? '—',
                    ),
                    _StatusRow(
                      label: 'Phase',
                      value: scope?.phase.name ?? '—',
                    ),
                  ],
                );
              }),
              const SizedBox(height: 16),
              _StatusCard(
                title: 'GlassQualityPersistence',
                rows: [
                  _StatusRow(
                    label: 'Saved on disk',
                    value: _savedOnDisk?.name ?? 'nothing saved yet',
                  ),
                ],
              ),
              const SizedBox(height: 28),

              const Text(
                'Simulate settling on a quality',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'On a real device, Phase 2/3 of GlassAdaptiveScope would call '
                'this automatically once the benchmark settles. Tap one to '
                'write it to disk right now.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: CupertinoColors.white.withValues(alpha: 0.55),
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: GlassQuality.values
                    .map((q) => _ActionButton(
                          label: 'Save "${q.name}"',
                          busy: _busy,
                          onTap: () => _save(q),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 28),

              const Text(
                'Simulate a cold start',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Creates a brand new GlassQualityPersistence instance and '
                'reads the persisted value back from disk — exactly what '
                'main() does on every real relaunch.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: CupertinoColors.white.withValues(alpha: 0.55),
                ),
              ),
              const SizedBox(height: 14),
              _ActionButton(
                label: 'Simulate cold start',
                busy: _busy,
                onTap: _simulateColdStart,
                wide: true,
              ),
              if (_lastColdStartRead != null || _lastColdStartLatency != null)
                Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: _StatusCard(
                    title: 'Result',
                    rows: [
                      _StatusRow(
                        label: 'Restored quality',
                        value: _lastColdStartRead?.name ?? 'nothing saved yet',
                      ),
                      _StatusRow(
                        label: 'Read latency',
                        value: _lastColdStartLatency == null
                            ? '—'
                            : '${_lastColdStartLatency!.inMicroseconds / 1000} ms '
                                '(vs. ~3000 ms for a fresh Phase 2 benchmark)',
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small presentational widgets
// ─────────────────────────────────────────────────────────────────────────────

class _StatusRow {
  const _StatusRow({required this.label, required this.value});
  final String label;
  final String value;
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.title, required this.rows});
  final String title;
  final List<_StatusRow> rows;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      quality: GlassQuality.standard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
              color: CupertinoColors.white.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 10),
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    row.label,
                    style: TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.white.withValues(alpha: 0.65),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      row.value,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.onTap,
    this.busy = false,
    this.wide = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool busy;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    return GlassButton.custom(
      width: wide ? double.infinity : null,
      height: 44,
      shape: const LiquidRoundedRectangle(borderRadius: 12),
      onTap: busy ? () {} : onTap,
      enabled: !busy,
      quality: GlassQuality.standard,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.white,
          ),
        ),
      ),
    );
  }
}
