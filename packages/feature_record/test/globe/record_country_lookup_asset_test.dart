import 'dart:convert';
import 'dart:io';

import 'package:feature_record/src/globe_engine/picking/record_country_lookup_grid.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('country lookup assets stay structurally aligned with palette metadata',
      () async {
    final lookupGrid = await _loadLookupGrid();

    expect(lookupGrid.indices.length, lookupGrid.width * lookupGrid.height);
    expect(lookupGrid.countryCodes, isNotEmpty);

    final maxIndex = lookupGrid.indices.reduce((left, right) {
      return left > right ? left : right;
    });
    expect(maxIndex, lessThan(lookupGrid.countryCodes.length));
  });

  test(
    'country lookup asset resolves interior samples, seam-adjacent countries, and ocean gaps',
    () async {
      final lookupGrid = await _loadLookupGrid();

      for (final sample in const <({double lat, double lon, String code})>[
        (lat: 46.2, lon: 2.0, code: 'FR'),
        (lat: -25.0, lon: 133.0, code: 'AU'),
        (lat: 36.0, lon: 138.0, code: 'JP'),
        (lat: 54.0, lon: -2.0, code: 'GB'),
        (lat: -41.0, lon: 174.0, code: 'NZ'),
        (lat: 36.5, lon: 127.8, code: 'KR'),
        (lat: 39.0, lon: -98.0, code: 'US'),
        (lat: -10.0, lon: -55.0, code: 'BR'),
        (lat: -29.0, lon: 24.0, code: 'ZA'),
        (lat: -17.7, lon: 178.1, code: 'FJ'),
        (lat: 67.0, lon: 179.0, code: 'RU'),
        (lat: 67.0, lon: -179.0, code: 'RU'),
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
      expect(
        lookupGrid.countryCodeForUv(
          _uForLongitude(179.8),
          _vForLatitude(0.0),
          neighborhoodRadius: 0,
        ),
        isNull,
      );
      expect(
        lookupGrid.countryCodeForUv(
          _uForLongitude(-180.2),
          _vForLatitude(0.0),
          neighborhoodRadius: 0,
        ),
        isNull,
      );
    },
  );

  test('country lookup wraps longitudinal UVs consistently across the seam',
      () async {
    final lookupGrid = await _loadLookupGrid();
    final franceV = _vForLatitude(46.2);

    expect(
      lookupGrid.countryCodeForUv(_uForLongitude(2.0), franceV),
      lookupGrid.countryCodeForUv(_uForLongitude(362.0), franceV),
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
