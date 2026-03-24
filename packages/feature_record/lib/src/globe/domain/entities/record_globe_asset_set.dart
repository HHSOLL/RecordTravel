import 'package:flutter/foundation.dart';

import '../../../globe_engine/record_globe_engine_config.dart';

@immutable
class RecordGlobeAssetSet {
  const RecordGlobeAssetSet({
    required this.rendererKind,
    required this.baseEarthTextureAsset,
    required this.countryIdTextureAsset,
    required this.borderOverlayTextureAsset,
    required this.countryMetadataAsset,
    this.usesHighResolutionTextures = false,
  });

  final RecordGlobeRendererKind rendererKind;
  final String baseEarthTextureAsset;
  final String countryIdTextureAsset;
  final String borderOverlayTextureAsset;
  final String countryMetadataAsset;
  final bool usesHighResolutionTextures;

  RecordGlobeAssetSet copyWith({
    RecordGlobeRendererKind? rendererKind,
    String? baseEarthTextureAsset,
    String? countryIdTextureAsset,
    String? borderOverlayTextureAsset,
    String? countryMetadataAsset,
    bool? usesHighResolutionTextures,
  }) {
    return RecordGlobeAssetSet(
      rendererKind: rendererKind ?? this.rendererKind,
      baseEarthTextureAsset:
          baseEarthTextureAsset ?? this.baseEarthTextureAsset,
      countryIdTextureAsset:
          countryIdTextureAsset ?? this.countryIdTextureAsset,
      borderOverlayTextureAsset:
          borderOverlayTextureAsset ?? this.borderOverlayTextureAsset,
      countryMetadataAsset: countryMetadataAsset ?? this.countryMetadataAsset,
      usesHighResolutionTextures:
          usesHighResolutionTextures ?? this.usesHighResolutionTextures,
    );
  }
}
