import 'package:core_domain/core_domain.dart';

import '../contracts/travel_remote_data_source.dart';

class NoopTravelRemoteDataSource implements TravelRemoteDataSource {
  @override
  Future<List<TripSummary>> fetchTrips() async => const [];

  @override
  Future<List<JournalEntry>> fetchEntries() async => const [];

  @override
  Future<List<PhotoAsset>> fetchPhotos() async => const [];

  @override
  Future<void> upsertEntry(JournalEntry entry) async {}

  @override
  Future<void> upsertPhoto(PhotoAsset photo) async {}

  @override
  Future<void> upsertTrip(TripSummary trip) async {}
}
