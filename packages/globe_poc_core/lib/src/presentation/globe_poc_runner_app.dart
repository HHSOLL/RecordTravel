import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';

import '../contracts/globe_engine_adapter.dart';
import '../controller/globe_poc_controller.dart';
import '../fixtures/globe_fixture_factory.dart';
import '../models/globe_models.dart';

final globeFixtureProvider = Provider<GlobeFixture>((ref) {
  throw UnimplementedError(
    'Override globeFixtureProvider in GlobePocRunnerApp.',
  );
});

final globeControllerProvider = Provider<GlobePocController>((ref) {
  throw UnimplementedError(
    'Override globeControllerProvider in GlobePocRunnerApp.',
  );
});

final globeBindingProvider = Provider<GlobeEngineBinding>((ref) {
  throw UnimplementedError(
    'Override globeBindingProvider in GlobePocRunnerApp.',
  );
});

class GlobePocRunnerApp extends StatefulWidget {
  const GlobePocRunnerApp({required this.binding, super.key});

  final GlobeEngineBinding binding;

  @override
  State<GlobePocRunnerApp> createState() => _GlobePocRunnerAppState();
}

class _GlobePocRunnerAppState extends State<GlobePocRunnerApp> {
  late final GlobeFixture fixture;
  late final GlobePocController controller;

  @override
  void initState() {
    super.initState();
    fixture = GlobeFixtureFactory.buildDefault();
    controller = GlobePocController(fixture: fixture);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        globeFixtureProvider.overrideWithValue(fixture),
        globeControllerProvider.overrideWithValue(controller),
        globeBindingProvider.overrideWithValue(widget.binding),
      ],
      child: const _GlobePocMaterialApp(),
    );
  }
}

class _GlobePocMaterialApp extends StatelessWidget {
  const _GlobePocMaterialApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Travel Globe PoC',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF18B6A2)),
        scaffoldBackgroundColor: const Color(0xFF07131D),
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const GlobePocScreen(),
    );
  }
}

class GlobePocScreen extends ConsumerStatefulWidget {
  const GlobePocScreen({super.key});

  @override
  ConsumerState<GlobePocScreen> createState() => _GlobePocScreenState();
}

