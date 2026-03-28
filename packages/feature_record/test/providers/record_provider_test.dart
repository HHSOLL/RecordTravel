import 'package:core_data/core_data.dart';
import 'package:core_domain/core_domain.dart';
import 'package:feature_record/feature_record.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' as legacy;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('record providers', () {
    test('globe assets stay style-specific and stable', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final lightAssets = container.read(
        recordGlobeAssetSetProvider(RecordGlobeStyle.light),
      );
      final darkAssets = container.read(
        recordGlobeAssetSetProvider(RecordGlobeStyle.dark),
      );

      expect(
        lightAssets.baseEarthTextureAsset,
        'assets/globe/earth_storybook_light.png',
      );
      expect(
        darkAssets.baseEarthTextureAsset,
        'assets/globe/earth_storybook_dark.png',
      );
      expect(
        lightAssets.borderOverlayTextureAsset,
        darkAssets.borderOverlayTextureAsset,
      );
      expect(
        lightAssets.countryLookupGridAsset,
        darkAssets.countryLookupGridAsset,
      );
      expect(
        lightAssets.countryLookupPaletteAsset,
        darkAssets.countryLookupPaletteAsset,
      );
    });

    test('globe scene updates immediately when an upcoming trip is added', () {
      final tripsState = legacy.StateProvider<List<TripSummary>>(
        (ref) => [
          TripSummary(
            id: 'trip-france-past',
            title: 'France Notes',
            subtitle: 'Recorded trip',
            startDate: DateTime(2025, 11, 10),
            endDate: DateTime(2025, 11, 15),
            heroPlace: const PlaceRef(
              countryCode: 'FR',
              countryName: 'France',
              cityName: 'Paris',
              latitude: 48.8566,
              longitude: 2.3522,
            ),
            coverHint: 'Paris lights',
            memoryCount: 1,
            photoCount: 0,
            countryCount: 1,
          ),
        ],
      );
      final entriesState = legacy.StateProvider<List<JournalEntry>>(
        (ref) => [
          JournalEntry(
            id: 'entry-france-past',
            tripId: 'trip-france-past',
            title: 'River walk',
            body: 'Cold air over the Seine.',
            recordedAt: DateTime(2025, 11, 11, 9, 0),
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
        ],
      );
      final photosState = legacy.StateProvider<List<PhotoAsset>>(
        (ref) => const [],
      );
      final container = ProviderContainer(
        overrides: [
          tripsProvider.overrideWith((ref) => ref.watch(tripsState)),
          entriesProvider.overrideWith((ref) => ref.watch(entriesState)),
          photosProvider.overrideWith((ref) => ref.watch(photosState)),
        ],
      );
      addTearDown(container.dispose);

      container.read(recordCurrentTimeProvider.notifier).state = DateTime(
        2026,
        3,
        25,
        12,
      );

      final initialScene = container.read(
        recordGlobeSceneSpecProvider(Brightness.light),
      );
      final initialFrance = initialScene.countries.singleWhere(
        (country) => country.code == 'FR',
      );

      expect(initialFrance.signal, RecordGlobeCountrySignal.visited);
      expect(initialFrance.hasUpcomingTrip, isFalse);
      expect(initialFrance.activityLevel, 1);

      container.read(tripsState.notifier).state = [
        ...container.read(tripsState),
        TripSummary(
          id: 'trip-france-upcoming',
          title: 'Nice Plan',
          subtitle: 'Upcoming coast route',
          startDate: DateTime(2026, 4, 20),
          endDate: DateTime(2026, 4, 24),
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
      ];

      final refreshedScene = container.read(
        recordGlobeSceneSpecProvider(Brightness.light),
      );
      final refreshedFrance = refreshedScene.countries.singleWhere(
        (country) => country.code == 'FR',
      );

      expect(refreshedFrance.signal, RecordGlobeCountrySignal.visited);
      expect(refreshedFrance.hasUpcomingTrip, isTrue);
      expect(
        refreshedFrance.activityScore,
        greaterThan(initialFrance.activityScore),
      );
      expect(
        refreshedFrance.activityLevel,
        greaterThan(initialFrance.activityLevel),
      );
    });

    test('country and globe projections refresh when the current time changes',
        () {
      final tripsState = legacy.StateProvider<List<TripSummary>>(
        (ref) => [
          TripSummary(
            id: 'trip-france-recorded',
            title: 'France Notes',
            subtitle: 'Recorded trip',
            startDate: DateTime(2026, 1, 15),
            endDate: DateTime(2026, 1, 20),
            heroPlace: const PlaceRef(
              countryCode: 'FR',
              countryName: 'France',
              cityName: 'Paris',
              latitude: 48.8566,
              longitude: 2.3522,
            ),
            coverHint: 'Paris lights',
            memoryCount: 1,
            photoCount: 0,
            countryCount: 1,
          ),
          TripSummary(
            id: 'trip-france-planned',
            title: 'Nice Plan',
            subtitle: 'Upcoming coast route',
            startDate: DateTime(2026, 4, 20),
            endDate: DateTime(2026, 4, 24),
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
        ],
      );
      final entriesState = legacy.StateProvider<List<JournalEntry>>(
        (ref) => [
          JournalEntry(
            id: 'entry-france-recorded',
            tripId: 'trip-france-recorded',
            title: 'Winter walk',
            body: 'Quiet morning.',
            recordedAt: DateTime(2026, 1, 15, 10, 0),
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
        ],
      );
      final photosState = legacy.StateProvider<List<PhotoAsset>>(
        (ref) => const [],
      );
      final container = ProviderContainer(
        overrides: [
          tripsProvider.overrideWith((ref) => ref.watch(tripsState)),
          entriesProvider.overrideWith((ref) => ref.watch(entriesState)),
          photosProvider.overrideWith((ref) => ref.watch(photosState)),
        ],
      );
      addTearDown(container.dispose);

      container.read(recordCurrentTimeProvider.notifier).state = DateTime(
        2026,
        3,
        15,
        12,
      );
      final marchProjection = container.read(
        recordCountryProjectionProvider('FR'),
      )!;
      final marchScene = container.read(
        recordGlobeSceneSpecProvider(Brightness.light),
      );
      final marchFrance = marchScene.countries.singleWhere(
        (country) => country.code == 'FR',
      );

      expect(marchProjection.hasRecentVisit, isTrue);
      expect(marchProjection.hasUpcomingTrip, isTrue);
      expect(marchFrance.hasRecentVisit, isTrue);
      expect(marchFrance.hasUpcomingTrip, isTrue);

      container.read(recordCurrentTimeProvider.notifier).state = DateTime(
        2026,
        5,
        1,
        12,
      );
      final mayProjection =
          container.read(recordCountryProjectionProvider('FR'))!;
      final mayScene = container.read(
        recordGlobeSceneSpecProvider(Brightness.light),
      );
      final mayFrance = mayScene.countries.singleWhere(
        (country) => country.code == 'FR',
      );

      expect(mayProjection.hasRecentVisit, isFalse);
      expect(mayProjection.hasUpcomingTrip, isFalse);
      expect(mayFrance.hasRecentVisit, isFalse);
      expect(mayFrance.hasUpcomingTrip, isFalse);
    });
  });
}
