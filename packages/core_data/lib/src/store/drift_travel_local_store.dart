import 'package:core_domain/core_domain.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/foundation.dart';

import '../contracts/travel_local_store.dart';
import 'drift_database.dart';
import 'seed_state.dart';

class DriftTravelLocalStore extends ChangeNotifier implements TravelLocalStore {
  DriftTravelLocalStore._(this._database, this._snapshot);

  final TravelAtlasDatabase _database;
  TravelAppState _snapshot;

  static const _uploadBucket = 'travel-media';

  static Future<DriftTravelLocalStore> open() async {
    final database = TravelAtlasDatabase();
    await _seedIfEmpty(database);
    final snapshot = await _loadSnapshot(database);
    return DriftTravelLocalStore._(database, snapshot);
  }

  @override
  TravelAppState get snapshot => _snapshot;

  @override
  Future<void> dispose() async {
    await _database.close();
    super.dispose();
  }

  @override
  Future<void> addJournalEntry(JournalEntry entry) async {
    await _database.transaction(() async {
      await _upsertJournalEntry(entry);
      await _enqueueOutbox(
        SyncOutboxItem(
          id: _outboxId(OutboxOperation.upsertJournalEntry, entry.id),
          operation: OutboxOperation.upsertJournalEntry,
          entityId: entry.id,
          status: QueueDeliveryStatus.pending,
          attemptCount: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      await _refreshTripCounts(entry.tripId);
      await _enqueueTripSync(entry.tripId);
      await _applySnapshotMessage(
        const SyncSnapshot(
          severity: SyncSeverity.pending,
          bannerTitle: 'Saved on this device',
          bannerMessage:
              'Changes are stored locally first so Supabase can be replaced later without product churn.',
          pendingChanges: 0,
          pendingUploads: 0,
        ),
      );
    });
    await _reloadSnapshot();
  }

  @override
  Future<void> importPhotos({
    required List<PhotoAsset> photos,
    required List<JournalEntry> entries,
  }) async {
    if (photos.isEmpty && entries.isEmpty) return;
    await _database.transaction(() async {
      for (final photo in photos) {
        await _upsertPhoto(photo);
        await _enqueueOutbox(
          SyncOutboxItem(
            id: _outboxId(OutboxOperation.upsertPhotoMetadata, photo.id),
            operation: OutboxOperation.upsertPhotoMetadata,
            entityId: photo.id,
            status: QueueDeliveryStatus.pending,
            attemptCount: 0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
        if (photo.localPath != null && photo.localPath!.isNotEmpty) {
          await _enqueueMediaUpload(photo);
        }
      }

      final touchedTripIds = <String>{};
      for (final entry in entries) {
        touchedTripIds.add(entry.tripId);
        await _upsertJournalEntry(entry);
        await _enqueueOutbox(
          SyncOutboxItem(
            id: _outboxId(OutboxOperation.upsertJournalEntry, entry.id),
            operation: OutboxOperation.upsertJournalEntry,
            entityId: entry.id,
            status: QueueDeliveryStatus.pending,
            attemptCount: 0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
      }

      for (final tripId in touchedTripIds) {
        await _refreshTripCounts(tripId);
        await _enqueueTripSync(tripId);
      }

      await _applySnapshotMessage(
        const SyncSnapshot(
          severity: SyncSeverity.pending,
          bannerTitle: 'Saved on this device',
          bannerMessage:
              'Photos and memories are stored locally. Uploads and metadata sync resume when the backend path is available.',
          pendingChanges: 0,
          pendingUploads: 0,
        ),
      );
    });
    await _reloadSnapshot();
  }

  @override
  Future<void> updateSyncSnapshot(SyncSnapshot snapshot) async {
    await _applySnapshotMessage(snapshot);
    await _reloadSnapshot();
  }

  @override
  Future<List<SyncOutboxItem>> getPendingOutboxItems() async {
    final rows =
        await (_database.select(_database.outboxMutations)
              ..where(
                (tbl) => tbl.status.isIn([
                  QueueDeliveryStatus.pending.name,
                  QueueDeliveryStatus.failed.name,
                ]),
              )
              ..orderBy([(tbl) => OrderingTerm.asc(tbl.createdAt)]))
            .get();
    return rows.map(_outboxFromRow).toList(growable: false);
  }

  @override
  Future<List<PendingMediaUploadTask>> getPendingMediaUploads() async {
    final rows =
        await (_database.select(_database.pendingMediaUploads)
              ..where(
                (tbl) => tbl.status.isIn([
                  QueueDeliveryStatus.pending.name,
                  QueueDeliveryStatus.failed.name,
                ]),
              )
              ..orderBy([(tbl) => OrderingTerm.asc(tbl.createdAt)]))
            .get();
    return rows.map(_mediaTaskFromRow).toList(growable: false);
  }

  @override
  Future<void> markOutboxItemProcessing(String id) async {
    await (_database.update(
      _database.outboxMutations,
    )..where((tbl) => tbl.id.equals(id))).write(
      OutboxMutationsCompanion(
        status: Value(QueueDeliveryStatus.processing.name),
        updatedAt: Value(DateTime.now()),
      ),
    );
    await _reloadSnapshot();
  }

  @override
  Future<void> markOutboxItemSynced(String id) async {
    await (_database.delete(
      _database.outboxMutations,
    )..where((tbl) => tbl.id.equals(id))).go();
    await _reloadSnapshot();
  }

  @override
  Future<void> markOutboxItemFailed(String id, String error) async {
    await (_database.update(
      _database.outboxMutations,
    )..where((tbl) => tbl.id.equals(id))).write(
      OutboxMutationsCompanion(
        status: Value(QueueDeliveryStatus.failed.name),
        attemptCount: const Value.absent(),
        lastError: Value(error),
        updatedAt: Value(DateTime.now()),
      ),
    );
    await _incrementOutboxAttempts(id);
    await _applySnapshotMessage(
      const SyncSnapshot(
        severity: SyncSeverity.attention,
        bannerTitle: 'Sync needs attention',
        bannerMessage:
            'Some travel records could not sync yet. Local data is safe and can retry later.',
        pendingChanges: 0,
        pendingUploads: 0,
      ),
    );
    await _reloadSnapshot();
  }

  @override
  Future<void> markMediaUploadProcessing(String id) async {
    await (_database.update(
      _database.pendingMediaUploads,
    )..where((tbl) => tbl.id.equals(id))).write(
      PendingMediaUploadsCompanion(
        status: Value(QueueDeliveryStatus.processing.name),
        updatedAt: Value(DateTime.now()),
      ),
    );
    await _reloadSnapshot();
  }

  @override
  Future<void> markMediaUploadUploaded({
    required String taskId,
    required String photoId,
    required String storagePath,
  }) async {
    await _database.transaction(() async {
      await (_database.delete(
        _database.pendingMediaUploads,
      )..where((tbl) => tbl.id.equals(taskId))).go();

      final photoRow = await (_database.select(
        _database.photoAssets,
      )..where((tbl) => tbl.id.equals(photoId))).getSingle();
      await _upsertPhoto(
        _photoFromRow(
          photoRow,
        ).copyWith(uploadState: UploadState.uploaded, storagePath: storagePath),
      );
      await _enqueueOutbox(
        SyncOutboxItem(
          id: _outboxId(OutboxOperation.upsertPhotoMetadata, photoId),
          operation: OutboxOperation.upsertPhotoMetadata,
          entityId: photoId,
          status: QueueDeliveryStatus.pending,
          attemptCount: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      await _resolvePendingEntryFlagsForPhoto(photoId);
      await _applySnapshotMessage(
        SyncSnapshot(
          severity: SyncSeverity.syncing,
          bannerTitle: 'Upload complete',
          bannerMessage:
              'Media binary uploaded. Metadata sync will finish next.',
          pendingChanges: 0,
          pendingUploads: 0,
          lastSyncedAt: DateTime.now(),
        ),
      );
    });
    await _reloadSnapshot();
  }

  @override
  Future<void> markMediaUploadFailed({
    required String taskId,
    required String photoId,
    required String error,
  }) async {
    await _database.transaction(() async {
      await (_database.update(
        _database.pendingMediaUploads,
      )..where((tbl) => tbl.id.equals(taskId))).write(
        PendingMediaUploadsCompanion(
            status: Value(QueueDeliveryStatus.failed.name),
          lastError: Value(error),
          updatedAt: Value(DateTime.now()),
        ),
      );
      await _incrementMediaAttempts(taskId);

      final photoRow = await (_database.select(
        _database.photoAssets,
      )..where((tbl) => tbl.id.equals(photoId))).getSingle();
      await _upsertPhoto(
        _photoFromRow(photoRow).copyWith(uploadState: UploadState.failed),
      );
      await _applySnapshotMessage(
        const SyncSnapshot(
          severity: SyncSeverity.attention,
          bannerTitle: 'Upload retry needed',
          bannerMessage:
              'A media file could not upload yet. The memory is still saved locally and can retry later.',
          pendingChanges: 0,
          pendingUploads: 0,
        ),
      );
    });
    await _reloadSnapshot();
  }

  Future<void> _upsertJournalEntry(JournalEntry entry) {
    return _database
        .into(_database.journalEntries)
        .insertOnConflictUpdate(
          JournalEntriesCompanion.insert(
            id: entry.id,
            tripId: entry.tripId,
            title: entry.title,
            body: entry.body,
            recordedAt: entry.recordedAt,
            placeCountryCode: entry.place.countryCode,
            placeCountryName: entry.place.countryName,
            placeCityName: entry.place.cityName,
            placeLatitude: Value(entry.place.latitude),
            placeLongitude: Value(entry.place.longitude),
            type: entry.type.name,
            photoAssetIds: entry.photoAssetIds,
            hasPendingUpload: entry.hasPendingUpload,
          ),
        );
  }

  Future<void> _upsertPhoto(PhotoAsset photo) {
    return _database
        .into(_database.photoAssets)
        .insertOnConflictUpdate(
          PhotoAssetsCompanion.insert(
            id: photo.id,
            fileName: photo.fileName,
            previewLabel: photo.previewLabel,
            format: photo.format,
            takenAt: photo.takenAt,
            placeCountryCode: photo.place.countryCode,
            placeCountryName: photo.place.countryName,
            placeCityName: photo.place.cityName,
            placeLatitude: Value(photo.place.latitude),
            placeLongitude: Value(photo.place.longitude),
            uploadState: photo.uploadState.name,
            localPath: Value(photo.localPath),
            storagePath: Value(photo.storagePath),
            byteSize: Value(photo.byteSize),
          ),
        );
  }

  Future<void> _enqueueTripSync(String tripId) async {
    await _enqueueOutbox(
      SyncOutboxItem(
        id: _outboxId(OutboxOperation.upsertTrip, tripId),
        operation: OutboxOperation.upsertTrip,
        entityId: tripId,
        status: QueueDeliveryStatus.pending,
        attemptCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> _enqueueOutbox(SyncOutboxItem item) {
    return _database
        .into(_database.outboxMutations)
        .insertOnConflictUpdate(
          OutboxMutationsCompanion.insert(
            id: item.id,
            operation: item.operation.name,
            entityId: item.entityId,
            status: item.status.name,
            attemptCount: item.attemptCount,
            lastError: Value(item.lastError),
            createdAt: item.createdAt,
            updatedAt: item.updatedAt,
          ),
        );
  }

  Future<void> _enqueueMediaUpload(PhotoAsset photo) {
    final localPath = photo.localPath;
    if (localPath == null || localPath.isEmpty) return Future.value();
    return _database
        .into(_database.pendingMediaUploads)
        .insertOnConflictUpdate(
          PendingMediaUploadsCompanion.insert(
            id: _mediaTaskId(photo.id),
            photoId: photo.id,
            localPath: localPath,
            fileName: photo.fileName,
            storageBucket: _uploadBucket,
            storagePath: _storagePathFor(photo),
            status: QueueDeliveryStatus.pending.name,
            attemptCount: 0,
            lastError: const Value.absent(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
  }

  Future<void> _refreshTripCounts(String tripId) async {
    final trip = await (_database.select(
      _database.trips,
    )..where((tbl) => tbl.id.equals(tripId))).getSingle();
    final entryRows = await (_database.select(
      _database.journalEntries,
    )..where((tbl) => tbl.tripId.equals(tripId))).get();
    final countryCodes = entryRows
        .map((entry) => entry.placeCountryCode)
        .toSet();
    final photoCount = entryRows.fold<int>(
      0,
      (sum, entry) => sum + entry.photoAssetIds.length,
    );

    await _database
        .into(_database.trips)
        .insertOnConflictUpdate(
          TripsCompanion.insert(
            id: trip.id,
            title: trip.title,
            subtitle: trip.subtitle,
            startDate: trip.startDate,
            endDate: trip.endDate,
            heroCountryCode: trip.heroCountryCode,
            heroCountryName: trip.heroCountryName,
            heroCityName: trip.heroCityName,
            heroLatitude: Value(trip.heroLatitude),
            heroLongitude: Value(trip.heroLongitude),
            coverHint: trip.coverHint,
            memoryCount: entryRows.length,
            photoCount: photoCount,
            countryCount: countryCodes.length,
          ),
        );
  }

  Future<void> _resolvePendingEntryFlagsForPhoto(String photoId) async {
    final rows = await (_database.select(
      _database.journalEntries,
    )..where((tbl) => tbl.photoAssetIds.like('%$photoId%'))).get();
    for (final row in rows) {
      final remainingPending = await _countPendingUploadsForPhotoIds(
        row.photoAssetIds,
      );
      if (remainingPending == 0 && row.hasPendingUpload) {
        await _database
            .into(_database.journalEntries)
            .insertOnConflictUpdate(
              JournalEntriesCompanion.insert(
                id: row.id,
                tripId: row.tripId,
                title: row.title,
                body: row.body,
                recordedAt: row.recordedAt,
                placeCountryCode: row.placeCountryCode,
                placeCountryName: row.placeCountryName,
                placeCityName: row.placeCityName,
                placeLatitude: Value(row.placeLatitude),
                placeLongitude: Value(row.placeLongitude),
                type: row.type,
                photoAssetIds: row.photoAssetIds,
                hasPendingUpload: false,
              ),
            );
        await _enqueueOutbox(
          SyncOutboxItem(
            id: _outboxId(OutboxOperation.upsertJournalEntry, row.id),
            operation: OutboxOperation.upsertJournalEntry,
            entityId: row.id,
            status: QueueDeliveryStatus.pending,
            attemptCount: 0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
      }
    }
  }

  Future<int> _countPendingUploadsForPhotoIds(List<String> photoIds) async {
    if (photoIds.isEmpty) return 0;
    final expression = _database.pendingMediaUploads.photoId.isIn(photoIds);
    final rows = await (_database.select(
      _database.pendingMediaUploads,
    )..where((tbl) => expression)).get();
    return rows.length;
  }

  Future<void> _applySnapshotMessage(SyncSnapshot snapshot) async {
    final outboxCount = await _pendingOutboxCount();
    final uploadCount = await _pendingUploadCount();
    await _database
        .into(_database.syncStates)
        .insertOnConflictUpdate(
          SyncStatesCompanion.insert(
            id: const Value(1),
            severity: snapshot.severity.name,
            bannerTitle: snapshot.bannerTitle,
            bannerMessage: snapshot.bannerMessage,
            pendingChanges: outboxCount,
            pendingUploads: uploadCount,
            lastSyncedAt: Value(snapshot.lastSyncedAt),
          ),
        );
  }

  Future<int> _pendingOutboxCount() async {
    final countExpression = _database.outboxMutations.id.count();
    final query = _database.selectOnly(_database.outboxMutations)
      ..addColumns([countExpression]);
    final row = await query.getSingle();
    return row.read(countExpression) ?? 0;
  }

  Future<int> _pendingUploadCount() async {
    final countExpression = _database.pendingMediaUploads.id.count();
    final query = _database.selectOnly(_database.pendingMediaUploads)
      ..addColumns([countExpression]);
    final row = await query.getSingle();
    return row.read(countExpression) ?? 0;
  }

  Future<void> _incrementOutboxAttempts(String id) {
    return _database.customStatement(
      'update outbox_mutations set attempt_count = attempt_count + 1 where id = ?',
      [id],
    );
  }

  Future<void> _incrementMediaAttempts(String id) {
    return _database.customStatement(
      'update pending_media_uploads set attempt_count = attempt_count + 1 where id = ?',
      [id],
    );
  }

  Future<void> _reloadSnapshot() async {
    _snapshot = await _loadSnapshot(_database);
    notifyListeners();
  }

  static String _outboxId(OutboxOperation operation, String entityId) =>
      '${operation.name}:$entityId';

  static String _mediaTaskId(String photoId) => 'media-upload:$photoId';

  static String _storagePathFor(PhotoAsset photo) =>
      '${photo.takenAt.year}/${photo.id}/${photo.fileName}';
}

Future<void> _seedIfEmpty(TravelAtlasDatabase database) async {
  final existingTrips = await database.select(database.trips).get();
  if (existingTrips.isNotEmpty) return;

  final seed = buildSeedTravelState();
  await database.transaction(() async {
    for (final trip in seed.trips) {
      await database
          .into(database.trips)
          .insert(
            TripsCompanion.insert(
              id: trip.id,
              title: trip.title,
              subtitle: trip.subtitle,
              startDate: trip.startDate,
              endDate: trip.endDate,
              heroCountryCode: trip.heroPlace.countryCode,
              heroCountryName: trip.heroPlace.countryName,
              heroCityName: trip.heroPlace.cityName,
              heroLatitude: Value(trip.heroPlace.latitude),
              heroLongitude: Value(trip.heroPlace.longitude),
              coverHint: trip.coverHint,
              memoryCount: trip.memoryCount,
              photoCount: trip.photoCount,
              countryCount: trip.countryCount,
            ),
          );
    }

    for (final entry in seed.entries) {
      await database
          .into(database.journalEntries)
          .insert(
            JournalEntriesCompanion.insert(
              id: entry.id,
              tripId: entry.tripId,
              title: entry.title,
              body: entry.body,
              recordedAt: entry.recordedAt,
              placeCountryCode: entry.place.countryCode,
              placeCountryName: entry.place.countryName,
              placeCityName: entry.place.cityName,
              placeLatitude: Value(entry.place.latitude),
              placeLongitude: Value(entry.place.longitude),
              type: entry.type.name,
              photoAssetIds: entry.photoAssetIds,
              hasPendingUpload: entry.hasPendingUpload,
            ),
          );
      if (entry.hasPendingUpload) {
        await database
            .into(database.outboxMutations)
            .insert(
              OutboxMutationsCompanion.insert(
                id: DriftTravelLocalStore._outboxId(
                  OutboxOperation.upsertJournalEntry,
                  entry.id,
                ),
                operation: OutboxOperation.upsertJournalEntry.name,
                entityId: entry.id,
                status: QueueDeliveryStatus.pending.name,
                attemptCount: 0,
                lastError: const Value.absent(),
                createdAt: entry.recordedAt,
                updatedAt: entry.recordedAt,
              ),
            );
      }
    }

    for (final photo in seed.photos) {
      await database
          .into(database.photoAssets)
          .insert(
            PhotoAssetsCompanion.insert(
              id: photo.id,
              fileName: photo.fileName,
              previewLabel: photo.previewLabel,
              format: photo.format,
              takenAt: photo.takenAt,
              placeCountryCode: photo.place.countryCode,
              placeCountryName: photo.place.countryName,
              placeCityName: photo.place.cityName,
              placeLatitude: Value(photo.place.latitude),
              placeLongitude: Value(photo.place.longitude),
              uploadState: photo.uploadState.name,
              localPath: Value(photo.localPath),
              storagePath: Value(photo.storagePath),
              byteSize: Value(photo.byteSize),
            ),
          );
      await database
          .into(database.outboxMutations)
          .insert(
            OutboxMutationsCompanion.insert(
              id: DriftTravelLocalStore._outboxId(
                OutboxOperation.upsertPhotoMetadata,
                photo.id,
              ),
              operation: OutboxOperation.upsertPhotoMetadata.name,
              entityId: photo.id,
              status: QueueDeliveryStatus.pending.name,
              attemptCount: 0,
              lastError: const Value.absent(),
              createdAt: photo.takenAt,
              updatedAt: photo.takenAt,
            ),
          );
      if (photo.localPath != null && photo.localPath!.isNotEmpty) {
        await database
            .into(database.pendingMediaUploads)
            .insert(
              PendingMediaUploadsCompanion.insert(
                id: DriftTravelLocalStore._mediaTaskId(photo.id),
                photoId: photo.id,
                localPath: photo.localPath!,
                fileName: photo.fileName,
                storageBucket: DriftTravelLocalStore._uploadBucket,
                storagePath: DriftTravelLocalStore._storagePathFor(photo),
                status: QueueDeliveryStatus.pending.name,
                attemptCount: 0,
                lastError: const Value.absent(),
                createdAt: photo.takenAt,
                updatedAt: photo.takenAt,
              ),
            );
      }
    }

    final seededTripIds = seed.entries.map((entry) => entry.tripId).toSet();
    for (final tripId in seededTripIds) {
      await database
          .into(database.outboxMutations)
          .insertOnConflictUpdate(
            OutboxMutationsCompanion.insert(
              id: DriftTravelLocalStore._outboxId(
                OutboxOperation.upsertTrip,
                tripId,
              ),
              operation: OutboxOperation.upsertTrip.name,
              entityId: tripId,
              status: QueueDeliveryStatus.pending.name,
              attemptCount: 0,
              lastError: const Value.absent(),
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );
    }

    await database
        .into(database.syncStates)
        .insert(
          SyncStatesCompanion.insert(
            id: const Value(1),
            severity: seed.syncSnapshot.severity.name,
            bannerTitle: seed.syncSnapshot.bannerTitle,
            bannerMessage: seed.syncSnapshot.bannerMessage,
            pendingChanges: 0,
            pendingUploads: 0,
            lastSyncedAt: Value(seed.syncSnapshot.lastSyncedAt),
          ),
        );
  });

  final outboxCountExpression = database.outboxMutations.id.count();
  final uploadCountExpression = database.pendingMediaUploads.id.count();
  final outboxCount = await (database.selectOnly(
    database.outboxMutations,
  )..addColumns([outboxCountExpression])).getSingle();
  final uploadCount = await (database.selectOnly(
    database.pendingMediaUploads,
  )..addColumns([uploadCountExpression])).getSingle();

  await database
      .into(database.syncStates)
      .insertOnConflictUpdate(
        SyncStatesCompanion.insert(
          id: const Value(1),
          severity: seed.syncSnapshot.severity.name,
          bannerTitle: seed.syncSnapshot.bannerTitle,
          bannerMessage: seed.syncSnapshot.bannerMessage,
          pendingChanges: outboxCount.read(outboxCountExpression) ?? 0,
          pendingUploads: uploadCount.read(uploadCountExpression) ?? 0,
          lastSyncedAt: Value(seed.syncSnapshot.lastSyncedAt),
        ),
      );
}

Future<TravelAppState> _loadSnapshot(TravelAtlasDatabase database) async {
  final tripRows = await database.select(database.trips).get();
  final entryRows = await database.select(database.journalEntries).get();
  final photoRows = await database.select(database.photoAssets).get();
  final syncRow = await (database.select(
    database.syncStates,
  )..where((tbl) => tbl.id.equals(1))).getSingle();

  return TravelAppState(
    trips: tripRows.map(_tripFromRow).toList(growable: false),
    entries: entryRows.map(_entryFromRow).toList(growable: false),
    photos: photoRows.map(_photoFromRow).toList(growable: false),
    syncSnapshot: _syncFromRow(syncRow),
  );
}

TripSummary _tripFromRow(DbTrip row) {
  return TripSummary(
    id: row.id,
    title: row.title,
    subtitle: row.subtitle,
    startDate: row.startDate,
    endDate: row.endDate,
    heroPlace: placeFromDb(
      countryCode: row.heroCountryCode,
      countryName: row.heroCountryName,
      cityName: row.heroCityName,
      latitude: row.heroLatitude,
      longitude: row.heroLongitude,
    ),
    coverHint: row.coverHint,
    memoryCount: row.memoryCount,
    photoCount: row.photoCount,
    countryCount: row.countryCount,
  );
}

JournalEntry _entryFromRow(DbJournalEntry row) {
  return JournalEntry(
    id: row.id,
    tripId: row.tripId,
    title: row.title,
    body: row.body,
    recordedAt: row.recordedAt,
    place: placeFromDb(
      countryCode: row.placeCountryCode,
      countryName: row.placeCountryName,
      cityName: row.placeCityName,
      latitude: row.placeLatitude,
      longitude: row.placeLongitude,
    ),
    type: row.type == MemoryType.photo.name
        ? MemoryType.photo
        : MemoryType.note,
    photoAssetIds: row.photoAssetIds,
    hasPendingUpload: row.hasPendingUpload,
  );
}

PhotoAsset _photoFromRow(DbPhotoAsset row) {
  return PhotoAsset(
    id: row.id,
    fileName: row.fileName,
    previewLabel: row.previewLabel,
    format: row.format,
    takenAt: row.takenAt,
    place: placeFromDb(
      countryCode: row.placeCountryCode,
      countryName: row.placeCountryName,
      cityName: row.placeCityName,
      latitude: row.placeLatitude,
      longitude: row.placeLongitude,
    ),
    uploadState: UploadState.values.firstWhere(
      (item) => item.name == row.uploadState,
      orElse: () => UploadState.localOnly,
    ),
    localPath: row.localPath,
    byteSize: row.byteSize,
    storagePath: row.storagePath,
  );
}

SyncSnapshot _syncFromRow(DbSyncState row) {
  return SyncSnapshot(
    severity: SyncSeverity.values.firstWhere(
      (item) => item.name == row.severity,
      orElse: () => SyncSeverity.pending,
    ),
    bannerTitle: row.bannerTitle,
    bannerMessage: row.bannerMessage,
    pendingChanges: row.pendingChanges,
    pendingUploads: row.pendingUploads,
    lastSyncedAt: row.lastSyncedAt,
  );
}

SyncOutboxItem _outboxFromRow(DbOutboxMutation row) {
  return SyncOutboxItem(
    id: row.id,
    operation: OutboxOperation.values.firstWhere(
      (item) => item.name == row.operation,
      orElse: () => OutboxOperation.upsertJournalEntry,
    ),
    entityId: row.entityId,
    status: QueueDeliveryStatus.values.firstWhere(
      (item) => item.name == row.status,
      orElse: () => QueueDeliveryStatus.pending,
    ),
    attemptCount: row.attemptCount,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
    lastError: row.lastError,
  );
}

PendingMediaUploadTask _mediaTaskFromRow(DbPendingMediaUpload row) {
  return PendingMediaUploadTask(
    id: row.id,
    photoId: row.photoId,
    localPath: row.localPath,
    fileName: row.fileName,
    storageBucket: row.storageBucket,
    storagePath: row.storagePath,
    status: QueueDeliveryStatus.values.firstWhere(
      (item) => item.name == row.status,
      orElse: () => QueueDeliveryStatus.pending,
    ),
    attemptCount: row.attemptCount,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
    lastError: row.lastError,
  );
}
