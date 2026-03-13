import 'dart:async';
import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../fixtures/globe_fixture_factory.dart';
import '../math/globe_math.dart';
import '../models/globe_models.dart';
import '../validation/globe_validation.dart';

class GlobePocController extends ChangeNotifier {
  GlobePocController({GlobeFixture? fixture})
    : fixture = fixture ?? GlobeFixtureFactory.buildDefault();

  final GlobeFixture fixture;
  GlobeCameraPose _cameraPose = const GlobeCameraPose(
    yaw: 0.5,
    pitch: 0.45,
    radius: 3.1,
    fieldOfView: 38,
  );
  GlobeCameraPose get cameraPose => _cameraPose;
  GlobeTextureBundle? _runtimeTextureBundle;
  final Map<int, GlobeCountryLookupEntry> _runtimeCountriesByIndex = {};

  String? selectedCountryCode;
  String? selectedCityId;
  int? selectedCountryIndex;
  BenchmarkScenario? activeScenario;
  double playhead = 0;
  bool playing = false;
  GlobeValidationReport validationReport = GlobeValidationReport.pending();

  final Queue<double> _frameTimes = Queue<double>();
  int _droppedFrames = 0;
  int? _currentMemoryBytes;
  int? _peakMemoryBytes;
  GlobeRenderStats stats = GlobeRenderStats.empty;

  Timer? _scenarioTimer;
  DateTime? _scenarioStartedAt;

  GlobeTextureBundle get activeTextureBundle =>
      _runtimeTextureBundle ?? fixture.textureBundle;

  List<GlobeCountryLookupEntry> get activeCountryEntries {
    if (_runtimeCountriesByIndex.isNotEmpty) {
      return _runtimeCountriesByIndex.values.toList(growable: false);
    }
    return fixture.countries
        .map(
          (country) => GlobeCountryLookupEntry(
            index: country.index,
            code: country.code,
            isoA3: country.code,
            name: country.name,
            centerLat: country.centerLat,
            centerLon: country.centerLon,
            bbox: [
              country.lonMin,
              country.latMin,
              country.lonMax,
              country.latMax,
            ],
          ),
        )
        .toList(growable: false);
  }

  String get demoCountryCode {
    for (final preferred in const ['KR', 'FR', 'US', 'BR']) {
      final found = activeCountryEntries.where((item) => item.code == preferred);
      if (found.isNotEmpty) {
        return found.first.code;
      }
    }
    return activeCountryEntries.first.code;
  }

  void applyRuntimeGlobeAssets({
    required GlobeTextureBundle textureBundle,
    required List<GlobeCountryLookupEntry> countries,
  }) {
    _runtimeTextureBundle = textureBundle;
    _runtimeCountriesByIndex
      ..clear()
      ..addEntries(countries.map((country) => MapEntry(country.index, country)));
    notifyListeners();
  }

  void resetView() {
    _cameraPose = const GlobeCameraPose(
      yaw: 0.5,
      pitch: 0.45,
      radius: 3.1,
      fieldOfView: 38,
    );
    selectedCountryCode = null;
    selectedCityId = null;
    selectedCountryIndex = null;
    playhead = 0;
    activeScenario = null;
    playing = false;
    _scenarioTimer?.cancel();
    notifyListeners();
  }

  void orbit(Offset delta) {
    cancelFocus();
    _cameraPose = GlobeMath.clampPose(
      _cameraPose.copyWith(
        yaw: _cameraPose.yaw - delta.dx * 0.005,
        pitch: _cameraPose.pitch - delta.dy * 0.005,
      ),
    );
    notifyListeners();
  }

  void zoom(double scaleDelta) {
    final next = _cameraPose.radius / scaleDelta.clamp(0.85, 1.15);
    _cameraPose = GlobeMath.clampPose(_cameraPose.copyWith(radius: next));
    notifyListeners();
  }

