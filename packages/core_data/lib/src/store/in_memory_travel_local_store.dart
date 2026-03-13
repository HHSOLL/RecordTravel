import 'package:core_domain/core_domain.dart';

import '../contracts/travel_local_store.dart';
import 'seed_state.dart';

class InMemoryTravelLocalStore extends TravelLocalStore {
  InMemoryTravelLocalStore.seeded() : _snapshot = buildSeedTravelState() {
    for (final entry in _snapshot.entries.where(
      (item) => item.hasPendingUpload,
    )) {
      _outbox[_outboxId(
        OutboxOperation.upsertJournalEntry,
        entry.id,
      )] = SyncOutboxItem(
        id: _outboxId(OutboxOperation.upsertJournalEntry, entry.id),
        operation: OutboxOperation.upsertJournalEntry,
        entityId: entry.id,
        status: QueueDeliveryStatus.pending,
        attemptCount: 0,
        createdAt: entry.recordedAt,
        updatedAt: entry.recordedAt,
      );
    }
    for (final photo in _snapshot.photos) {
      _outbox[_outboxId(
        OutboxOperation.upsertPhotoMetadata,
        photo.id,
      )] = SyncOutboxItem(
        id: _outboxId(OutboxOperation.upsertPhotoMetadata, photo.id),
        operation: OutboxOperation.upsertPhotoMetadata,
        entityId: photo.id,
        status: QueueDeliveryStatus.pending,
        attemptCount: 0,
        createdAt: photo.takenAt,
        updatedAt: photo.takenAt,
      );
      if (photo.localPath != null && photo.localPath!.isNotEmpty) {
        _uploads[_mediaTaskId(photo.id)] = PendingMediaUploadTask(
          id: _mediaTaskId(photo.id),
          photoId: photo.id,
          localPath: photo.localPath!,
          fileName: photo.fileName,
          storageBucket: 'travel-media',
          storagePath: '${photo.takenAt.year}/${photo.id}/${photo.fileName}',
          status: QueueDeliveryStatus.pending,
          attemptCount: 0,
          createdAt: photo.takenAt,
          updatedAt: photo.takenAt,
        );
      }
    }
    _recomputeSyncCounts();
  }

  TravelAppState _snapshot;
  final Map<String, SyncOutboxItem> _outbox = {};
  final Map<String, PendingMediaUploadTask> _uploads = {};

  @override
  TravelAppState get snapshot => _snapshot;