class _GlobePocScreenState extends ConsumerState<GlobePocScreen> {
  GlobeEngineAdapter? adapter;
  double _lastScale = 1.0;
  Offset? _pointerDownPosition;
  bool _probeLoggingAttached = false;
  bool _autoBenchmarkStarted = false;
  bool _validationLogged = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    adapter ??= ref
        .read(globeBindingProvider)
        .createAdapter(
          fixture: ref.read(globeFixtureProvider),
          controller: ref.read(globeControllerProvider),
        );
    adapter!.initialize();
    if (!_probeLoggingAttached) {
      _probeLoggingAttached = true;
      adapter!.probeResult.addListener(_logProbe);
      _logProbe();
    }
    _runValidationIfNeeded();
    _startAutoBenchmarkIfNeeded();
  }

  @override
  void dispose() {
    if (_probeLoggingAttached) {
      adapter?.probeResult.removeListener(_logProbe);
    }
    adapter?.dispose();
    super.dispose();
  }

  void _logProbe() {
    final binding = ref.read(globeBindingProvider);
    final probe = adapter?.probeResult.value ?? GlobeProbeResult.unknown;
    debugPrint(
      'POC_PROBE|${jsonEncode({'candidate': binding.displayName, 'ready': probe.ready, 'summary': probe.summary, 'blockingIssues': probe.blockingIssues})}',
    );
  }

  void _startAutoBenchmarkIfNeeded() {
    if (_autoBenchmarkStarted) {
      return;
    }
    final config = GlobeBenchmarkConfig.fromEnvironment();
    if (!config.enabled) {
      return;
    }
    _autoBenchmarkStarted = true;
    final controller = ref.read(globeControllerProvider);
    final binding = ref.read(globeBindingProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.runScenario(config.scenario!);
      Future<void>.delayed(Duration(milliseconds: config.durationMs), () {
        final payload = controller.benchmarkSnapshot(
          candidate: binding.displayName,
          scenario: config.scenario!,
        );
        debugPrint('POC_BENCHMARK|${jsonEncode(payload)}');
      });
    });
  }

  void _runValidationIfNeeded() {
    if (_validationLogged) {
      return;
    }
    _validationLogged = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final controller = ref.read(globeControllerProvider);
      final binding = ref.read(globeBindingProvider);
      final size = MediaQuery.of(context).size;
      controller.runValidation(size);
      debugPrint(
        'POC_VALIDATION|${jsonEncode({
          'candidate': binding.displayName,
          'passed': controller.validationReport.passed,
          'metrics': controller.validationReport.metrics.map((metric) => {'label': metric.label, 'value': metric.value, 'threshold': metric.threshold, 'passed': metric.passed}).toList(),
          'notes': controller.validationReport.notes,
        })}',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(globeControllerProvider);
    final binding = ref.watch(globeBindingProvider);
    final size = MediaQuery.of(context).size;
    return AnimatedBuilder(
      animation: Listenable.merge([
        controller,
        adapter?.probeResult ?? ValueNotifier(GlobeProbeResult.unknown),
      ]),
      builder: (context, _) {
        return Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    IgnorePointer(
                      ignoring: kIsWeb,
                      child: adapter!.buildRenderer(context),
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapUp: kIsWeb
                          ? null
                          : (details) => controller.tapViewport(
                                point: details.localPosition,
                                viewport: size,
                              ),
                      onPanUpdate: (details) => controller.orbit(details.delta),
                      onScaleStart: (_) => _lastScale = 1.0,
                      onScaleUpdate: (details) {
                        final ratio = details.scale / _lastScale;
                        _lastScale = details.scale;
                        controller.zoom(ratio);
                      },
                      child: Listener(
                        behavior: HitTestBehavior.opaque,
                        onPointerDown: kIsWeb
                            ? (event) {
                                _pointerDownPosition = event.localPosition;
                              }
                            : null,
                        onPointerUp: kIsWeb
                            ? (event) {
                                final origin = _pointerDownPosition;
                                _pointerDownPosition = null;
                                if (origin == null) {
                                  return;
                                }
                                if ((event.localPosition - origin).distance <= 8) {
                                  controller.tapViewport(
                                    point: event.localPosition,
                                    viewport: size,
                                  );
                                }
                              }
                            : null,
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 24,
                left: 24,
                right: 24,
                child: _InfoCard(
                  binding: binding,
                  probe: adapter!.probeResult.value,
                  controller: controller,
                ),
              ),
              Positioned(
                left: 24,
                right: 24,
                bottom: 24,
                child: _ControlDock(controller: controller, viewport: size),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.binding,
    required this.probe,
    required this.controller,
  });

  final GlobeEngineBinding binding;
  final GlobeProbeResult probe;
  final GlobePocController controller;

  @override
  Widget build(BuildContext context) {
    final selected = controller.selectedCountryCode ?? 'none';
    final city = controller.selectedCityId ?? 'none';
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: DefaultTextStyle(
          style: const TextStyle(color: Colors.white),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${binding.displayName} · ${probe.summary}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text('Selected country: $selected · Selected city: $city'),
              Text(
                'FPS ${controller.stats.averageFps.toStringAsFixed(1)} · p95 ${controller.stats.p95FrameTimeMs.toStringAsFixed(1)} ms · worst ${controller.stats.worstFrameTimeMs.toStringAsFixed(1)} ms',
              ),
              Text(
                'Memory: ${controller.stats.memoryLabel} · Dropped: ${controller.stats.droppedFrameCount}',
              ),
              Text(
                'Validation: ${controller.validationReport.passed ? 'PASS' : 'PENDING/FAIL'}',
              ),
              if (probe.blockingIssues.isNotEmpty)
                Text('Blocking: ${probe.blockingIssues.join(' | ')}'),
            ],
          ),
        ),
      ),
    );
  }
}

class _ControlDock extends StatelessWidget {
  const _ControlDock({required this.controller, required this.viewport});

  final GlobePocController controller;
  final Size viewport;
  static const _demoCityId = 'city_14';

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white24),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            FilledButton.tonal(
              onPressed: controller.resetView,
              child: const Text('Reset'),
            ),
            FilledButton.tonal(
              onPressed: () => controller.focusCountry(controller.demoCountryCode),
              child: const Text('Focus Country'),
            ),
            FilledButton.tonal(
              onPressed: () => controller.focusCity(_demoCityId),
              child: const Text('Focus City'),
            ),
            FilledButton.tonal(
              onPressed: () => controller.runValidation(viewport),
              child: const Text('Validate'),
            ),
            FilledButton.tonal(
              onPressed: () => controller.runScenario(BenchmarkScenario.idle),
              child: const Text('Idle'),
            ),
            FilledButton.tonal(
              onPressed: () =>
                  controller.runScenario(BenchmarkScenario.interaction),
              child: const Text('Interaction'),
            ),
            FilledButton.tonal(
              onPressed: () =>
                  controller.runScenario(BenchmarkScenario.density),
              child: const Text('Density'),
            ),
            FilledButton.tonal(
              onPressed: () =>
                  controller.runScenario(BenchmarkScenario.playback),
              child: const Text('Playback'),
            ),
            FilledButton.tonal(
              onPressed: () => controller.runScenario(BenchmarkScenario.soak),
              child: const Text('Soak'),
            ),
          ],
        ),
      ),
    );
  }
}
