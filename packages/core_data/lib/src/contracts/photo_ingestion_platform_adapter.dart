import 'package:core_domain/core_domain.dart';

abstract class PhotoIngestionPlatformAdapter {
  Future<List<ExtractedPhotoMetadata>> pickPhotos(
    PhotoIngestionRequest request,
  );
}
