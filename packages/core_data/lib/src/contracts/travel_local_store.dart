import 'package:flutter/foundation.dart';
import 'package:core_domain/core_domain.dart';

abstract class TravelLocalStore extends ChangeNotifier {
  TravelAppState get snapshot;

  Future<void> upsertTrip(TripSummary trip);
  Future<void> addJournalEntry(JournalEntry entry);
  Future<void> importPhotos({
    required List<PhotoAsset> photos,
    required List<JournalEntry> entries,
  });
  Future<void> updateSyncSnapshot(SyncSnapshot snapshot);

  Future<List<SyncOutboxItem>> getPendingOutboxItems();
  Future<List<PendingMediaUploadTask>> getPendingMediaUploads();
  Future<void> markOutboxItemProcessing(String id);
  Future<void> markOutboxItemSynced(String id);
  Future<void> markOutboxItemFailed(String id, String error);
  Future<void> markMediaUploadProcessing(String id);
  Future<void> markMediaUploadUploaded({
    required String taskId,
    required String photoId,
    required String storagePath,
  });
  Future<void> markMediaUploadFailed({
    required String taskId,
    required String photoId,
    required String error,
  });
}
