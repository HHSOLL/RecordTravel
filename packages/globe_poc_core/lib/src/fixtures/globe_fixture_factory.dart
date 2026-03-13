import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../math/globe_math.dart';
import '../models/globe_models.dart';

class GlobeFixtureFactory {
  static GlobeFixture buildDefault() {
    const seed = 424242;
    final random = Random(seed);
    final countries = _buildCountries();
    final cities = _buildCities(random, countries);
    final routes = _buildRoutes(cities);
    final events = _buildTimelineEvents(cities);
    final textureBundle = _buildTextures(countries);
    return GlobeFixture(
      seed: seed,
      countries: countries,
      cities: cities,
      routes: routes,
      timelineEvents: events,
      textureBundle: textureBundle,
    );
  }

  static List<GlobeCountry> _buildCountries() {
    const continents = [
      'Americas',
      'Europe',
      'Africa',
      'Asia',
      'Oceania',
      'Polar',
    ];
    final colors = [
      const Color(0xFF4AC0FF),
      const Color(0xFF7CE38B),
      const Color(0xFFFFC35A),
      const Color(0xFFFF7B72),
      const Color(0xFF7F89FF),
      const Color(0xFFE4E7EF),
    ];
    final countries = <GlobeCountry>[];
    int index = 1;
    for (int latBand = 0; latBand < 4; latBand++) {
      final latMin = -80 + latBand * 40;
      final latMax = latMin + 40;
      for (int lonBand = 0; lonBand < 6; lonBand++) {
        final lonMin = -180 + lonBand * 60;
        final lonMax = lonMin + 60;
        countries.add(
          GlobeCountry(
            index: index,
            code: 'C${index.toString().padLeft(2, '0')}',
            name: 'Country ${index.toString().padLeft(2, '0')}',
            continent: continents[lonBand],
            latMin: latMin.toDouble(),
            latMax: latMax.toDouble(),
            lonMin: lonMin.toDouble(),
            lonMax: lonMax.toDouble(),
            displayColor: colors[lonBand],
          ),
        );
        index += 1;
      }
    }
    return countries;
  }

  static List<CityVisit> _buildCities(
    Random random,
    List<GlobeCountry> countries,
  ) {
    final baseDate = DateTime(2024, 1, 1);
    return List<CityVisit>.generate(1000, (index) {
      final country = countries[index % countries.length];
      final lat =
          country.latMin +
          4 +
          random.nextDouble() * (country.latMax - country.latMin - 8);
      final lon =
          country.lonMin +
          4 +
          random.nextDouble() * (country.lonMax - country.lonMin - 8);
      final tripNumber = (index ~/ 333) + 1;
      return CityVisit(
        id: 'city_$index',
        tripId: 'trip_$tripNumber',
        countryCode: country.code,
        cityName:
            '${country.code}-City-${(index % 36).toString().padLeft(2, '0')}',
        latitude: lat,
        longitude: lon,
        visitDate: baseDate.add(Duration(days: index ~/ 2, hours: index % 12)),
        markerColor: country.displayColor,
      );
    })..sort((a, b) => a.visitDate.compareTo(b.visitDate));
  }

  static List<TravelRoute> _buildRoutes(List<CityVisit> cities) {
    final routes = <TravelRoute>[];
    for (int index = 0; index < 50; index++) {
      final origin = cities[index * 8];
      final destination = cities[(index * 8 + 13) % cities.length];
      routes.add(
        TravelRoute(
          id: 'route_$index',
          tripId: origin.tripId,
          originCityId: origin.id,
          destinationCityId: destination.id,
          travelDate: destination.visitDate.subtract(const Duration(hours: 3)),
          transportType: index.isEven ? 'flight' : 'rail',
          points: GlobeMath.buildGreatCircleArc(
            originLat: origin.latitude,
            originLon: origin.longitude,
            destinationLat: destination.latitude,
            destinationLon: destination.longitude,
            segments: 42,
          ),
        ),
      );
    }
    return routes;
  }

  static List<TravelTimelineEvent> _buildTimelineEvents(
    List<CityVisit> cities,
  ) {
    return cities.take(120).map((city) {
      return TravelTimelineEvent(
        id: 'event_${city.id}',
        tripId: city.tripId,
        cityId: city.id,
        occurredAt: city.visitDate,
        label: 'Arrived at ${city.cityName}',
      );
    }).toList();
  }

  static GlobeTextureBundle _buildTextures(List<GlobeCountry> countries) {
    const width = 512;
    const height = 256;
    final earth = Uint8List(width * height * 4);
    final countryId = Uint8List(width * height * 4);
    for (int y = 0; y < height; y++) {
      final v = y / (height - 1);
      final lat = 90 - v * 180;
      for (int x = 0; x < width; x++) {
        final u = x / (width - 1);
        final lon = u * 360 - 180;
        final index = (y * width + x) * 4;
        final country = countries.firstWhere(
          (item) => item.contains(lat, lon),
          orElse: () => countries.last,
        );
        final hueBoost = (((lat + 90) / 180) * 30).round();
        final base = country.displayColor;
        earth[index] = (base.red * 0.6 + hueBoost).clamp(0, 255).toInt();
        earth[index + 1] = (base.green * 0.7 + 25).clamp(0, 255).toInt();
        earth[index + 2] = (base.blue * 0.8 + 50).clamp(0, 255).toInt();
        earth[index + 3] = 255;
        if (x % 64 == 0 || y % 64 == 0) {
          earth[index] = 255;
          earth[index + 1] = 255;
          earth[index + 2] = 255;
        }
        countryId[index] = country.index;
        countryId[index + 1] = 0;
        countryId[index + 2] = 0;
        countryId[index + 3] = 255;
      }
    }
    return GlobeTextureBundle(
      width: width,
      height: height,
      earthRgba: earth,
      countryIdRgba: countryId,
    );
  }
}