  void tapViewport({required Offset point, required Size viewport}) {
    final countryIndex = GlobeMath.lookupCountryIndexFromScreen(
      textureBundle: activeTextureBundle,
      screenPoint: point,
      viewport: viewport,
      pose: _cameraPose,
    );
    if (countryIndex == null) {
      return;
    }
    selectedCountryIndex = countryIndex;
    final runtimeCountry = _runtimeCountriesByIndex[countryIndex];
    if (runtimeCountry != null) {
      selectedCountryCode = runtimeCountry.code;
    } else {
      final country = fixture.countries.firstWhere(
        (item) => item.index == countryIndex,
        orElse: () => fixture.countries.first,
      );
      selectedCountryCode = country.code;
    }
    selectedCityId = _nearestCity(point: point, viewport: viewport)?.id;
    notifyListeners();
  }

  void focusCountry(String countryCode) {
    final country = activeCountryEntries.firstWhere(
      (item) => item.code == countryCode,
      orElse: () => activeCountryEntries.first,
    );
    selectedCountryCode = country.code;
    selectedCountryIndex = country.index;
    _animateTo(
      _cameraPose.copyWith(
        yaw: GlobeMath.degToRad(country.centerLon),
        pitch: GlobeMath.degToRad(country.centerLat.clamp(-55, 55)),
        radius: 2.3,
      ),
    );
  }

  void focusCity(String cityId) {
    final city = fixture.cities.firstWhere((item) => item.id == cityId);
    _animateTo(
      _cameraPose.copyWith(
        yaw: GlobeMath.degToRad(city.longitude),
        pitch: GlobeMath.degToRad(city.latitude.clamp(-60, 60)),
        radius: 2.0,
      ),
    );
  }

  void runValidation(Size viewport) {
    validationReport = GlobeValidation.run(
      textureBundle: activeTextureBundle,
      countries: activeCountryEntries,
      cities: fixture.cities,
      pose: _cameraPose,
      viewport: viewport,
    );
    notifyListeners();
  }

  void recordFrame(double frameTimeMs) {
    if (frameTimeMs > 33) {
      _droppedFrames += 1;
    }
    _frameTimes.add(frameTimeMs);
    while (_frameTimes.length > 240) {
      _frameTimes.removeFirst();
    }
    final list = _frameTimes.toList()..sort();
    final average = _frameTimes.isEmpty
        ? 0.0
        : _frameTimes.reduce((a, b) => a + b) / _frameTimes.length;
    final p95Index = list.isEmpty
        ? 0
        : (list.length * 0.95).floor().clamp(0, list.length - 1);
    stats = GlobeRenderStats(
      frameCount: _frameTimes.length,
      averageFps: average == 0 ? 0 : 1000 / average,
      p95FrameTimeMs: list.isEmpty ? 0 : list[p95Index],
      worstFrameTimeMs: list.isEmpty ? 0 : list.last,
      lastFrameTimeMs: frameTimeMs,
      droppedFrameCount: _droppedFrames,
      memoryHint:
          '${fixture.cities.length} markers / ${fixture.routes.length} routes',
      currentMemoryBytes: _currentMemoryBytes,
      peakMemoryBytes: _peakMemoryBytes,
    );
    notifyListeners();
  }

  void recordMemorySample(int? bytes) {
    if (bytes == null) {
      return;
    }
    _currentMemoryBytes = bytes;
    final peak = _peakMemoryBytes ?? 0;
    if (bytes > peak) {
      _peakMemoryBytes = bytes;
    }
    stats = GlobeRenderStats(
      frameCount: stats.frameCount,
      averageFps: stats.averageFps,
      p95FrameTimeMs: stats.p95FrameTimeMs,
      worstFrameTimeMs: stats.worstFrameTimeMs,
      lastFrameTimeMs: stats.lastFrameTimeMs,
      droppedFrameCount: stats.droppedFrameCount,
      memoryHint: stats.memoryHint,
      currentMemoryBytes: _currentMemoryBytes,
      peakMemoryBytes: _peakMemoryBytes,
    );
    notifyListeners();
  }

  Map<String, Object?> benchmarkSnapshot({
    required String candidate,
    required BenchmarkScenario scenario,
  }) {
    return {
      'candidate': candidate,
      'scenario': scenario.name,
      'avgFps': double.parse(stats.averageFps.toStringAsFixed(2)),
      'p95FrameTimeMs': double.parse(stats.p95FrameTimeMs.toStringAsFixed(2)),
      'worstFrameTimeMs': double.parse(
        stats.worstFrameTimeMs.toStringAsFixed(2),
      ),
      'currentMemoryBytes': stats.currentMemoryBytes,
      'peakMemoryBytes': stats.peakMemoryBytes,
      'droppedFrames': stats.droppedFrameCount,
      'frameCount': stats.frameCount,
    };
  }

