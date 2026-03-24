import 'package:flutter/foundation.dart';

@immutable
class RecordGlobeAssetSet {
  const RecordGlobeAssetSet({
    required this.baseEarthTextureAsset,
    required this.borderOverlayTextureAsset,
  });

  final String baseEarthTextureAsset;
  final String borderOverlayTextureAsset;

  RecordGlobeAssetSet copyWith({
    String? baseEarthTextureAsset,
    String? borderOverlayTextureAsset,
  }) {
    return RecordGlobeAssetSet(
      baseEarthTextureAsset:
          baseEarthTextureAsset ?? this.baseEarthTextureAsset,
      borderOverlayTextureAsset:
          borderOverlayTextureAsset ?? this.borderOverlayTextureAsset,
    );
  }
}
