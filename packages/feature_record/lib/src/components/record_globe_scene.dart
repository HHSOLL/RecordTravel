import 'package:flutter/material.dart';

@immutable
class RecordGlobeScene {
  const RecordGlobeScene({
    required this.style,
    required this.initialCountryCode,
    required this.anchors,
    required this.arcs,
    required this.selectableCountryCodes,
  });

  final RecordGlobeStyle style;
  final String? initialCountryCode;
  final List<RecordGlobeAnchor> anchors;
  final List<RecordGlobeArc> arcs;
  final Set<String> selectableCountryCodes;

  RecordGlobeAnchor? anchorForCountry(String countryCode) {
    for (final anchor in anchors) {
      if (anchor.countryCode == countryCode) return anchor;
    }
    return null;
  }
}

enum RecordGlobeStyle {
  storybookLight,
  orbitNight,
}

@immutable
class RecordGlobeAnchor {
  const RecordGlobeAnchor({
    required this.countryCode,
    required this.countryName,
    required this.latitude,
    required this.longitude,
    required this.markerCount,
    required this.emphasis,
    required this.color,
    required this.isUpcoming,
  });

  final String countryCode;
  final String countryName;
  final double latitude;
  final double longitude;
  final int markerCount;
  final double emphasis;
  final Color color;
  final bool isUpcoming;
}

@immutable
class RecordGlobeArc {
  const RecordGlobeArc({
    required this.id,
    required this.fromCountryCode,
    required this.toCountryCode,
    required this.fromLatitude,
    required this.fromLongitude,
    required this.toLatitude,
    required this.toLongitude,
    required this.color,
    required this.weight,
    required this.isUpcoming,
  });

  final String id;
  final String fromCountryCode;
  final String toCountryCode;
  final double fromLatitude;
  final double fromLongitude;
  final double toLatitude;
  final double toLongitude;
  final Color color;
  final double weight;
  final bool isUpcoming;
}
