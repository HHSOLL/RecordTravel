import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:core_data/core_data.dart';
import 'package:core_domain/core_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../globe/domain/entities/record_globe_asset_set.dart';
import '../globe/domain/entities/record_globe_country.dart';
import '../globe/domain/entities/record_globe_scene_spec.dart';
import '../globe_engine/record_globe_engine_config.dart';
import '../models/record_models.dart';

final recordUserProvider = Provider<RecordUserData>((ref) {
  final session = ref.watch(sessionSnapshotProvider);
  final home = ref.watch(atlasHomeSnapshotProvider);
  return RecordUserData(
    name: session.user.displayName,
    title: _titleForSnapshot(home),
    totalCities: home.visitedCities,
    totalCountries: home.visitedCountries,
    totalTrips: home.totalTrips,
  );
});

final recordTripsProvider = Provider<List<RecordTrip>>((ref) {
  final trips = ref.watch(tripsProvider);
  final entries = ref.watch(entriesProvider);
  final photos = ref.watch(photosProvider);
  final now = DateTime.now();

  final mapped = trips.map((trip) {
    final tripEntries = entries
        .where((entry) => entry.tripId == trip.id)
        .toList()
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
    final countries = _countriesForTrip(trip, tripEntries);
    final locations = tripEntries.isEmpty
        ? [
            RecordLocation(
              id: 'hero-${trip.id}',
              name: trip.heroPlace.cityName,
              countryCode: trip.heroPlace.countryCode,
              countryName: trip.heroPlace.countryName,
              lat: trip.heroPlace.latitude ?? 37.5665,
              lng: trip.heroPlace.longitude ?? 126.9780,
              date: trip.startDate.toIso8601String(),
              photos: const [],
            ),
          ]
        : tripEntries.map((entry) {
            final relatedPhotoLabels = <String>[
              for (final photoId in entry.photoAssetIds)
                for (final photo in photos)
                  if (photo.id == photoId) photo.previewLabel,
            ];
            return RecordLocation(
              id: entry.id,
              name: entry.place.cityName,
              countryCode: entry.place.countryCode,
              countryName: entry.place.countryName,
              lat: entry.place.latitude ?? trip.heroPlace.latitude ?? 37.5665,
              lng:
                  entry.place.longitude ?? trip.heroPlace.longitude ?? 126.9780,
              date: entry.recordedAt.toIso8601String(),
              photos: relatedPhotoLabels,
            );
          }).toList(growable: false);

    return RecordTrip(
      id: trip.id,
      title: trip.title,
      countries: countries,
      startDate: trip.startDate.toIso8601String(),
      endDate: trip.endDate.toIso8601String(),
      description: trip.subtitle.isNotEmpty ? trip.subtitle : trip.coverHint,
      coverImage: trip.coverHint,
      isUpcoming: trip.startDate.isAfter(now),
      locations: locations,
      color: _colorForCountry(countries.first.code),
      companions: const [],
    );
  }).toList()
    ..sort((a, b) =>
        DateTime.parse(a.startDate).compareTo(DateTime.parse(b.startDate)));

  return mapped;
});

final recordGlobeSceneSpecProvider =
    Provider.family<RecordGlobeSceneSpec, Brightness>((ref, brightness) {
  final trips = ref.watch(recordTripsProvider);
  final anchorDrafts = <String, _AnchorDraft>{};

  for (final trip in trips) {
    for (final location in trip.locations) {
      final country = trip.countries.firstWhere(
        (candidate) =>
            candidate.code == _countryCodeForLocation(trip, location),
        orElse: () => trip.countries.first,
      );
      final draft = anchorDrafts.putIfAbsent(
        country.code,
        () => _AnchorDraft(
          countryCode: country.code,
          countryName: country.name,
          isUpcoming: trip.isUpcoming,
        ),
      );
      draft.addLocation(location, isUpcoming: trip.isUpcoming);
    }
  }

  final countries = anchorDrafts.values
      .map((draft) => draft.build())
      .toList(growable: false)
    ..sort((a, b) => b.visitCount.compareTo(a.visitCount));

  final style = brightness == Brightness.light
      ? RecordGlobeStyle.light
      : RecordGlobeStyle.dark;
  final initialCountryCode = countries.isEmpty ? null : countries.first.code;

  return RecordGlobeSceneSpec(
    style: style,
    countries: countries,
    assetSet: RecordGlobeAssetSet(
      rendererKind: RecordGlobeRendererKind.threeJs,
      baseEarthTextureAsset: style == RecordGlobeStyle.light
          ? 'assets/globe/earth_storybook_light.png'
          : 'assets/globe/earth_storybook_dark.png',
      countryIdTextureAsset: 'assets/globe/record_country_shapes.json',
      borderOverlayTextureAsset: 'assets/globe/earth_borders_overlay_v1_4096.png',
      countryMetadataAsset: 'assets/globe/record_country_shapes.json',
      usesHighResolutionTextures: false,
    ),
    initialCountryCode: initialCountryCode,
    selectedCountryCode: initialCountryCode,
    focusedCountryCode: initialCountryCode,
  );
});

