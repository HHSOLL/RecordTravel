import 'package:core_data/core_data.dart';
import 'package:core_domain/core_domain.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubPhotoIngestionAdapter implements PhotoIngestionPlatformAdapter {
  const _StubPhotoIngestionAdapter(this._drafts);

  final List<ExtractedPhotoMetadata> _drafts;

  @override
  Future<List<ExtractedPhotoMetadata>> pickPhotos(
    PhotoIngestionRequest request,
  ) async => _drafts;
}

void main() {
  test('photo import drafts classify ready, place review, time review, and duplicates', () async {
    final service = PhotoImportService(
      adapter: _StubPhotoIngestionAdapter([
        ExtractedPhotoMetadata(
          id: 'ready-photo',
          fileName: 'kyoto.heic',
          displayName: 'Kyoto Walk',
          format: 'HEIC',
          previewLabel: 'KY',
          takenAt: DateTime(2025, 4, 18, 17, 24),
          sourcePath: '/tmp/kyoto.heic',
          byteSize: 2400000,
          latitude: 35.0116,
          longitude: 135.7681,
        ),
        ExtractedPhotoMetadata(
          id: 'review-photo',
          fileName: 'unknown.jpg',
          displayName: 'Unknown Place',
          format: 'JPEG',
          previewLabel: 'UN',
          takenAt: DateTime(2025, 4, 19, 10, 30),
          sourcePath: null,
          byteSize: 1800000,
        ),
        ExtractedPhotoMetadata(
          id: 'time-review-photo',
          fileName: 'late-kyoto.jpg',
          displayName: 'Late Kyoto',
          format: 'JPEG',
          previewLabel: 'LK',
          takenAt: DateTime(2026, 7, 1, 10, 30),
          sourcePath: '/tmp/late-kyoto.jpg',
          byteSize: 1820000,
          latitude: 35.0116,
          longitude: 135.7681,
        ),
        ExtractedPhotoMetadata(
          id: 'duplicate-photo',
          fileName: 'lisbon-tram.heic',
          displayName: 'Lisbon Tram',
          format: 'HEIC',
          previewLabel: 'LT',
          takenAt: DateTime(2025, 9, 7, 19, 41),
          sourcePath: '/tmp/lisbon-tram.heic',
          byteSize: 1800000,
          latitude: 38.7223,
          longitude: -9.1393,
        ),
      ]),
      localStore: InMemoryTravelLocalStore.seeded(),
      placeInferenceService: const PlaceInferenceService(),
    );

    final drafts = await service.prepareDraftsForScope(
      tripId: 'trip-seoul-kyoto',
      scope: PhotoIngestionScope.library,
    );

    expect(drafts, hasLength(4));
    expect(drafts.first.reviewState, PhotoImportReviewState.autoResolved);
    expect(drafts[1].reviewState, PhotoImportReviewState.needsPlaceReview);
    expect(drafts[2].reviewState, PhotoImportReviewState.needsTimeReview);
    expect(drafts[3].reviewState, PhotoImportReviewState.duplicateCandidate);
  });
}
