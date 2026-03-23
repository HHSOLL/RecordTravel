import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

@immutable
class RecordGeoPoint {
  const RecordGeoPoint({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
}

@immutable
class RecordCountryGeometry {
  const RecordCountryGeometry({
    required this.code,
    required this.name,
    required this.centroidLat,
    required this.centroidLng,
    required this.minLat,
    required this.maxLat,
    required this.minLng,
    required this.maxLng,
    required this.polygons,
  });

  final String code;
  final String name;
  final double centroidLat;
  final double centroidLng;
  final double minLat;
  final double maxLat;
  final double minLng;
  final double maxLng;
  final List<List<RecordGeoPoint>> polygons;
}

class RecordCountryGeometryBundle {
  RecordCountryGeometryBundle._(this.countries)
      : byCode = {
          for (final country in countries) country.code: country,
        };

  final List<RecordCountryGeometry> countries;
  final Map<String, RecordCountryGeometry> byCode;

  static Future<RecordCountryGeometryBundle>? _cache;

  static Future<RecordCountryGeometryBundle> load() {
    return _cache ??= _load();
  }

  static Future<RecordCountryGeometryBundle> _load() async {
    final raw = await rootBundle.loadString(
      'assets/globe/record_country_shapes.json',
    );
    final decoded = json.decode(raw) as Map<String, dynamic>;
    final countries = (decoded['countries'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(_countryFromJson)
        .toList(growable: false);
    return RecordCountryGeometryBundle._(countries);
  }

  static RecordCountryGeometry _countryFromJson(Map<String, dynamic> json) {
    return RecordCountryGeometry(
      code: json['code'] as String,
      name: json['name'] as String,
      centroidLat: (json['centroidLat'] as num).toDouble(),
      centroidLng: (json['centroidLng'] as num).toDouble(),
      minLat: (json['minLat'] as num).toDouble(),
      maxLat: (json['maxLat'] as num).toDouble(),
      minLng: (json['minLng'] as num).toDouble(),
      maxLng: (json['maxLng'] as num).toDouble(),
      polygons: (json['polygons'] as List<dynamic>)
          .cast<List<dynamic>>()
          .map(
            (ring) => ring
                .cast<List<dynamic>>()
                .map(
                  (point) => RecordGeoPoint(
                    latitude: (point[0] as num).toDouble(),
                    longitude: (point[1] as num).toDouble(),
                  ),
                )
                .toList(growable: false),
          )
          .toList(growable: false),
    );
  }
}
