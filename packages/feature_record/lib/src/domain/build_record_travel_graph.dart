import 'dart:math' as math;

import 'package:core_domain/core_domain.dart';

import '../globe/domain/entities/record_globe_country.dart';
import '../models/record_models.dart';
import 'record_travel_graph.dart';

RecordTravelGraph buildRecordTravelGraph({
  required List<TripSummary> trips,
  required List<JournalEntry> entries,
  required List<PhotoAsset> photos,
  required DateTime now,
}) {
  final photoById = {for (final photo in photos) photo.id: photo};
  final mappedTrips = trips
      .map(
        (trip) => _mapTrip(
          trip: trip,
          entries: entries.where((entry) => entry.tripId == trip.id).toList(),
          photoById: photoById,
          now: now,
        ),
      )
      .toList()
    ..sort(
      (a, b) =>
          DateTime.parse(a.startDate).compareTo(DateTime.parse(b.startDate)),
    );

  final tripById = {for (final trip in mappedTrips) trip.id: trip};
  final drafts = <String, _CountryProjectionDraft>{};

  for (final trip in mappedTrips) {
    for (final location in trip.locations) {
      final draft = drafts.putIfAbsent(
        location.countryCode,
        () => _CountryProjectionDraft(
          code: location.countryCode,
          name: location.countryName,
          continent: _continentFor(location.countryCode),
          accentColor: _colorForCountry(location.countryCode),
        ),
      );
      draft.addLocation(trip: trip, location: location);
    }
  }

  final entriesById = {
    for (final entry in entries) entry.id: entry,
  };
  for (final entry in entriesById.values) {
    final trip = tripById[entry.tripId];
    if (trip == null) {
      continue;
    }
    final photoLabels = <String>[
      for (final photoId in entry.photoAssetIds)
        if (photoById[photoId] case final photo?) photo.previewLabel,
    ];
    final draft = drafts.putIfAbsent(
      entry.place.countryCode,
      () => _CountryProjectionDraft(
        code: entry.place.countryCode,
        name: entry.place.countryName,
        continent: _continentFor(entry.place.countryCode),
        accentColor: _colorForCountry(entry.place.countryCode),
      ),
    );
    draft.addMoment(
      RecordTimelineMoment(
        id: entry.id,
        tripId: trip.id,
        tripTitle: trip.title,
        locationName: entry.place.cityName,
        happenedAt: entry.recordedAt,
        title: entry.title,
        summary: entry.body,
        photoLabels: photoLabels,
        isPlanned: trip.isUpcoming,
      ),
    );
  }

  final countries =
      drafts.values.map((draft) => draft.build(now)).toList(growable: false)
        ..sort((a, b) {
          final scoreOrder = b.activityScore.compareTo(a.activityScore);
          if (scoreOrder != 0) {
            return scoreOrder;
          }
          return a.name.compareTo(b.name);
        });

  return RecordTravelGraph(
    trips: List.unmodifiable(mappedTrips),
    countries: countries,
  );
}

