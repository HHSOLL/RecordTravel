import 'package:flutter/foundation.dart';

enum RecordGlobeCountrySignal {
  neutral,
  planned,
  visited,
}

@immutable
class RecordGlobeCountry {
  const RecordGlobeCountry({
    required this.code,
    required this.name,
    required this.anchorLatitude,
    required this.anchorLongitude,
    required this.continent,
    this.visitCount = 0,
    this.activityScore = 0,
    this.activityLevel = 0,
    this.signal = RecordGlobeCountrySignal.neutral,
    this.hasRecentVisit = false,
    this.hasUpcomingTrip = false,
    this.isSelectable = true,
  });

  final String code;
  final String name;
  final double anchorLatitude;
  final double anchorLongitude;
  final String continent;
  final int visitCount;
  final double activityScore;
  final int activityLevel;
  final RecordGlobeCountrySignal signal;
  final bool hasRecentVisit;
  final bool hasUpcomingTrip;
  final bool isSelectable;

  RecordGlobeCountry copyWith({
    String? code,
    String? name,
    double? anchorLatitude,
    double? anchorLongitude,
    String? continent,
    int? visitCount,
    double? activityScore,
    int? activityLevel,
    RecordGlobeCountrySignal? signal,
    bool? hasRecentVisit,
    bool? hasUpcomingTrip,
    bool? isSelectable,
  }) {
    return RecordGlobeCountry(
      code: code ?? this.code,
      name: name ?? this.name,
      anchorLatitude: anchorLatitude ?? this.anchorLatitude,
      anchorLongitude: anchorLongitude ?? this.anchorLongitude,
      continent: continent ?? this.continent,
      visitCount: visitCount ?? this.visitCount,
      activityScore: activityScore ?? this.activityScore,
      activityLevel: activityLevel ?? this.activityLevel,
      signal: signal ?? this.signal,
      hasRecentVisit: hasRecentVisit ?? this.hasRecentVisit,
      hasUpcomingTrip: hasUpcomingTrip ?? this.hasUpcomingTrip,
      isSelectable: isSelectable ?? this.isSelectable,
    );
  }
}
