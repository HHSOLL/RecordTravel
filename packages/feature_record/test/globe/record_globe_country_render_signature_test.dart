import 'package:feature_record/src/globe/domain/entities/record_globe_country.dart';
import 'package:feature_record/src/globe_engine/renderers/record_globe_country_render_signature.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('hasSameCountryRenderState', () {
    test('returns true when render-affecting fields are unchanged', () {
      const countries = [
        RecordGlobeCountry(
          code: 'FR',
          name: 'France',
          anchorLatitude: 46.22,
          anchorLongitude: 2.21,
          continent: 'Europe',
          visitCount: 2,
          activityLevel: 2,
          signal: RecordGlobeCountrySignal.visited,
          hasRecentVisit: true,
          hasUpcomingTrip: false,
        ),
      ];

      expect(hasSameCountryRenderState(countries, countries), isTrue);
    });

    test('returns false when render-affecting fields change', () {
      const previous = [
        RecordGlobeCountry(
          code: 'FR',
          name: 'France',
          anchorLatitude: 46.22,
          anchorLongitude: 2.21,
          continent: 'Europe',
          visitCount: 2,
          activityLevel: 1,
          signal: RecordGlobeCountrySignal.visited,
          hasRecentVisit: false,
          hasUpcomingTrip: false,
        ),
      ];
      const next = [
        RecordGlobeCountry(
          code: 'FR',
          name: 'France',
          anchorLatitude: 46.22,
          anchorLongitude: 2.21,
          continent: 'Europe',
          visitCount: 2,
          activityLevel: 3,
          signal: RecordGlobeCountrySignal.planned,
          hasRecentVisit: true,
          hasUpcomingTrip: true,
        ),
      ];

      expect(hasSameCountryRenderState(previous, next), isFalse);
    });
  });
}
