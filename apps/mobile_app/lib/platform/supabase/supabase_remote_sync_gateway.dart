import 'dart:io';

import 'package:core_data/core_data.dart';
import 'package:core_domain/core_domain.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_travel_remote_data_source.dart';

class SupabaseRemoteSyncGateway implements RemoteSyncGateway {
  SupabaseRemoteSyncGateway({
    required SupabaseClient client,
    required SupabaseTravelRemoteDataSource remoteDataSource,
  }) : _client = client,
       _remoteDataSource = remoteDataSource;

  final SupabaseClient _client;
  final SupabaseTravelRemoteDataSource _remoteDataSource;

  @override
  Future<SyncSnapshot> requestSync(TravelLocalStore store) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return store.snapshot.syncSnapshot.copyWith(
        severity: SyncSeverity.attention,
        bannerTitle: 'Sign in required',
        bannerMessage:
            'Remote sync is configured, but you need a Supabase session before uploads and records can sync.',
      );
    }

    try {
      final outbox = await store.getPendingOutboxItems();
      for (final item in outbox) {
        await store.markOutboxItemProcessing(item.id);
        try {
          await _syncOutboxItem(store, item);
          await store.markOutboxItemSynced(item.id);
        } catch (error) {
          await store.markOutboxItemFailed(item.id, error.toString());
        }
      }

      final uploads = await store.getPendingMediaUploads();
      for (final task in uploads) {
        await store.markMediaUploadProcessing(task.id);
        try {
          final file = File(task.localPath);
          final bytes = await file.readAsBytes();
          final remotePath = '${user.id}/${task.storagePath}';
          await _client.storage
              .from(task.storageBucket)
              .uploadBinary(
                remotePath,
                bytes,
                fileOptions: FileOptions(
                  upsert: true,
                  contentType: _contentTypeFor(task.fileName),
                ),
              );

          await store.markMediaUploadUploaded(
            taskId: task.id,
            photoId: task.photoId,
            storagePath: remotePath,
          );

          final uploadedPhoto = store.snapshot.photos.firstWhere(
            (photo) => photo.id == task.photoId,
          );
          await _remoteDataSource.upsertPhoto(uploadedPhoto);
          await store.markOutboxItemSynced(
            '${OutboxOperation.upsertPhotoMetadata.name}:${task.photoId}',
          );
        } catch (error) {
          await store.markMediaUploadFailed(
            taskId: task.id,
            photoId: task.photoId,
            error: error.toString(),
          );
        }
      }

      final remainingOutbox = await store.getPendingOutboxItems();
      final remainingUploads = await store.getPendingMediaUploads();
      return SyncSnapshot(
        severity: remainingOutbox.isEmpty && remainingUploads.isEmpty
            ? SyncSeverity.synced
            : SyncSeverity.pending,
        bannerTitle: remainingOutbox.isEmpty && remainingUploads.isEmpty
            ? 'Supabase sync complete'
            : 'Sync partially complete',
        bannerMessage: remainingOutbox.isEmpty && remainingUploads.isEmpty
            ? 'Trips, memories, media metadata, and uploaded files are now synced.'
            : 'Some local changes are still queued and will retry on the next sync.',
        pendingChanges: remainingOutbox.length,
        pendingUploads: remainingUploads.length,
        lastSyncedAt: DateTime.now(),
      );
    } catch (_) {
      return store.snapshot.syncSnapshot.copyWith(
        severity: SyncSeverity.attention,
        bannerTitle: 'Sync needs attention',
        bannerMessage:
            'Supabase is configured, but the expected tables, storage bucket, or policies are not ready yet.',
      );
    }
  }

  @override
  Future<SyncSnapshot> markResolved(TravelLocalStore store) =>
      requestSync(store);

  Future<void> _syncOutboxItem(
    TravelLocalStore store,
    SyncOutboxItem item,
  ) async {
    switch (item.operation) {
      case OutboxOperation.upsertTrip:
        final trip = store.snapshot.trips.firstWhere(
          (value) => value.id == item.entityId,
        );
        await _remoteDataSource.upsertTrip(trip);
        break;
      case OutboxOperation.upsertJournalEntry:
        final entry = store.snapshot.entries.firstWhere(
          (value) => value.id == item.entityId,
        );
        await _remoteDataSource.upsertEntry(entry);
        break;
      case OutboxOperation.upsertPhotoMetadata:
        final photo = store.snapshot.photos.firstWhere(
          (value) => value.id == item.entityId,
        );
        await _remoteDataSource.upsertPhoto(photo);
        break;
    }
  }

  String _contentTypeFor(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.heic') || lower.endsWith('.heif')) return 'image/heic';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }
}
