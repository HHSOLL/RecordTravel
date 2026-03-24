import 'dart:convert';
import 'dart:io';

import 'package:feature_record/src/globe_engine/picking/record_country_lookup_grid.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('country lookup asset resolves broad country interiors and ocean gaps', () async {
    final lookupGrid = await _loadLookupGrid();

    for (final sample in const <({double lat, double lon, String code})>[
      (lat: 46.2, lon: 2.0, code: 'FR'),
      (lat: 45.5, lon: 5.0, code: 'FR'),
      (lat: -25.0, lon: 133.0, code: 'AU'),
      (lat: -31.0, lon: 146.0, code: 'AU'),
      (lat: 36.0, lon: 138.0, code: 'JP'),
      (lat: 38.0, lon: 140.0, code: 'JP'),
    ]) {
      expect(
        lookupGrid.countryCodeForUv(
          _uForLongitude(sample.lon),
          _vForLatitude(sample.lat),
        ),
        sample.code,
      );
    }

    expect(
      lookupGrid.countryCodeForUv(
        _uForLongitude(-140.0),
        _vForLatitude(0.0),
        neighborhoodRadius: 0,
      ),
      isNull,
    );
  });
}

Future<RecordCountryLookupGrid> _loadLookupGrid() async {
  final repoRoot = Directory.current.parent.parent.path;
  final paletteFile = File(
    '$repoRoot/apps/mobile_app/assets/globe/country_lookup_v1_palette.json',
  );
  final gridFile = File(
    '$repoRoot/apps/mobile_app/assets/globe/country_lookup_v1.bin',
  );
  final paletteJson =
      json.decode(await paletteFile.readAsString()) as Map<String, dynamic>;
  return RecordCountryLookupGrid(
    width: paletteJson['width'] as int,
    height: paletteJson['height'] as int,
    indices: await gridFile.readAsBytes(),
    countryCodes: List<String>.from(paletteJson['countryCodes'] as List),
  );
}

double _uForLongitude(double longitude) {
  final normalized = (longitude + 180.0) / 360.0;
  return normalized - normalized.floorToDouble();
}

double _vForLatitude(double latitude) => (90.0 - latitude) / 180.0;
