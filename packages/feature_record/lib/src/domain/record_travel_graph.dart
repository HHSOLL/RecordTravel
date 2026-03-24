import 'package:flutter/foundation.dart';

import '../models/record_models.dart';

enum RecordCountrySignal {
  neutral,
  planned,
  visited,
}

@immutable
class RecordTimelineMoment {
  const RecordTimelineMoment({
    required this.id,
    required this.tripId,
    required this.tripTitle,
    required this.locationName,
    required this.happenedAt,
    required this.title,
    required this.summary,
    required this.photoLabels,
    required this.isPlanned,
    required this.isSynthetic,
  });

  final String id;
  final String tripId;
  final String tripTitle;
  final String locationName;
  final DateTime happenedAt;
  final String title;
  final String summary;
  final List<String> photoLabels;
  final bool isPlanned;
  final bool isSynthetic;
}

@immutable
class RecordTimelineDay {
  const RecordTimelineDay({
    required this.date,
    required this.moments,
  });

  final DateTime date;
  final List<RecordTimelineMoment> moments;
}

@immutable
class RecordAlbumMoment {
  const RecordAlbumMoment({
    required this.id,
    required this.tripId,
    required this.tripTitle,
    required this.locationName,
    required this.happenedAt,
    required this.primaryPhotoLabel,
    required this.photoCount,
    required this.summary,
    required this.isPlanned,
    required this.isSynthetic,
  });

  final String id;
  final String tripId;
  final String tripTitle;
  final String locationName;
  final DateTime happenedAt;
  final String primaryPhotoLabel;
  final int photoCount;
  final String summary;
  final bool isPlanned;
  final bool isSynthetic;
}

@immutable
class RecordCountryProjection {
  const RecordCountryProjection({
    required this.code,
    required this.name,
    required this.continent,
    required this.accentColor,
    required this.signal,
    required this.trips,
    required this.locations,
    required this.timelineDays,
    required this.albumMoments,
    required this.centerLat,
    required this.centerLng,
    required this.minLat,
    required this.maxLat,
    required this.minLng,
    required this.maxLng,
    required this.tripCount,
    required this.cityCount,
    required this.visitCount,
    required this.plannedStopCount,
    required this.photoCount,
    required this.noteCount,
    required this.totalDays,
    required this.activityScore,
    required this.activityLevel,
    required this.hasUpcomingTrip,
    required this.hasRecentVisit,
  });

  final String code;
  final String name;
  final String continent;
  final String accentColor;
  final RecordCountrySignal signal;
  final List<RecordTrip> trips;
  final List<RecordLocation> locations;
  final List<RecordTimelineDay> timelineDays;
  final List<RecordAlbumMoment> albumMoments;
  final double centerLat;
  final double centerLng;
  final double minLat;
  final double maxLat;
  final double minLng;
  final double maxLng;
  final int tripCount;
  final int cityCount;
  final int visitCount;
  final int plannedStopCount;
  final int photoCount;
  final int noteCount;
  final int totalDays;
  final double activityScore;
  final int activityLevel;
  final bool hasUpcomingTrip;
  final bool hasRecentVisit;

  bool get hasVisits => visitCount > 0;
}

@immutable
class RecordTravelGraph {
  RecordTravelGraph({
    required this.trips,
    required List<RecordCountryProjection> countries,
  })  : countries = List.unmodifiable(countries),
        countriesByCode = Map.unmodifiable({
          for (final country in countries) country.code: country,
        });

  final List<RecordTrip> trips;
  final List<RecordCountryProjection> countries;
  final Map<String, RecordCountryProjection> countriesByCode;
}
