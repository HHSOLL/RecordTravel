import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../controller/globe_poc_controller.dart';
import '../math/globe_math.dart';
import '../models/globe_models.dart';

class GlobeValidation {
  static GlobeValidationReport run({
    required GlobeTextureBundle textureBundle,
    required List<GlobeCountryLookupEntry> countries,
    required List<CityVisit> cities,
    required GlobeCameraPose pose,
    required Size viewport,
  }) {
    final countryMetrics = _countryLookupMetric(
      countries,
      textureBundle,
      pose,
      viewport,
    );
    final markerMetrics = _markerMetric(cities, pose, viewport);
    return GlobeValidationReport(
      generatedAt: DateTime.now(),
      metrics: [countryMetrics, markerMetrics[0], markerMetrics[1]],
      notes: const [
        'Validation is based on shared projection math and deterministic fixture data.',
        'Automated correctness is currently limited to country lookup and marker hit-testing.',
      ],
    );
  }

  static GlobeValidationMetric _countryLookupMetric(
    List<GlobeCountryLookupEntry> countries,
    GlobeTextureBundle textureBundle,
    GlobeCameraPose pose,
    Size viewport,
  ) {
    int total = 0;
    int correct = 0;
    for (final country in countries) {
      final world = GlobeMath.latLonToVector3(
        latitude: country.centerLat,
        longitude: country.centerLon,
      );
      if (!GlobeMath.isSurfacePointVisible(world: world, pose: pose)) {
        continue;
      }
      final screen = GlobeMath.projectToScreen(
        world: world,
        viewport: viewport,
        pose: pose,
      );
      if (screen == null) {
        continue;
      }
      total += 1;
      final hit = GlobeMath.lookupCountryIndexFromScreen(
        textureBundle: textureBundle,
        screenPoint: screen,
        viewport: viewport,
        pose: pose,
      );
      if (hit == null) {
        continue;
      }
      if (hit == country.index) {
        correct += 1;
      }
    }
    final accuracy = total == 0 ? 0 : correct / total;
    return GlobeValidationMetric(
      label: 'country ID lookup accuracy',
      value: '${(accuracy * 100).toStringAsFixed(1)}%',
      threshold: '>= 99%',
      passed: accuracy >= 0.99,
    );
  }

  static List<GlobeValidationMetric> _markerMetric(
    List<CityVisit> cities,
    GlobeCameraPose pose,
    Size viewport,
  ) {
    final visibleCities = cities
        .take(300)
        .map((city) {
          final world = GlobeMath.latLonToVector3(
            latitude: city.latitude,
            longitude: city.longitude,
            radius: 1.02,
          );
          if (!GlobeMath.isSurfacePointVisible(world: world, pose: pose)) {
            return null;
          }
          final screen = GlobeMath.projectToScreen(
            world: world,
            viewport: viewport,
            pose: pose,
          );
          if (screen == null) {
            return null;
          }
          return _ProjectedCity(city: city, screen: screen);
        })
        .whereType<_ProjectedCity>()
        .toList();

    int rawHit = 0;
    for (final projected in visibleCities) {
      final hit = _nearestProjectedCity(
        candidates: visibleCities,
        point: projected.screen,
      );
      if (hit?.city.id == projected.city.id) {
        rawHit += 1;
      }
    }
    final rawAccuracy = visibleCities.isEmpty
        ? 0
        : rawHit / visibleCities.length;

    final clusters = <String, List<_ProjectedCity>>{};
    for (final projected in visibleCities) {
      final key =
          '${(projected.screen.dx / 72).floor()}:${(projected.screen.dy / 72).floor()}';
      clusters.putIfAbsent(key, () => <_ProjectedCity>[]).add(projected);
    }

    int clusterHit = 0;
    for (final entry in clusters.entries) {
      final centroid =
          entry.value.map((item) => item.screen).reduce((a, b) => a + b) /
          entry.value.length.toDouble();
      final hit = _nearestCluster(clusters: clusters, point: centroid);
      if (hit == entry.key) {
        clusterHit += 1;
      }
    }
    final clusterAccuracy = clusters.isEmpty ? 0 : clusterHit / clusters.length;
    return [
      GlobeValidationMetric(
        label: 'marker hit-test accuracy (raw)',
        value: '${(rawAccuracy * 100).toStringAsFixed(1)}%',
        threshold: '>= 99%',
        passed: rawAccuracy >= 0.99,
      ),
      GlobeValidationMetric(
        label: 'marker hit-test accuracy (cluster)',
        value: '${(clusterAccuracy * 100).toStringAsFixed(1)}%',
        threshold: '>= 97%',
        passed: clusterAccuracy >= 0.97,
      ),
    ];
  }

  static _ProjectedCity? _nearestProjectedCity({
    required List<_ProjectedCity> candidates,
    required Offset point,
  }) {
    _ProjectedCity? nearest;
    double nearestDistance = 18;
    for (final candidate in candidates) {
      final distance = (candidate.screen - point).distance;
      if (distance < nearestDistance) {
        nearest = candidate;
        nearestDistance = distance;
      }
    }
    return nearest;
  }

  static String? _nearestCluster({
    required Map<String, List<_ProjectedCity>> clusters,
    required Offset point,
  }) {
    String? nearestKey;
    double nearestDistance = 36;
    for (final entry in clusters.entries) {
      final centroid =
          entry.value.map((item) => item.screen).reduce((a, b) => a + b) /
          entry.value.length.toDouble();
      final distance = (centroid - point).distance;
      if (distance < nearestDistance) {
        nearestKey = entry.key;
        nearestDistance = distance;
      }
    }
    return nearestKey;
  }
}

class _ProjectedCity {
  const _ProjectedCity({required this.city, required this.screen});

  final CityVisit city;
  final Offset screen;
}
