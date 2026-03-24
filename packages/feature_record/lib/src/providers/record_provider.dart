import 'package:flutter/material.dart';
import 'package:core_data/core_data.dart';
import 'package:core_domain/core_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../domain/build_record_travel_graph.dart';
import '../domain/record_travel_graph.dart';
import '../globe/domain/entities/record_globe_asset_set.dart';
import '../globe/domain/entities/record_globe_scene_spec.dart';
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
  return ref.watch(recordTravelGraphProvider).trips;
});

final recordCurrentTimeProvider =
    StateProvider<DateTime>((ref) => DateTime.now());

final recordTravelGraphProvider = Provider<RecordTravelGraph>((ref) {
  return buildRecordTravelGraph(
    trips: ref.watch(tripsProvider),
    entries: ref.watch(entriesProvider),
    photos: ref.watch(photosProvider),
    now: ref.watch(recordCurrentTimeProvider),
  );
});

final recordGlobeSceneSpecProvider =
    Provider.family<RecordGlobeSceneSpec, Brightness>((ref, brightness) {
  final graph = ref.watch(recordTravelGraphProvider);
  final countries = buildRecordGlobeCountries(graph);

  final style = brightness == Brightness.light
      ? RecordGlobeStyle.light
      : RecordGlobeStyle.dark;
  final initialCountryCode = countries.isEmpty ? null : countries.first.code;

  return RecordGlobeSceneSpec(
    style: style,
    countries: countries,
    assetSet: RecordGlobeAssetSet(
      baseEarthTextureAsset: style == RecordGlobeStyle.light
          ? 'assets/globe/earth_storybook_light.png'
          : 'assets/globe/earth_storybook_dark.png',
      borderOverlayTextureAsset:
          'assets/globe/earth_borders_overlay_v1_4096.png',
      countryLookupGridAsset: 'assets/globe/country_lookup_v1.bin',
      countryLookupPaletteAsset: 'assets/globe/country_lookup_v1_palette.json',
    ),
    initialCountryCode: initialCountryCode,
  );
});

final recordCountryProjectionProvider =
    Provider.family<RecordCountryProjection?, String>((ref, countryCode) {
  return ref.watch(recordTravelGraphProvider).countriesByCode[countryCode];
});

String _titleForSnapshot(AtlasHomeSnapshot snapshot) {
  if (snapshot.totalTrips >= 8) return '지도 위에 기억을 쌓아가는 아카이비스트';
  if (snapshot.totalTrips >= 4) return '여행의 결을 모으는 탐험가';
  if (snapshot.totalTrips >= 1) return '첫 여정을 쌓는 기록가';
  return '아직 비어 있는 세계를 준비하는 여행자';
}
