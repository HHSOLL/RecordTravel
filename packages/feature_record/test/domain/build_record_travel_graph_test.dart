import 'package:core_domain/core_domain.dart';
import 'package:feature_record/src/domain/build_record_travel_graph.dart';
import 'package:feature_record/src/domain/record_travel_graph.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('buildRecordTravelGraph', () {
    test('builds unified visited and planned country projections', () {
      final now = DateTime(2026, 3, 24, 12);
      final trips = [
        TripSummary(
          id: 'trip-paris',
          title: 'Winter in France',
          subtitle: 'Paris and Lyon notes',
          startDate: DateTime(2026, 1, 10),
          endDate: DateTime(2026, 1, 14),
          heroPlace: const PlaceRef(
            countryCode: 'FR',
            countryName: 'France',
            cityName: 'Paris',
            latitude: 48.8566,
            longitude: 2.3522,
          ),
          coverHint: 'Seine at dusk',
          memoryCount: 2,
          photoCount: 1,
          countryCount: 1,
        ),
        TripSummary(
          id: 'trip-riviera',
          title: 'Spring Riviera',
          subtitle: 'Upcoming south coast plan',
          startDate: DateTime(2026, 4, 10),
          endDate: DateTime(2026, 4, 13),
          heroPlace: const PlaceRef(
            countryCode: 'FR',
            countryName: 'France',
            cityName: 'Nice',
            latitude: 43.7102,
            longitude: 7.2620,
          ),
          coverHint: 'Blue coast',
          memoryCount: 0,
          photoCount: 0,
          countryCount: 1,
        ),
        TripSummary(
          id: 'trip-sydney',
          title: 'Sydney Sketch',
          subtitle: 'Upcoming plan only',
          startDate: DateTime(2026, 5, 2),
          endDate: DateTime(2026, 5, 9),
          heroPlace: const PlaceRef(
            countryCode: 'AU',
            countryName: 'Australia',
            cityName: 'Sydney',
            latitude: -33.8688,
            longitude: 151.2093,
          ),
          coverHint: 'Opera house',
          memoryCount: 0,
          photoCount: 0,
          countryCount: 1,
        ),
      ];

      final entries = [
        JournalEntry(
          id: 'entry-paris',
          tripId: 'trip-paris',
          title: 'Morning by the Seine',
          body: 'Cold air, clean light, quiet river.',
          recordedAt: DateTime(2026, 1, 10, 9, 30),
          place: const PlaceRef(
            countryCode: 'FR',
            countryName: 'France',
            cityName: 'Paris',
            latitude: 48.8566,
            longitude: 2.3522,
          ),
          type: MemoryType.note,
          photoAssetIds: const [],
          hasPendingUpload: false,
        ),
        JournalEntry(
          id: 'entry-lyon',
          tripId: 'trip-paris',
          title: 'Dinner in Lyon',
          body: 'Warm lights and a crowded square.',
          recordedAt: DateTime(2026, 1, 11, 20, 15),
          place: const PlaceRef(
            countryCode: 'FR',
            countryName: 'France',
            cityName: 'Lyon',
            latitude: 45.7640,
            longitude: 4.8357,
          ),
          type: MemoryType.photo,
          photoAssetIds: const ['photo-lyon'],
          hasPendingUpload: false,
        ),
      ];

      final photos = [
        PhotoAsset(
          id: 'photo-lyon',
          fileName: 'lyon.jpg',
          previewLabel: 'Lyon Night',
          format: 'jpg',
          takenAt: DateTime(2026, 1, 11, 20, 12),
          place: const PlaceRef(
            countryCode: 'FR',
            countryName: 'France',
            cityName: 'Lyon',
            latitude: 45.7640,
            longitude: 4.8357,
          ),
          uploadState: UploadState.uploaded,
        ),
      ];

      final graph = buildRecordTravelGraph(
        trips: trips,
        entries: entries,
        photos: photos,
        now: now,
      );

      final france = graph.countriesByCode['FR'];
      final australia = graph.countriesByCode['AU'];

      expect(france, isNotNull);
      expect(france!.signal, RecordCountrySignal.visited);
      expect(france.tripCount, 2);
      expect(france.visitCount, 2);
      expect(france.plannedStopCount, 1);
      expect(france.cityCount, 3);
      expect(france.albumMoments, hasLength(1));
      expect(france.timelineDays, hasLength(2));
      expect(france.timelineDays.first.moments.first.title, 'Dinner in Lyon');
      expect(france.hasUpcomingTrip, isTrue);

      expect(australia, isNotNull);
      expect(australia!.signal, RecordCountrySignal.planned);
      expect(australia.visitCount, 0);
      expect(australia.plannedStopCount, 1);
      expect(australia.trips.single.isUpcoming, isTrue);

      final globeCountries = buildRecordGlobeCountries(graph);
      final plannedGlobeCountry = globeCountries.singleWhere(
        (country) => country.code == 'AU',
      );
      expect(plannedGlobeCountry.hasUpcomingTrip, isTrue);
    });
  });
}
