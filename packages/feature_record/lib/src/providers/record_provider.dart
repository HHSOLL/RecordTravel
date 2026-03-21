import 'package:flutter/material.dart';
import 'package:core_data/core_data.dart';
import 'package:core_domain/core_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/record_globe_scene.dart';
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

final recordGlobeSceneProvider =
    Provider.family<RecordGlobeScene, Brightness>((ref, brightness) {
  final trips = ref.watch(recordTripsProvider);
  final anchorDrafts = <String, _AnchorDraft>{};
  final arcs = <RecordGlobeArc>[];

  for (final trip in trips) {
    RecordLocation? previousLocation;
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
          colorHex: trip.color,
          isUpcoming: trip.isUpcoming,
        ),
      );
      draft.addLocation(location, isUpcoming: trip.isUpcoming);

      if (previousLocation != null) {
        final fromCountry = _countryForLocation(trip, previousLocation);
        final toCountry = _countryForLocation(trip, location);
        if (fromCountry.code != toCountry.code) {
          arcs.add(
            RecordGlobeArc(
              id: '${trip.id}:${previousLocation.id}:${location.id}',
              fromCountryCode: fromCountry.code,
              toCountryCode: toCountry.code,
              fromLatitude: previousLocation.lat,
              fromLongitude: previousLocation.lng,
              toLatitude: location.lat,
              toLongitude: location.lng,
              color: _parseHexColor(trip.color),
              weight: trip.isUpcoming ? 0.72 : 1.0,
              isUpcoming: trip.isUpcoming,
            ),
          );
        }
      }
      previousLocation = location;
    }
  }

  final anchors = anchorDrafts.values
      .map((draft) => draft.build())
      .toList(growable: false)
    ..sort((a, b) => b.emphasis.compareTo(a.emphasis));

  final visibleArcs = arcs.take(18).toList(growable: false);

  return RecordGlobeScene(
    style: brightness == Brightness.light
        ? RecordGlobeStyle.storybookLight
        : RecordGlobeStyle.orbitNight,
    initialCountryCode: anchors.isEmpty ? null : anchors.first.countryCode,
    anchors: anchors,
    arcs: visibleArcs,
    selectableCountryCodes: anchors.map((anchor) => anchor.countryCode).toSet(),
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

RecordCountry _countryForLocation(RecordTrip trip, RecordLocation location) {
  for (final country in trip.countries) {
    if (country.code == location.countryCode) return country;
  }
  return trip.countries.first;
}

String _countryCodeForLocation(RecordTrip trip, RecordLocation location) {
  for (final country in trip.countries) {
    if (country.code == location.countryCode) {
      return country.code;
    }
  }
  return trip.countries.first.code;
}

Color _parseHexColor(String input) {
  final normalized = input.replaceAll('#', '');
  final expanded = normalized.length == 6 ? 'FF$normalized' : normalized;
  return Color(int.parse(expanded, radix: 16));
}

class _AnchorDraft {
  _AnchorDraft({
    required this.countryCode,
    required this.countryName,
    required this.colorHex,
    required this.isUpcoming,
  });

  final String countryCode;
  final String countryName;
  final String colorHex;
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

  RecordGlobeAnchor build() {
    final emphasisBase = markerCount.clamp(1, 6).toDouble();
    final emphasis = (emphasisBase / 6).clamp(0.2, 1.0);
    return RecordGlobeAnchor(
      countryCode: countryCode,
      countryName: countryName,
      latitude: latitudeSum / markerCount,
      longitude: longitudeSum / markerCount,
      markerCount: markerCount,
      emphasis: emphasis,
      color: _parseHexColor(colorHex),
      isUpcoming: isUpcoming,
    );
  }
}
