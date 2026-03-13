import 'package:core_domain/core_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../contracts/photo_ingestion_platform_adapter.dart';
import '../contracts/remote_sync_gateway.dart';
import '../contracts/session_repository.dart';
import '../contracts/travel_remote_data_source.dart';
import '../contracts/travel_local_store.dart';
import '../services/photo_import_service.dart';
import '../services/place_inference_service.dart';

final backendProfileProvider = Provider<BackendProfile>(
  (ref) => throw UnimplementedError(
    'backendProfileProvider must be overridden by the app bootstrap.',
  ),
);

final sessionRepositoryProvider = ChangeNotifierProvider<SessionRepository>(
  (ref) => throw UnimplementedError(
    'sessionRepositoryProvider must be overridden by the app bootstrap.',
  ),
);

final travelLocalStoreProvider = Provider<TravelLocalStore>(
  (ref) => throw UnimplementedError(
    'travelLocalStoreProvider must be overridden by the app bootstrap.',
  ),
);

final remoteSyncGatewayProvider = Provider<RemoteSyncGateway>(
  (ref) => throw UnimplementedError(
    'remoteSyncGatewayProvider must be overridden by the app bootstrap.',
  ),
);

final travelRemoteDataSourceProvider = Provider<TravelRemoteDataSource>(
  (ref) => throw UnimplementedError(
    'travelRemoteDataSourceProvider must be overridden by the app bootstrap.',
  ),
);

final photoIngestionAdapterProvider = Provider<PhotoIngestionPlatformAdapter>(
  (ref) => throw UnimplementedError(
    'PhotoIngestionPlatformAdapter must be overridden by the mobile app shell.',
  ),
);

final placeInferenceServiceProvider = Provider<PlaceInferenceService>(
  (ref) => const PlaceInferenceService(),
);

final photoImportServiceProvider = Provider<PhotoImportService>((ref) {
  return PhotoImportService(
    adapter: ref.watch(photoIngestionAdapterProvider),
    localStore: ref.watch(travelLocalStoreProvider),
    placeInferenceService: ref.watch(placeInferenceServiceProvider),
  );
});

final travelAppControllerProvider =
    NotifierProvider<TravelAppController, TravelAppState>(
      TravelAppController.new,
    );

final sessionSnapshotProvider = Provider<SessionSnapshot>(
  (ref) => ref.watch(sessionRepositoryProvider).currentSession,
);
final syncSnapshotProvider = Provider<SyncSnapshot>(
  (ref) => ref.watch(travelAppControllerProvider).syncSnapshot,
);
final tripsProvider = Provider<List<TripSummary>>(
  (ref) => ref.watch(travelAppControllerProvider).trips,
);
final entriesProvider = Provider<List<JournalEntry>>(
  (ref) => ref.watch(travelAppControllerProvider).entries,
);
final photosProvider = Provider<List<PhotoAsset>>(
  (ref) => ref.watch(travelAppControllerProvider).photos,
);

final atlasHomeSnapshotProvider = Provider<AtlasHomeSnapshot>((ref) {
  final state = ref.watch(travelAppControllerProvider);
  final sortedEntries = [...state.entries]
    ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
  final sortedTrips = [...state.trips]
    ..sort((a, b) => b.startDate.compareTo(a.startDate));
  final countries = _buildCountrySummaries(state.entries);
  return AtlasHomeSnapshot(
    visitedCountries: countries.length,
    totalTrips: state.trips.length,
    pendingUploads: state.syncSnapshot.pendingUploads,
    syncSnapshot: state.syncSnapshot,
    recentTrips: sortedTrips.take(3).toList(growable: false),
    recentEntries: sortedEntries.take(4).toList(growable: false),
    highlightCountries: countries.take(4).toList(growable: false),
  );
});

final allTimelineGroupsProvider = Provider<List<TimelineDayGroup>>((ref) {
  final entries = ref.watch(entriesProvider);
  return _groupEntriesByDay(entries);
});

final tripTimelineGroupsProvider =
    Provider.family<List<TimelineDayGroup>, String>((ref, tripId) {
      final entries = ref
          .watch(entriesProvider)
          .where((entry) => entry.tripId == tripId)
          .toList();
      return _groupEntriesByDay(entries);
    });

final tripByIdProvider = Provider.family<TripSummary?, String>((ref, tripId) {
  final trips = ref.watch(tripsProvider);
  for (final trip in trips) {
    if (trip.id == tripId) return trip;
  }
  return null;
});

