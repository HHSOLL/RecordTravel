import 'dart:typed_data';

import 'package:feature_record/src/globe/domain/entities/record_globe_country.dart';
import 'package:feature_record/src/globe/presentation/widgets/record_globe_highlight_texture.dart';
import 'package:feature_record/src/globe_engine/picking/record_country_lookup_grid.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('buildPixels brightens visited and planned countries only', () {
    final lookupGrid = RecordCountryLookupGrid(
      width: 4,
      height: 1,
      indices: Uint8List.fromList([0, 1, 2, 3]),
      countryCodes: const ['', 'KR', 'JP', 'US'],
    );
    final countries = const [
      RecordGlobeCountry(
        code: 'KR',
        name: 'South Korea',
        anchorLatitude: 36,
        anchorLongitude: 128,
        continent: 'Asia',
        activityLevel: 3,
        signal: RecordGlobeCountrySignal.visited,
        hasRecentVisit: true,
      ),
      RecordGlobeCountry(
        code: 'JP',
        name: 'Japan',
        anchorLatitude: 36,
        anchorLongitude: 138,
        continent: 'Asia',
        signal: RecordGlobeCountrySignal.planned,
        hasUpcomingTrip: true,
      ),
      RecordGlobeCountry(
        code: 'US',
        name: 'United States',
        anchorLatitude: 39,
        anchorLongitude: -98,
        continent: 'North America',
        signal: RecordGlobeCountrySignal.neutral,
      ),
    ];

    final pixels = RecordGlobeHighlightTextureBuilder.buildPixels(
      lookupGrid,
      countries,
    );

    expect(pixels.length, lookupGrid.width * lookupGrid.height * 4);
    expect(_alphaAt(pixels, 1), greaterThan(0));
    expect(_alphaAt(pixels, 2), greaterThan(0));
    expect(_alphaAt(pixels, 3), 0);
    expect(_alphaAt(pixels, 1), greaterThan(_alphaAt(pixels, 2)));
    expect(_blueAt(pixels, 2), greaterThan(_redAt(pixels, 2)));
  });
}

int _alphaAt(Uint8List pixels, int texelIndex) => pixels[(texelIndex * 4) + 3];

int _redAt(Uint8List pixels, int texelIndex) => pixels[texelIndex * 4];

int _blueAt(Uint8List pixels, int texelIndex) => pixels[(texelIndex * 4) + 2];
