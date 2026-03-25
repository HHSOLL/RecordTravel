import 'package:core_data/core_data.dart';
import 'package:core_domain/core_domain.dart';

class DemoPhotoIngestionAdapter implements PhotoIngestionPlatformAdapter {
  @override
  Future<List<ExtractedPhotoMetadata>> pickPhotos(
    PhotoIngestionRequest request,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final samples = [
      ExtractedPhotoMetadata(
        id: 'draft-1',
        fileName: 'kyoto-rain.heic',
        displayName: 'Kyoto Rain Walk',
        format: 'HEIC',
        previewLabel: 'KY',
        takenAt: DateTime(2025, 4, 18, 17, 24),
        sourcePath: '/demo/kyoto-rain.heic',
        byteSize: 2400000,
        latitude: 35.0116,
        longitude: 135.7681,
      ),
      ExtractedPhotoMetadata(
        id: 'draft-2',
        fileName: 'jeju-cliff.jpg',
        displayName: 'Jeju Cliff Line',
        format: 'JPEG',
        previewLabel: 'JJ',
        takenAt: DateTime(2026, 1, 21, 15, 12),
        sourcePath: '/demo/jeju-cliff.jpg',
        byteSize: 1800000,
        latitude: 33.4996,
        longitude: 126.5312,
      ),
    ];
    if (request.scope == PhotoIngestionScope.library) {
      return [
        ...samples,
        ExtractedPhotoMetadata(
          id: 'draft-3',
          fileName: 'lisbon-tram.jpg',
          displayName: 'Lisbon Tram Hour',
          format: 'JPEG',
          previewLabel: 'LI',
          takenAt: DateTime(2025, 9, 3, 10, 7),
          sourcePath: '/demo/lisbon-tram.jpg',
          byteSize: 1700000,
          latitude: 38.7223,
          longitude: -9.1393,
        ),
        ExtractedPhotoMetadata(
          id: 'draft-4',
          fileName: 'porto-river.jpg',
          displayName: 'Porto River Blue',
          format: 'JPEG',
          previewLabel: 'PO',
          takenAt: DateTime(2025, 9, 5, 19, 3),
          sourcePath: '/demo/porto-river.jpg',
          byteSize: 1560000,
          latitude: 41.1579,
          longitude: -8.6291,
        ),
        ExtractedPhotoMetadata(
          id: 'draft-5',
          fileName: 'osaka-night.jpg',
          displayName: 'Osaka Night Crossing',
          format: 'JPEG',
          previewLabel: 'OS',
          takenAt: DateTime(2025, 4, 19, 21, 14),
          sourcePath: null,
          byteSize: 1640000,
        ),
      ];
    }
    return samples;
  }
}
