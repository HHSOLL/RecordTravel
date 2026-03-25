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
    return prepareDraftsForScope(tripId: tripId);
  }

  Future<List<PhotoImportDraft>> prepareDraftsForScope({
    String? tripId,
    PhotoIngestionScope scope = PhotoIngestionScope.selection,
  }) async {
    final raw = await _adapter.pickPhotos(
      PhotoIngestionRequest(tripId: tripId, scope: scope),
    );
    final snapshot = _localStore.snapshot;
    final trips = snapshot.trips;
    final photos = snapshot.photos;
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
            reviewState: _reviewStateFor(
              metadata: metadata,
              suggestion: suggestion,
              tripId: tripId,
              trips: trips,
              existingPhotos: photos,
            ),
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

  PhotoImportReviewState _reviewStateFor({
    required ExtractedPhotoMetadata metadata,
    required PlaceSuggestion suggestion,
    required String? tripId,
    required List<TripSummary> trips,
    required List<PhotoAsset> existingPhotos,
  }) {
    if (_isLikelyDuplicate(
      metadata: metadata,
      suggestedPlace: suggestion.place,
      existingPhotos: existingPhotos,
    )) {
      return PhotoImportReviewState.duplicateCandidate;
    }

    final hasLocation =
        metadata.latitude != null && metadata.longitude != null;
    if (!hasLocation || suggestion.confidence < 0.7) {
      return PhotoImportReviewState.needsPlaceReview;
    }

    final selectedTrip = _tripForId(trips, tripId);
    if (selectedTrip != null &&
        !_isWithinTripWindow(metadata.takenAt, selectedTrip)) {
      return PhotoImportReviewState.needsTimeReview;
    }

    return PhotoImportReviewState.autoResolved;
  }

  TripSummary? _tripForId(List<TripSummary> trips, String? tripId) {
    if (tripId == null) {
      return null;
    }
    for (final trip in trips) {
      if (trip.id == tripId) {
        return trip;
      }
    }
    return null;
  }

  bool _isWithinTripWindow(DateTime takenAt, TripSummary trip) {
    final windowStart = trip.startDate.subtract(const Duration(hours: 18));
    final windowEnd = trip.endDate.add(const Duration(hours: 18));
    return !takenAt.isBefore(windowStart) && !takenAt.isAfter(windowEnd);
  }

  bool _isLikelyDuplicate({
    required ExtractedPhotoMetadata metadata,
    required PlaceRef suggestedPlace,
    required List<PhotoAsset> existingPhotos,
  }) {
    final normalizedFileName = metadata.fileName.toLowerCase();
    for (final photo in existingPhotos) {
      final sameName = photo.fileName.toLowerCase() == normalizedFileName;
      if (sameName) {
        return true;
      }

      final samePlace = photo.place.cityKey == suggestedPlace.cityKey;
      final timeDelta =
          photo.takenAt.difference(metadata.takenAt).inMinutes.abs();
      final nearTime = timeDelta <= 5;
      final similarSize =
          metadata.byteSize == null ||
          photo.byteSize == null ||
          (photo.byteSize! - metadata.byteSize!).abs() <= 32 * 1024;
      if (samePlace && nearTime && similarSize) {
        return true;
      }
    }
    return false;
  }
}
