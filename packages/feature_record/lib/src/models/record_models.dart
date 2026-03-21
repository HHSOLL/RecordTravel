import 'package:flutter/foundation.dart';

@immutable
class RecordCountry {
  const RecordCountry({
    required this.name,
    required this.code,
    required this.continent,
  });

  final String name;
  final String code;
  final String continent;
}

@immutable
class RecordLocation {
  const RecordLocation({
    required this.id,
    required this.name,
    required this.countryCode,
    required this.countryName,
    required this.lat,
    required this.lng,
    required this.date,
    required this.photos,
  });

  final String id;
  final String name;
  final String countryCode;
  final String countryName;
  final double lat;
  final double lng;
  final String date;
  final List<String> photos;
}

@immutable
class RecordTrip {
  const RecordTrip({
    required this.id,
    required this.title,
    required this.countries,
    required this.startDate,
    required this.endDate,
    required this.description,
    required this.coverImage,
    required this.isUpcoming,
    required this.locations,
    required this.color,
    required this.companions,
  });

  final String id;
  final String title;
  final List<RecordCountry> countries;
  final String startDate;
  final String endDate;
  final String description;
  final String coverImage;
  final bool isUpcoming;
  final List<RecordLocation> locations;
  final String color;
  final List<String> companions;

  RecordTrip copyWith({
    String? title,
    List<RecordCountry>? countries,
    String? startDate,
    String? endDate,
    String? description,
    String? coverImage,
    bool? isUpcoming,
    List<RecordLocation>? locations,
    String? color,
    List<String>? companions,
  }) {
    return RecordTrip(
      id: id,
      title: title ?? this.title,
      countries: countries ?? this.countries,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      description: description ?? this.description,
      coverImage: coverImage ?? this.coverImage,
      isUpcoming: isUpcoming ?? this.isUpcoming,
      locations: locations ?? this.locations,
      color: color ?? this.color,
      companions: companions ?? this.companions,
    );
  }
}

@immutable
class RecordUserData {
  const RecordUserData({
    required this.name,
    required this.title,
    required this.totalCities,
    required this.totalCountries,
    required this.totalTrips,
  });

  final String name;
  final String title;
  final int totalCities;
  final int totalCountries;
  final int totalTrips;
}