final recordCountrySpotlightProvider =
    Provider.family<RecordCountrySpotlight?, String>((ref, countryCode) {
  final trips = ref.watch(recordTripsProvider);
  final matchingTrips = <RecordTrip>[];
  final matchingLocations = <RecordLocation>[];
  RecordCountry? primaryCountry;

  for (final trip in trips) {
    final country = trip.countries.where((item) => item.code == countryCode);
    if (country.isEmpty) {
      continue;
    }
    matchingTrips.add(trip);
    primaryCountry ??= country.first;
    matchingLocations.addAll(
      trip.locations.where((location) => location.countryCode == countryCode),
    );
  }

  if (matchingTrips.isEmpty || primaryCountry == null) {
    return null;
  }

  matchingLocations.sort((a, b) => a.date.compareTo(b.date));

  final sourceLocations = matchingLocations.isEmpty
      ? [
          for (final trip in matchingTrips)
            if (trip.locations.isNotEmpty) trip.locations.first,
        ]
      : matchingLocations;

  var latSum = 0.0;
  var lngSum = 0.0;
  var minLat = sourceLocations.first.lat;
  var maxLat = sourceLocations.first.lat;
  var minLng = sourceLocations.first.lng;
  var maxLng = sourceLocations.first.lng;

  for (final location in sourceLocations) {
    latSum += location.lat;
    lngSum += location.lng;
    minLat = math.min(minLat, location.lat);
    maxLat = math.max(maxLat, location.lat);
    minLng = math.min(minLng, location.lng);
    maxLng = math.max(maxLng, location.lng);
  }

  return RecordCountrySpotlight(
    code: primaryCountry.code,
    name: primaryCountry.name,
    continent: primaryCountry.continent,
    color: matchingTrips.first.color,
    trips: matchingTrips,
    locations: sourceLocations,
    centerLat: latSum / sourceLocations.length,
    centerLng: lngSum / sourceLocations.length,
    minLat: minLat,
    maxLat: maxLat,
    minLng: minLng,
    maxLng: maxLng,
  );
});

List<RecordCountry> _countriesForTrip(
  TripSummary trip,
  List<JournalEntry> entries,
) {
  if (entries.isEmpty) {
    return [
      RecordCountry(
        name: trip.heroPlace.countryName,
        code: trip.heroPlace.countryCode,
        continent: _continentFor(trip.heroPlace.countryCode),
      ),
    ];
  }
  final unique = <String, RecordCountry>{};
  for (final entry in entries) {
    unique[entry.place.countryCode] = RecordCountry(
      name: entry.place.countryName,
      code: entry.place.countryCode,
      continent: _continentFor(entry.place.countryCode),
    );
  }
  return unique.values.toList(growable: false);
}

String _titleForSnapshot(AtlasHomeSnapshot snapshot) {
  if (snapshot.totalTrips >= 8) return '지도 위에 기억을 쌓아가는 아카이비스트';
  if (snapshot.totalTrips >= 4) return '여행의 결을 모으는 탐험가';
  if (snapshot.totalTrips >= 1) return '첫 여정을 쌓는 기록가';
  return '아직 비어 있는 세계를 준비하는 여행자';
}

String _continentFor(String countryCode) {
  switch (countryCode) {
    case 'KR':
    case 'JP':
    case 'CN':
    case 'TH':
    case 'VN':
    case 'SG':
      return 'Asia';
    case 'FR':
    case 'IT':
    case 'PT':
    case 'ES':
    case 'DE':
    case 'GB':
      return 'Europe';
    case 'US':
    case 'CA':
    case 'MX':
      return 'North America';
    case 'BR':
    case 'AR':
    case 'CL':
      return 'South America';
    case 'AU':
    case 'NZ':
      return 'Oceania';
    case 'ZA':
    case 'EG':
    case 'MA':
      return 'Africa';
    default:
      return 'World';
  }
}

String _colorForCountry(String countryCode) {
  switch (countryCode) {
    case 'KR':
      return '#4D7CFE';
    case 'JP':
      return '#E96D7B';
    case 'PT':
      return '#F3A84A';
    case 'FR':
      return '#6E8BF4';
    case 'IT':
      return '#49B884';
    case 'CA':
      return '#E06A61';
    default:
      return '#7C9BCF';
  }
}

String _countryCodeForLocation(RecordTrip trip, RecordLocation location) {
  for (final country in trip.countries) {
    if (country.code == location.countryCode) {
      return country.code;
    }
  }
  return trip.countries.first.code;
}

class _AnchorDraft {
  _AnchorDraft({
    required this.countryCode,
    required this.countryName,
    required this.isUpcoming,
  });

  final String countryCode;
  final String countryName;
  bool isUpcoming;

  int markerCount = 0;
  double latitudeSum = 0;
  double longitudeSum = 0;

  void addLocation(
    RecordLocation location, {
    required bool isUpcoming,
  }) {
    markerCount += 1;
    latitudeSum += location.lat;
    longitudeSum += location.lng;
    this.isUpcoming = this.isUpcoming || isUpcoming;
  }

  RecordGlobeCountry build() {
    return RecordGlobeCountry(
      code: countryCode,
      name: countryName,
      anchorLatitude: latitudeSum / markerCount,
      anchorLongitude: longitudeSum / markerCount,
      continent: _continentFor(countryCode),
      visitCount: markerCount,
      isSelectable: true,
    );
  }
}