RecordTrip _mapTrip({
  required TripSummary trip,
  required List<JournalEntry> entries,
  required Map<String, PhotoAsset> photoById,
  required DateTime now,
}) {
  final sortedEntries = [...entries]
    ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
  final countries = _countriesForTrip(trip, sortedEntries);
  final locations = sortedEntries.isEmpty
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
            isPlanned: trip.startDate.isAfter(now),
          ),
        ]
      : sortedEntries.map((entry) {
          final relatedPhotoLabels = <String>[
            for (final photoId in entry.photoAssetIds)
              if (photoById[photoId] case final photo?) photo.previewLabel,
          ];
          return RecordLocation(
            id: entry.id,
            name: entry.place.cityName,
            countryCode: entry.place.countryCode,
            countryName: entry.place.countryName,
            lat: entry.place.latitude ?? trip.heroPlace.latitude ?? 37.5665,
            lng: entry.place.longitude ?? trip.heroPlace.longitude ?? 126.9780,
            date: entry.recordedAt.toIso8601String(),
            photos: relatedPhotoLabels,
            isPlanned: trip.startDate.isAfter(now),
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
}

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

List<RecordGlobeCountry> buildRecordGlobeCountries(
  RecordTravelGraph graph,
) {
  return [
    for (final country in graph.countries)
      RecordGlobeCountry(
        code: country.code,
        name: country.name,
        anchorLatitude: country.centerLat,
        anchorLongitude: country.centerLng,
        continent: country.continent,
        visitCount: math.max(1, country.visitCount),
        activityScore: country.activityScore,
        activityLevel: country.activityLevel,
        signal: switch (country.signal) {
          RecordCountrySignal.planned => RecordGlobeCountrySignal.planned,
          RecordCountrySignal.visited => RecordGlobeCountrySignal.visited,
          RecordCountrySignal.neutral => RecordGlobeCountrySignal.neutral,
        },
        hasRecentVisit: country.hasRecentVisit,
        hasUpcomingTrip: country.hasUpcomingTrip,
        isSelectable: true,
      ),
  ];
}

class _CountryProjectionDraft {
  _CountryProjectionDraft({
    required this.code,
    required this.name,
    required this.continent,
    required this.accentColor,
  });

  final String code;
  final String name;
  final String continent;
  final String accentColor;

  final Map<String, RecordTrip> _trips = {};
  final List<RecordLocation> _locations = [];
  final List<RecordTimelineMoment> _moments = [];
  final Set<String> _cityKeys = {};
  final Set<String> _dayKeys = {};

  var _latSum = 0.0;
  var _lngSum = 0.0;
  double? _minLat;
  double? _maxLat;
  double? _minLng;
  double? _maxLng;

  void addLocation({
    required RecordTrip trip,
    required RecordLocation location,
  }) {
    _trips[trip.id] = trip;
    _locations.add(location);
    _cityKeys.add('${location.countryCode}:${location.name}');

    final happenedAt = DateTime.tryParse(location.date);
    if (happenedAt != null) {
      _dayKeys.add(_dayKey(happenedAt));
    }

    _latSum += location.lat;
    _lngSum += location.lng;
    _minLat = _minLat == null ? location.lat : math.min(_minLat!, location.lat);
    _maxLat = _maxLat == null ? location.lat : math.max(_maxLat!, location.lat);
    _minLng = _minLng == null ? location.lng : math.min(_minLng!, location.lng);
    _maxLng = _maxLng == null ? location.lng : math.max(_maxLng!, location.lng);
  }

  void addMoment(RecordTimelineMoment moment) {
    _moments.add(moment);
  }

  RecordCountryProjection build(DateTime now) {
    final sortedTrips = _trips.values.toList(growable: false)
      ..sort(
        (a, b) =>
            DateTime.parse(b.startDate).compareTo(DateTime.parse(a.startDate)),
      );
    final sortedLocations = [..._locations]
      ..sort((a, b) => a.date.compareTo(b.date));
    final sortedMoments = [..._moments]
      ..sort((a, b) => b.happenedAt.compareTo(a.happenedAt));

    final visitCount =
        sortedLocations.where((location) => !location.isPlanned).length;
    final plannedStopCount =
        sortedLocations.where((location) => location.isPlanned).length;
    final photoCount = sortedMoments.fold<int>(
      0,
      (count, moment) => count + moment.photoLabels.length,
    );
    final noteCount = sortedMoments
        .where((moment) => moment.summary.trim().isNotEmpty)
        .length;
    final hasUpcomingTrip = sortedTrips.any((trip) => trip.isUpcoming);
    final recentThreshold = now.subtract(const Duration(days: 90));
    final hasRecentVisit = sortedLocations.any((location) {
      if (location.isPlanned) {
        return false;
      }
      final happenedAt = DateTime.tryParse(location.date);
      return happenedAt != null && happenedAt.isAfter(recentThreshold);
    });

    final activityScore = _activityScore(
      cityCount: _cityKeys.length,
      visitCount: visitCount,
      photoCount: photoCount,
      noteCount: noteCount,
      totalDays: _dayKeys.length,
      hasUpcomingTrip: hasUpcomingTrip,
      hasRecentVisit: hasRecentVisit,
      tripCount: sortedTrips.length,
    );
    final activityLevel = _activityLevel(activityScore);

    final timelineGroups = <DateTime, List<RecordTimelineMoment>>{};
    for (final moment in sortedMoments) {
      final key = DateTime(
        moment.happenedAt.year,
        moment.happenedAt.month,
        moment.happenedAt.day,
      );
      timelineGroups
          .putIfAbsent(key, () => <RecordTimelineMoment>[])
          .add(moment);
    }

    final timelineDays = timelineGroups.entries
        .map(
          (entry) => RecordTimelineDay(
            date: entry.key,
            moments: List.unmodifiable(entry.value),
          ),
        )
        .toList(growable: false)
      ..sort((a, b) => b.date.compareTo(a.date));

    final albumMoments = sortedMoments
        .where((moment) => moment.photoLabels.isNotEmpty)
        .map(
          (moment) => RecordAlbumMoment(
            id: moment.id,
            tripId: moment.tripId,
            tripTitle: moment.tripTitle,
            locationName: moment.locationName,
            happenedAt: moment.happenedAt,
            primaryPhotoLabel: moment.photoLabels.first,
            photoCount: moment.photoLabels.length,
            summary: moment.summary,
            isPlanned: moment.isPlanned,
          ),
        )
        .toList(growable: false);

    final signal = visitCount > 0
        ? RecordCountrySignal.visited
        : (hasUpcomingTrip
            ? RecordCountrySignal.planned
            : RecordCountrySignal.neutral);

    return RecordCountryProjection(
      code: code,
      name: name,
      continent: continent,
      accentColor: accentColor,
      signal: signal,
      trips: List.unmodifiable(sortedTrips),
      locations: List.unmodifiable(sortedLocations),
      timelineDays: timelineDays,
      albumMoments: albumMoments,
      centerLat: _latSum / math.max(1, sortedLocations.length),
      centerLng: _lngSum / math.max(1, sortedLocations.length),
      minLat: _minLat ?? 0,
      maxLat: _maxLat ?? 0,
      minLng: _minLng ?? 0,
      maxLng: _maxLng ?? 0,
      tripCount: sortedTrips.length,
      cityCount: _cityKeys.length,
      visitCount: visitCount,
      plannedStopCount: plannedStopCount,
      photoCount: photoCount,
      noteCount: noteCount,
      totalDays: _dayKeys.length,
      activityScore: activityScore,
      activityLevel: activityLevel,
      hasUpcomingTrip: hasUpcomingTrip,
      hasRecentVisit: hasRecentVisit,
    );
  }
}

double _activityScore({
  required int cityCount,
  required int visitCount,
  required int photoCount,
  required int noteCount,
  required int totalDays,
  required bool hasUpcomingTrip,
  required bool hasRecentVisit,
  required int tripCount,
}) {
  return cityCount * 1.4 +
      visitCount * 1.1 +
      photoCount * 0.16 +
      noteCount * 0.45 +
      totalDays * 0.6 +
      tripCount * 0.8 +
      (hasUpcomingTrip ? 1.0 : 0) +
      (hasRecentVisit ? 1.6 : 0);
}

int _activityLevel(double score) {
  if (score >= 12) {
    return 3;
  }
  if (score >= 6) {
    return 2;
  }
  if (score > 0) {
    return 1;
  }
  return 0;
}

String _dayKey(DateTime value) => '${value.year}-${value.month}-${value.day}';

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