final countryDetailProvider = Provider.family<CountryDetailSnapshot?, String>((
  ref,
  countryCode,
) {
  final state = ref.watch(travelAppControllerProvider);
  final summary = _buildCountrySummaries(
    state.entries,
  ).where((item) => item.countryCode == countryCode).firstOrNull;
  if (summary == null) return null;
  final entries =
      state.entries
          .where((entry) => entry.place.countryCode == countryCode)
          .toList()
        ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
  final cityMap = <String, CitySummary>{};
  for (final entry in entries) {
    final key = entry.place.cityKey;
    final current = cityMap[key];
    cityMap[key] = CitySummary(
      key: key,
      countryCode: entry.place.countryCode,
      countryName: entry.place.countryName,
      cityName: entry.place.cityName,
      visitCount: (current?.visitCount ?? 0) + 1,
      lastVisitedAt:
          current == null || entry.recordedAt.isAfter(current.lastVisitedAt)
          ? entry.recordedAt
          : current.lastVisitedAt,
    );
  }
  final tripIds = entries.map((entry) => entry.tripId).toSet();
  final trips = state.trips.where((trip) => tripIds.contains(trip.id)).toList();
  return CountryDetailSnapshot(
    summary: summary,
    cities: cityMap.values.toList()
      ..sort((a, b) => b.lastVisitedAt.compareTo(a.lastVisitedAt)),
    entries: entries,
    trips: trips,
  );
});

final cityDetailProvider = Provider.family<CityDetailSnapshot?, String>((
  ref,
  cityKey,
) {
  final state = ref.watch(travelAppControllerProvider);
  final entries =
      state.entries.where((entry) => entry.place.cityKey == cityKey).toList()
        ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
  if (entries.isEmpty) return null;
  final place = entries.first.place;
  final summary = CitySummary(
    key: cityKey,
    countryCode: place.countryCode,
    countryName: place.countryName,
    cityName: place.cityName,
    visitCount: entries.length,
    lastVisitedAt: entries.first.recordedAt,
  );
  final tripIds = entries.map((entry) => entry.tripId).toSet();
  final trips = state.trips.where((trip) => tripIds.contains(trip.id)).toList();
  return CityDetailSnapshot(summary: summary, entries: entries, trips: trips);
});

final searchResultsProvider = Provider.family<List<SearchResultItem>, String>((
  ref,
  query,
) {
  final needle = query.trim().toLowerCase();
  if (needle.isEmpty) return const [];
  final state = ref.watch(travelAppControllerProvider);
  final results = <SearchResultItem>[];

  for (final trip in state.trips) {
    if ([
      trip.title,
      trip.subtitle,
      trip.heroPlace.fullLabel,
    ].join(' ').toLowerCase().contains(needle)) {
      results.add(
        SearchResultItem(
          type: SearchResultType.trip,
          id: trip.id,
          title: trip.title,
          subtitle: trip.subtitle,
          place: trip.heroPlace,
        ),
      );
    }
  }

  for (final entry in state.entries) {
    if ([
      entry.title,
      entry.body,
      entry.place.fullLabel,
    ].join(' ').toLowerCase().contains(needle)) {
      results.add(
        SearchResultItem(
          type: SearchResultType.entry,
          id: entry.id,
          title: entry.title,
          subtitle: entry.body,
          place: entry.place,
        ),
      );
    }
  }

  for (final country in _buildCountrySummaries(state.entries)) {
    if ('${country.countryName} ${country.countryCode}'.toLowerCase().contains(
      needle,
    )) {
      results.add(
        SearchResultItem(
          type: SearchResultType.country,
          id: country.countryCode,
          title: country.countryName,
          subtitle:
              '${country.cityCount} cities • ${country.visitCount} memories',
        ),
      );
    }
  }

  for (final city in _buildCitySummaries(state.entries)) {
    if ('${city.cityName} ${city.countryName}'.toLowerCase().contains(needle)) {
      results.add(
        SearchResultItem(
          type: SearchResultType.city,
          id: city.key,
          title: city.cityName,
          subtitle: city.countryName,
        ),
      );
    }
  }

  return results;
});

class TravelAppController extends Notifier<TravelAppState> {
  late final TravelLocalStore _store;
  late final RemoteSyncGateway _remoteSyncGateway;
  late final PhotoImportService _photoImportService;

