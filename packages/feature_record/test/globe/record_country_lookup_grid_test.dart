import 'dart:typed_data';

import 'package:feature_record/src/globe_engine/picking/record_country_lookup_grid.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

void main() {
  group('RecordCountryLookupGrid', () {
    test('samples a country code from UV space with neighborhood voting', () {
      final grid = RecordCountryLookupGrid(
        width: 4,
        height: 2,
        indices: Uint8List.fromList([
          0,
          1,
          1,
          0,
          0,
          1,
          0,
          0,
        ]),
        countryCodes: const ['', 'FR'],
      );

      expect(grid.countryCodeForUv(0.35, 0.25), 'FR');
      expect(
        grid.countryCodeForUv(0.95, 0.75, neighborhoodRadius: 0),
        isNull,
      );
    });

    test('converts local sphere points into equirectangular UV coordinates',
        () {
      final uvAtPrimeMeridian =
          RecordCountrySurfacePicker.uvForLocalPoint(vm.Vector3(0, 0, 1));
      final uvAtEast =
          RecordCountrySurfacePicker.uvForLocalPoint(vm.Vector3(1, 0, 0));
      final uvAtNorthPole =
          RecordCountrySurfacePicker.uvForLocalPoint(vm.Vector3(0, 1, 0));

      expect(uvAtPrimeMeridian.x, closeTo(0.5, 0.0001));
      expect(uvAtPrimeMeridian.y, closeTo(0.5, 0.0001));
      expect(uvAtEast.x, closeTo(0.75, 0.0001));
      expect(uvAtNorthPole.y, closeTo(0.0, 0.0001));
    });
  });
}
