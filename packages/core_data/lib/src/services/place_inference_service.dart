import 'dart:math' as math;

import 'package:core_domain/core_domain.dart';

class PlaceInferenceService {
  const PlaceInferenceService();

  PlaceSuggestion infer({
    required ExtractedPhotoMetadata metadata,
    required List<TripSummary> trips,
    String? tripId,
  }) {
    final places = [for (final trip in trips) trip.heroPlace];
    final tripContext = tripId == null
        ? null
        : trips.firstWhereOrNull((trip) => trip.id == tripId);

    if (metadata.latitude != null && metadata.longitude != null) {
      PlaceRef? best;
      double bestDistance = double.infinity;
      for (final place in places) {
        if (place.latitude == null || place.longitude == null) continue;
        final distance = _distanceKm(
          metadata.latitude!,
          metadata.longitude!,
          place.latitude!,
          place.longitude!,
        );
        if (distance < bestDistance) {
          bestDistance = distance;
          best = place;
        }
      }
      if (best != null) {
        final confidence = bestDistance < 30
            ? 0.96
            : bestDistance < 120
            ? 0.81
            : 0.62;
        return PlaceSuggestion(
          place: best,
          confidence: confidence,
          reason: 'Matched from embedded location metadata',
        );
      }
    }

    final fallback = tripContext?.heroPlace ?? trips.first.heroPlace;
    return PlaceSuggestion(
      place: fallback,
      confidence: 0.42,
      reason: tripContext == null
          ? 'Using your most recent trip context'
          : 'Using the selected trip context',
    );
  }
}

double _distanceKm(double lat1, double lon1, double lat2, double lon2) {
  const earthRadiusKm = 6371.0;
  final dLat = _degToRad(lat2 - lat1);
  final dLon = _degToRad(lon2 - lon1);
  final a =
      math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_degToRad(lat1)) *
          math.cos(_degToRad(lat2)) *
          math.sin(dLon / 2) *
          math.sin(dLon / 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return earthRadiusKm * c;
}

double _degToRad(double degrees) => degrees * math.pi / 180;

extension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T value) test) {
    for (final value in this) {
      if (test(value)) return value;
    }
    return null;
  }
}