  @override
  TravelAppState build() {
    _store = ref.watch(travelLocalStoreProvider);
    _remoteSyncGateway = ref.watch(remoteSyncGatewayProvider);
    _photoImportService = ref.watch(photoImportServiceProvider);

    void listener() {
      state = _store.snapshot;
    }

    _store.addListener(listener);
    ref.onDispose(() => _store.removeListener(listener));
    return _store.snapshot;
  }

  Future<List<PhotoImportDraft>> preparePhotoImportDrafts({String? tripId}) {
    return _photoImportService.prepareDrafts(tripId: tripId);
  }

  Future<void> createJournalEntry({
    required String tripId,
    required String title,
    required String body,
    required PlaceRef place,
  }) async {
    await _store.addJournalEntry(
      JournalEntry(
        id: 'entry-${DateTime.now().microsecondsSinceEpoch}',
        tripId: tripId,
        title: title,
        body: body,
        recordedAt: DateTime.now(),
        place: place,
        type: MemoryType.note,
        photoAssetIds: const [],
        hasPendingUpload: false,
      ),
    );
  }

  Future<void> importPhotoDrafts({
    required String tripId,
    required List<PhotoImportDraft> drafts,
  }) async {
    await _photoImportService.importDrafts(tripId: tripId, drafts: drafts);
  }

  Future<void> markSyncRequested() async {
    final nextSync = await _remoteSyncGateway.requestSync(_store);
    await _store.updateSyncSnapshot(nextSync);
  }

  Future<void> markSyncResolved() async {
    final nextSync = await _remoteSyncGateway.markResolved(_store);
    await _store.updateSyncSnapshot(nextSync);
  }
}

List<TimelineDayGroup> _groupEntriesByDay(List<JournalEntry> entries) {
  final sorted = [...entries]
    ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
  final buckets = <DateTime, List<JournalEntry>>{};
  for (final entry in sorted) {
    final key = DateTime(
      entry.recordedAt.year,
      entry.recordedAt.month,
      entry.recordedAt.day,
    );
    buckets.putIfAbsent(key, () => []).add(entry);
  }
  return buckets.entries
      .map((entry) => TimelineDayGroup(date: entry.key, entries: entry.value))
      .toList()
    ..sort((a, b) => b.date.compareTo(a.date));
}

List<CountrySummary> _buildCountrySummaries(List<JournalEntry> entries) {
  final map = <String, CountrySummary>{};
  for (final entry in entries) {
    final current = map[entry.place.countryCode];
    map[entry.place.countryCode] = CountrySummary(
      countryCode: entry.place.countryCode,
      countryName: entry.place.countryName,
      visitCount: (current?.visitCount ?? 0) + 1,
      cityCount: current?.cityCount ?? 0,
      lastVisitedAt:
          current == null || entry.recordedAt.isAfter(current.lastVisitedAt)
          ? entry.recordedAt
          : current.lastVisitedAt,
    );
  }
  final cityCounts = <String, Set<String>>{};
  for (final entry in entries) {
    cityCounts
        .putIfAbsent(entry.place.countryCode, () => <String>{})
        .add(entry.place.cityKey);
  }
  return map.values
      .map(
        (country) => CountrySummary(
          countryCode: country.countryCode,
          countryName: country.countryName,
          visitCount: country.visitCount,
          cityCount: cityCounts[country.countryCode]?.length ?? 0,
          lastVisitedAt: country.lastVisitedAt,
        ),
      )
      .toList()
    ..sort((a, b) => b.lastVisitedAt.compareTo(a.lastVisitedAt));
}

List<CitySummary> _buildCitySummaries(List<JournalEntry> entries) {
  final map = <String, CitySummary>{};
  for (final entry in entries) {
    final current = map[entry.place.cityKey];
    map[entry.place.cityKey] = CitySummary(
      key: entry.place.cityKey,
      countryCode: entry.place.countryCode,
      countryName: entry.place.countryName,
      cityName: entry.place.cityName,
      visitCount: (current?.visitCount ?? 0) + 1,
      lastVisitedAt:
          current == null || entry.recordedAt.isAfter(current.lastVisitedAt)
          ? entry.recordedAt
          : current.lastVisitedAt,
    );
  }
  return map.values.toList()
    ..sort((a, b) => b.lastVisitedAt.compareTo(a.lastVisitedAt));
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
