import 'package:core_domain/core_domain.dart';

abstract class TravelRemoteDataSource {
  Future<List<TripSummary>> fetchTrips();
  Future<List<JournalEntry>> fetchEntries();
  Future<List<PhotoAsset>> fetchPhotos();

  Future<void> upsertTrip(TripSummary trip);
  Future<void> upsertEntry(JournalEntry entry);
  Future<void> upsertPhoto(PhotoAsset photo);
}