  @override
  Future<void> addJournalEntry(JournalEntry entry) async {
    final nextEntries = [..._snapshot.entries, entry];
    _snapshot = _snapshot.copyWith(
      entries: nextEntries,
      trips: _recalculateTrips(_snapshot.trips, nextEntries),
    );
    _outbox[_outboxId(
      OutboxOperation.upsertJournalEntry,
      entry.id,
    )] = SyncOutboxItem(
      id: _outboxId(OutboxOperation.upsertJournalEntry, entry.id),
      operation: OutboxOperation.upsertJournalEntry,
      entityId: entry.id,
      status: QueueDeliveryStatus.pending,
      attemptCount: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _outbox[_outboxId(
      OutboxOperation.upsertTrip,
      entry.tripId,
    )] = SyncOutboxItem(
      id: _outboxId(OutboxOperation.upsertTrip, entry.tripId),
      operation: OutboxOperation.upsertTrip,
      entityId: entry.tripId,
      status: QueueDeliveryStatus.pending,
      attemptCount: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _setBanner(
      const SyncSnapshot(
        severity: SyncSeverity.pending,
        bannerTitle: 'Saved on this device',
        bannerMessage:
            'Changes are stored locally first so Supabase can be replaced later without product churn.',
        pendingChanges: 0,
        pendingUploads: 0,
      ),
    );
    notifyListeners();
  }

  @override
  Future<void> importPhotos({
    required List<PhotoAsset> photos,
    required List<JournalEntry> entries,
  }) async {
    final nextEntries = [..._snapshot.entries, ...entries];
    final nextPhotos = [..._snapshot.photos, ...photos];
    _snapshot = _snapshot.copyWith(
      entries: nextEntries,
      photos: nextPhotos,
      trips: _recalculateTrips(_snapshot.trips, nextEntries),
    );

    for (final entry in entries) {
      _outbox[_outboxId(
        OutboxOperation.upsertJournalEntry,
        entry.id,
      )] = SyncOutboxItem(
        id: _outboxId(OutboxOperation.upsertJournalEntry, entry.id),
        operation: OutboxOperation.upsertJournalEntry,
        entityId: entry.id,
        status: QueueDeliveryStatus.pending,
        attemptCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _outbox[_outboxId(
        OutboxOperation.upsertTrip,
        entry.tripId,
      )] = SyncOutboxItem(
        id: _outboxId(OutboxOperation.upsertTrip, entry.tripId),
        operation: OutboxOperation.upsertTrip,
        entityId: entry.tripId,
        status: QueueDeliveryStatus.pending,
        attemptCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    for (final photo in photos) {
      _outbox[_outboxId(
        OutboxOperation.upsertPhotoMetadata,
        photo.id,
      )] = SyncOutboxItem(
        id: _outboxId(OutboxOperation.upsertPhotoMetadata, photo.id),
        operation: OutboxOperation.upsertPhotoMetadata,
        entityId: photo.id,
        status: QueueDeliveryStatus.pending,
        attemptCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      if (photo.localPath != null && photo.localPath!.isNotEmpty) {
        _uploads[_mediaTaskId(photo.id)] = PendingMediaUploadTask(
          id: _mediaTaskId(photo.id),
          photoId: photo.id,
          localPath: photo.localPath!,
          fileName: photo.fileName,
          storageBucket: 'travel-media',
          storagePath: '${photo.takenAt.year}/${photo.id}/${photo.fileName}',
          status: QueueDeliveryStatus.pending,
          attemptCount: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }
    }

    _setBanner(
      const SyncSnapshot(
        severity: SyncSeverity.pending,
        bannerTitle: 'Saved on this device',
        bannerMessage:
            'Photos and memories are stored locally. Uploads and metadata sync resume when the backend path is available.',
        pendingChanges: 0,
        pendingUploads: 0,
      ),
    );
    notifyListeners();
  }

  @override
  Future<void> updateSyncSnapshot(SyncSnapshot snapshot) async {
    _setBanner(snapshot);
    notifyListeners();
  }

  @override
  Future<List<SyncOutboxItem>> getPendingOutboxItems() async =>
      _outbox.values.toList(growable: false);

  @override
  Future<List<PendingMediaUploadTask>> getPendingMediaUploads() async =>
      _uploads.values.toList(growable: false);

  @override
  Future<void> markOutboxItemProcessing(String id) async {
    final item = _outbox[id];
    if (item == null) return;
    _outbox[id] = SyncOutboxItem(
      id: item.id,
      operation: item.operation,
      entityId: item.entityId,
      status: QueueDeliveryStatus.processing,
      attemptCount: item.attemptCount,
      createdAt: item.createdAt,
      updatedAt: DateTime.now(),
      lastError: item.lastError,
    );
    _recomputeSyncCounts();
    notifyListeners();
  }

  @override
  Future<void> markOutboxItemSynced(String id) async {
    _outbox.remove(id);
    _recomputeSyncCounts();
    notifyListeners();
  }

  @override
  Future<void> markOutboxItemFailed(String id, String error) async {
    final item = _outbox[id];
    if (item == null) return;
    _outbox[id] = SyncOutboxItem(
      id: item.id,
      operation: item.operation,
      entityId: item.entityId,
      status: QueueDeliveryStatus.failed,
      attemptCount: item.attemptCount + 1,
      createdAt: item.createdAt,
      updatedAt: DateTime.now(),
      lastError: error,
    );
    _setBanner(
      const SyncSnapshot(
        severity: SyncSeverity.attention,
        bannerTitle: 'Sync needs attention',
        bannerMessage:
            'Some travel records could not sync yet. Local data is safe and can retry later.',
        pendingChanges: 0,
        pendingUploads: 0,
      ),
    );
    notifyListeners();
  }

  @override
  Future<void> markMediaUploadProcessing(String id) async {
    final item = _uploads[id];
    if (item == null) return;
    _uploads[id] = PendingMediaUploadTask(
      id: item.id,
      photoId: item.photoId,
      localPath: item.localPath,
      fileName: item.fileName,
      storageBucket: item.storageBucket,
      storagePath: item.storagePath,
      status: QueueDeliveryStatus.processing,
      attemptCount: item.attemptCount,
      createdAt: item.createdAt,
      updatedAt: DateTime.now(),
      lastError: item.lastError,
    );
    _recomputeSyncCounts();
    notifyListeners();
  }

  @override
  Future<void> markMediaUploadUploaded({
    required String taskId,
    required String photoId,
    required String storagePath,
  }) async {
    _uploads.remove(taskId);
    _snapshot = _snapshot.copyWith(
      photos: _snapshot.photos
          .map(
            (photo) => photo.id == photoId
                ? photo.copyWith(
                    uploadState: UploadState.uploaded,
                    storagePath: storagePath,
                  )
                : photo,
          )
          .toList(growable: false),
      entries: _snapshot.entries
          .map(
            (entry) => entry.photoAssetIds.contains(photoId)
                ? JournalEntry(
                    id: entry.id,
                    tripId: entry.tripId,
                    title: entry.title,
                    body: entry.body,
                    recordedAt: entry.recordedAt,
                    place: entry.place,
                    type: entry.type,
                    photoAssetIds: entry.photoAssetIds,
                    hasPendingUpload: false,
                  )
                : entry,
          )
          .toList(growable: false),
    );
    _outbox[_outboxId(
      OutboxOperation.upsertPhotoMetadata,
      photoId,
    )] = SyncOutboxItem(
      id: _outboxId(OutboxOperation.upsertPhotoMetadata, photoId),
      operation: OutboxOperation.upsertPhotoMetadata,
      entityId: photoId,
      status: QueueDeliveryStatus.pending,
      attemptCount: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _setBanner(
      SyncSnapshot(
        severity: SyncSeverity.syncing,
        bannerTitle: 'Upload complete',
        bannerMessage: 'Media binary uploaded. Metadata sync will finish next.',
        pendingChanges: 0,
        pendingUploads: 0,
        lastSyncedAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  @override
  Future<void> markMediaUploadFailed({
    required String taskId,
    required String photoId,
    required String error,
  }) async {
    final item = _uploads[taskId];
    if (item != null) {
      _uploads[taskId] = PendingMediaUploadTask(
        id: item.id,
        photoId: item.photoId,
        localPath: item.localPath,
        fileName: item.fileName,
        storageBucket: item.storageBucket,
        storagePath: item.storagePath,
        status: QueueDeliveryStatus.failed,
        attemptCount: item.attemptCount + 1,
        createdAt: item.createdAt,
        updatedAt: DateTime.now(),
        lastError: error,
      );
    }
    _snapshot = _snapshot.copyWith(
      photos: _snapshot.photos
          .map(
            (photo) => photo.id == photoId
                ? photo.copyWith(uploadState: UploadState.failed)
                : photo,
          )
          .toList(growable: false),
    );
    _setBanner(
      const SyncSnapshot(
        severity: SyncSeverity.attention,
        bannerTitle: 'Upload retry needed',
        bannerMessage:
            'A media file could not upload yet. The memory is still saved locally and can retry later.',
        pendingChanges: 0,
        pendingUploads: 0,
      ),
    );
    notifyListeners();
  }

  void _setBanner(SyncSnapshot snapshot) {
    _snapshot = _snapshot.copyWith(
      syncSnapshot: snapshot.copyWith(
        pendingChanges: _outbox.length,
        pendingUploads: _uploads.length,
      ),
    );
  }

  void _recomputeSyncCounts() {
    _snapshot = _snapshot.copyWith(
      syncSnapshot: _snapshot.syncSnapshot.copyWith(
        pendingChanges: _outbox.length,
        pendingUploads: _uploads.length,
      ),
    );
  }
}

List<TripSummary> _recalculateTrips(
  List<TripSummary> trips,
  List<JournalEntry> entries,
) {
  return trips.map((trip) {
    final tripEntries = entries
        .where((entry) => entry.tripId == trip.id)
        .toList();
    final countries = tripEntries
        .map((entry) => entry.place.countryCode)
        .toSet();
    final photoCount = tripEntries.fold<int>(
      0,
      (sum, entry) => sum + entry.photoAssetIds.length,
    );
    return trip.copyWith(
      memoryCount: tripEntries.length,
      photoCount: photoCount,
      countryCount: countries.length,
    );
  }).toList();
}

String _outboxId(OutboxOperation operation, String entityId) =>
    '${operation.name}:$entityId';

String _mediaTaskId(String photoId) => 'media-upload:$photoId';
