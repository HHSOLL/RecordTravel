import 'package:flutter/foundation.dart';

@immutable
class RecordGlobeAssetSet {
  const RecordGlobeAssetSet({
    required this.baseEarthTextureAsset,
    required this.borderOverlayTextureAsset,
    required this.countryLookupGridAsset,
    required this.countryLookupPaletteAsset,
  });

  final String baseEarthTextureAsset;
  final String borderOverlayTextureAsset;
  final String countryLookupGridAsset;
  final String countryLookupPaletteAsset;

  RecordGlobeAssetSet copyWith({
    String? baseEarthTextureAsset,
    String? borderOverlayTextureAsset,
    String? countryLookupGridAsset,
    String? countryLookupPaletteAsset,
  }) {
    return RecordGlobeAssetSet(
      baseEarthTextureAsset:
          baseEarthTextureAsset ?? this.baseEarthTextureAsset,
      borderOverlayTextureAsset:
          borderOverlayTextureAsset ?? this.borderOverlayTextureAsset,
      countryLookupGridAsset:
          countryLookupGridAsset ?? this.countryLookupGridAsset,
      countryLookupPaletteAsset:
          countryLookupPaletteAsset ?? this.countryLookupPaletteAsset,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is RecordGlobeAssetSet &&
            other.baseEarthTextureAsset == baseEarthTextureAsset &&
            other.borderOverlayTextureAsset == borderOverlayTextureAsset &&
            other.countryLookupGridAsset == countryLookupGridAsset &&
            other.countryLookupPaletteAsset == countryLookupPaletteAsset);
  }

  @override
  int get hashCode => Object.hash(
        baseEarthTextureAsset,
        borderOverlayTextureAsset,
        countryLookupGridAsset,
        countryLookupPaletteAsset,
      );
}
