import 'package:core_data/core_data.dart';
import 'package:core_domain/core_domain.dart';

class DemoPhotoIngestionAdapter implements PhotoIngestionPlatformAdapter {
  @override
  Future<List<ExtractedPhotoMetadata>> pickPhotos(
    PhotoIngestionRequest request,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return [
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
  }
}