  void runScenario(BenchmarkScenario scenario) {
    _scenarioTimer?.cancel();
    _scenarioStartedAt = DateTime.now();
    activeScenario = scenario;
    playing = scenario == BenchmarkScenario.playback;
    _scenarioTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      final elapsed =
          DateTime.now().difference(_scenarioStartedAt!).inMilliseconds / 1000;
      switch (scenario) {
        case BenchmarkScenario.idle:
          _cameraPose = GlobeMath.clampPose(
            _cameraPose.copyWith(yaw: _cameraPose.yaw + 0.01),
          );
        case BenchmarkScenario.interaction:
          _cameraPose = GlobeMath.clampPose(
            _cameraPose.copyWith(
              yaw: _cameraPose.yaw + 0.015,
              pitch: 0.35 + math.sin(elapsed) * 0.22,
              radius: 2.6 + math.sin(elapsed * 0.8) * 0.35,
            ),
          );
        case BenchmarkScenario.density:
          _cameraPose = GlobeMath.clampPose(
            _cameraPose.copyWith(
              yaw: _cameraPose.yaw + 0.02,
              pitch: 0.5 + math.cos(elapsed * 0.6) * 0.18,
              radius: 2.2,
            ),
          );
        case BenchmarkScenario.playback:
          playhead = (elapsed / 90).clamp(0, 1);
          _cameraPose = GlobeMath.clampPose(
            _cameraPose.copyWith(
              yaw: _cameraPose.yaw + 0.01,
              pitch: 0.25 + math.sin(elapsed * 0.7) * 0.12,
              radius: 2.7,
            ),
          );
        case BenchmarkScenario.soak:
          _cameraPose = GlobeMath.clampPose(
            _cameraPose.copyWith(yaw: _cameraPose.yaw + 0.008),
          );
      }
      notifyListeners();
    });
    notifyListeners();
  }

  void cancelFocus() {
    // Placeholder hook for adapter-driven focus cancellation.
  }

  void _animateTo(GlobeCameraPose target) {
    _scenarioTimer?.cancel();
    final start = _cameraPose;
    final startedAt = DateTime.now();
    _scenarioTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      final t = DateTime.now().difference(startedAt).inMilliseconds / 700;
      final eased = Curves.easeInOutCubic.transform(t.clamp(0, 1));
      _cameraPose = GlobeMath.clampPose(
        GlobeCameraPose(
          yaw: _lerpAngle(start.yaw, target.yaw, eased),
          pitch: start.pitch + (target.pitch - start.pitch) * eased,
          radius: start.radius + (target.radius - start.radius) * eased,
          fieldOfView: start.fieldOfView,
        ),
      );
      notifyListeners();
      if (t >= 1) {
        timer.cancel();
      }
    });
  }

  CityVisit? _nearestCity({required Offset point, required Size viewport}) {
    CityVisit? nearest;
    double nearestDistance = 18;
    for (final city in fixture.cities) {
      final world = GlobeMath.latLonToVector3(
        latitude: city.latitude,
        longitude: city.longitude,
        radius: 1.02,
      );
      if (!GlobeMath.isSurfacePointVisible(world: world, pose: _cameraPose)) {
        continue;
      }
      final projected = GlobeMath.projectToScreen(
        world: world,
        viewport: viewport,
        pose: _cameraPose,
      );
      if (projected == null) {
        continue;
      }
      final distance = (projected - point).distance;
      if (distance < nearestDistance) {
        nearest = city;
        nearestDistance = distance;
      }
    }
    return nearest;
  }

  double _lerpAngle(double a, double b, double t) {
    var delta = b - a;
    while (delta > math.pi) {
      delta -= 2 * math.pi;
    }
    while (delta < -math.pi) {
      delta += 2 * math.pi;
    }
    return a + delta * t;
  }

  @override
  void dispose() {
    _scenarioTimer?.cancel();
    super.dispose();
  }
}
