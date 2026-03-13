import 'package:core_domain/core_domain.dart';

import '../contracts/photo_ingestion_platform_adapter.dart';
import '../contracts/travel_local_store.dart';
import 'place_inference_service.dart';

class PhotoImportService {
  PhotoImportService({
    required PhotoIngestionPlatformAdapter adapter,
    required TravelLocalStore localStore,
    required PlaceInferenceService placeInferenceService,
  }) : _adapter = adapter,
       _localStore = localStore,
       _placeInferenceService = placeInferenceService;

  final PhotoIngestionPlatformAdapter _adapter;
  final TravelLocalStore _localStore;
  final PlaceInferenceService _placeInferenceService;

  Future<List<PhotoImportDraft>> prepareDrafts({String? tripId}) async {
    final raw = await _adapter.pickPhotos(
      PhotoIngestionRequest(tripId: tripId),
    );
    final trips = _localStore.snapshot.trips;
    return raw
        .map((metadata) {
          final suggestion = _placeInferenceService.infer(
            metadata: metadata,
            trips: trips,
            tripId: tripId,
          );
          return PhotoImportDraft(
            metadata: metadata,
            suggestion: suggestion,
            selectedPlace: suggestion.place,
          );
        })
        .toList(growable: false);
  }

  Future<void> importDrafts({
    required String tripId,
    required List<PhotoImportDraft> drafts,
  }) async {
    if (drafts.isEmpty) return;
    final createdPhotos = <PhotoAsset>[];
    final createdEntries = <JournalEntry>[];
    for (final draft in drafts) {
      final photoId = 'photo-${draft.metadata.id}';
      createdPhotos.add(
        PhotoAsset(
          id: photoId,
          fileName: draft.metadata.fileName,
          previewLabel: draft.metadata.previewLabel,
          format: draft.metadata.format,
          takenAt: draft.metadata.takenAt,
          place: draft.selectedPlace,
          uploadState: UploadState.queued,
          localPath: draft.metadata.sourcePath,
          byteSize: draft.metadata.byteSize,
          storagePath: null,
        ),
      );
      createdEntries.add(
        JournalEntry(
          id: 'entry-photo-${draft.metadata.id}',
          tripId: tripId,
          title: '${draft.selectedPlace.cityName} memory',
          body: 'Imported from ${draft.metadata.displayName}',
          recordedAt: draft.metadata.takenAt,
          place: draft.selectedPlace,
          type: MemoryType.photo,
          photoAssetIds: [photoId],
          hasPendingUpload: true,
        ),
      );
    }
    await _localStore.importPhotos(
      photos: createdPhotos,
      entries: createdEntries,
    );
  }
}
