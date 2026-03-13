import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vmath;

enum GlobeCandidateKind { candidateA, candidateB, candidateC }

enum BenchmarkScenario { idle, interaction, density, playback, soak }

class GlobeCountry {
  const GlobeCountry({
    required this.index,
    required this.code,
    required this.name,
    required this.continent,
    required this.latMin,
    required this.latMax,
    required this.lonMin,
    required this.lonMax,
    required this.displayColor,
  });

  final int index;
  final String code;
  final String name;
  final String continent;
  final double latMin;
  final double latMax;
  final double lonMin;
  final double lonMax;
  final Color displayColor;

  bool contains(double lat, double lon) {
    return lat >= latMin && lat < latMax && lon >= lonMin && lon < lonMax;
  }

  double get centerLat => (latMin + latMax) / 2;
  double get centerLon => (lonMin + lonMax) / 2;
}

class CityVisit {
  const CityVisit({
    required this.id,
    required this.tripId,
    required this.countryCode,
    required this.cityName,
    required this.latitude,
    required this.longitude,
    required this.visitDate,
    required this.markerColor,
  });

  final String id;
  final String tripId;
  final String countryCode;
  final String cityName;
  final double latitude;
  final double longitude;
  final DateTime visitDate;
  final Color markerColor;
}

class TravelRoute {
  const TravelRoute({
    required this.id,
    required this.tripId,
    required this.originCityId,
    required this.destinationCityId,
    required this.travelDate,
    required this.transportType,
    required this.points,
  });

  final String id;
  final String tripId;
  final String originCityId;
  final String destinationCityId;
  final DateTime travelDate;
  final String transportType;
  final List<vmath.Vector3> points;
}

class TravelTimelineEvent {
  const TravelTimelineEvent({
    required this.id,
    required this.tripId,
    required this.cityId,
    required this.occurredAt,
    required this.label,
  });

  final String id;
  final String tripId;
  final String cityId;
  final DateTime occurredAt;
  final String label;
}

class GlobeTextureBundle {
  const GlobeTextureBundle({
    required this.width,
    required this.height,
    required this.earthRgba,
    required this.countryIdRgba,
  });

  final int width;
  final int height;
  final Uint8List earthRgba;
  final Uint8List countryIdRgba;
}

class GlobeCountryLookupEntry {
  const GlobeCountryLookupEntry({
    required this.index,
    required this.code,
    required this.isoA3,
    required this.name,
    required this.centerLat,
    required this.centerLon,
    required this.bbox,
  });

  final int index;
  final String code;
  final String isoA3;
  final String name;
  final double centerLat;
  final double centerLon;
  final List<double> bbox;
}

class GlobeFixture {
  const GlobeFixture({
    required this.seed,
    required this.countries,
    required this.cities,
    required this.routes,
    required this.timelineEvents,
    required this.textureBundle,
  });

  final int seed;
  final List<GlobeCountry> countries;
  final List<CityVisit> cities;
  final List<TravelRoute> routes;
  final List<TravelTimelineEvent> timelineEvents;
  final GlobeTextureBundle textureBundle;
}

class GlobeCameraPose {
  const GlobeCameraPose({
    required this.yaw,
    required this.pitch,
    required this.radius,
    required this.fieldOfView,
  });

  final double yaw;
  final double pitch;
  final double radius;
  final double fieldOfView;

  GlobeCameraPose copyWith({
    double? yaw,
    double? pitch,
    double? radius,
    double? fieldOfView,
  }) {
    return GlobeCameraPose(
      yaw: yaw ?? this.yaw,
      pitch: pitch ?? this.pitch,
      radius: radius ?? this.radius,
      fieldOfView: fieldOfView ?? this.fieldOfView,
    );
  }
}

class GlobeRenderStats {
  const GlobeRenderStats({
    required this.frameCount,
    required this.averageFps,
    required this.p95FrameTimeMs,
    required this.worstFrameTimeMs,
    required this.lastFrameTimeMs,
    required this.droppedFrameCount,
    required this.memoryHint,
    required this.currentMemoryBytes,
    required this.peakMemoryBytes,
  });

  final int frameCount;
  final double averageFps;
  final double p95FrameTimeMs;
  final double worstFrameTimeMs;
  final double lastFrameTimeMs;
  final int droppedFrameCount;
  final String memoryHint;
  final int? currentMemoryBytes;
  final int? peakMemoryBytes;

  String get memoryLabel {
    if (peakMemoryBytes != null) {
      return 'heap ${_formatBytes(peakMemoryBytes!)}';
    }
    return memoryHint;
  }

  static String _formatBytes(int bytes) {
    const units = ['B', 'KB', 'MB', 'GB'];
    double value = bytes.toDouble();
    int unitIndex = 0;
    while (value >= 1024 && unitIndex < units.length - 1) {
      value /= 1024;
      unitIndex += 1;
    }
    return '${value.toStringAsFixed(unitIndex == 0 ? 0 : 1)} ${units[unitIndex]}';
  }

  static const empty = GlobeRenderStats(
    frameCount: 0,
    averageFps: 0,
    p95FrameTimeMs: 0,
    worstFrameTimeMs: 0,
    lastFrameTimeMs: 0,
    droppedFrameCount: 0,
    memoryHint: 'n/a',
    currentMemoryBytes: null,
    peakMemoryBytes: null,
  );
}

class GlobeValidationMetric {
  const GlobeValidationMetric({
    required this.label,
    required this.value,
    required this.threshold,
    required this.passed,
  });

  final String label;
  final String value;
  final String threshold;
  final bool passed;
}

class GlobeValidationReport {
  const GlobeValidationReport({
    required this.generatedAt,
    required this.metrics,
    required this.notes,
  });

  final DateTime generatedAt;
  final List<GlobeValidationMetric> metrics;
  final List<String> notes;

  bool get passed => metrics.every((metric) => metric.passed);

  static GlobeValidationReport pending() {
    return GlobeValidationReport(
      generatedAt: DateTime.now(),
      metrics: const [],
      notes: const ['Validation has not been executed yet.'],
    );
  }
}

class GlobeBenchmarkConfig {
  const GlobeBenchmarkConfig({
    required this.scenario,
    required this.durationMs,
  });

  final BenchmarkScenario? scenario;
  final int durationMs;

  bool get enabled => scenario != null;

  static GlobeBenchmarkConfig fromEnvironment() {
    const scenarioName = String.fromEnvironment('POC_AUTORUN_SCENARIO');
    const durationMs = int.fromEnvironment(
      'POC_AUTORUN_DURATION_MS',
      defaultValue: 5000,
    );
    return GlobeBenchmarkConfig(
      scenario: _parseScenario(scenarioName),
      durationMs: durationMs,
    );
  }

  static BenchmarkScenario? _parseScenario(String value) {
    for (final scenario in BenchmarkScenario.values) {
      if (scenario.name == value) {
        return scenario;
      }
    }
    return null;
  }
}

class GlobeProbeResult {
  const GlobeProbeResult({
    required this.ready,
    required this.summary,
    required this.blockingIssues,
  });

  final bool ready;
  final String summary;
  final List<String> blockingIssues;

  static const unknown = GlobeProbeResult(
    ready: false,
    summary: 'Probe has not completed yet.',
    blockingIssues: [],
  );
}
