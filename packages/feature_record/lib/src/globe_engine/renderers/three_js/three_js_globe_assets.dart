import 'package:flutter/foundation.dart';
import 'package:three_js/three_js.dart' as three;

import '../../../globe/domain/entities/record_globe_asset_set.dart';
import '../../picking/record_country_lookup_grid.dart';

@immutable
class ThreeJsGlobeAssets {
  const ThreeJsGlobeAssets({
    required this.baseTexture,
    required this.borderTexture,
    required this.countryLookupGrid,
  });

  final three.Texture? baseTexture;
  final three.Texture? borderTexture;
  final RecordCountryLookupGrid countryLookupGrid;

  static Future<ThreeJsGlobeAssets> load(RecordGlobeAssetSet assetSet) async {
    final textureLoader = three.TextureLoader(flipY: true);
    final baseTexture = await textureLoader.fromAsset(
      assetSet.baseEarthTextureAsset,
    );
    final borderTexture = await textureLoader.fromAsset(
      assetSet.borderOverlayTextureAsset,
    );

    _configureBaseTexture(baseTexture);
    _configureOverlayTexture(borderTexture);

    final lookupGrid = await RecordCountryLookupGrid.load(
      gridAsset: assetSet.countryLookupGridAsset,
      paletteAsset: assetSet.countryLookupPaletteAsset,
    );

    return ThreeJsGlobeAssets(
      baseTexture: baseTexture,
      borderTexture: borderTexture,
      countryLookupGrid: lookupGrid,
    );
  }

  void dispose() {
    baseTexture?.dispose();
    borderTexture?.dispose();
  }

  static void _configureBaseTexture(three.Texture? texture) {
    if (texture == null) {
      return;
    }
    texture.colorSpace = three.SRGBColorSpace;
    texture.wrapS = three.ClampToEdgeWrapping;
    texture.wrapT = three.ClampToEdgeWrapping;
    texture.magFilter = three.LinearFilter;
    texture.minFilter = three.LinearMipmapLinearFilter;
    texture.generateMipmaps = true;
    texture.premultiplyAlpha = false;
    texture.needsUpdate = true;
  }

  static void _configureOverlayTexture(three.Texture? texture) {
    if (texture == null) {
      return;
    }
    texture.colorSpace = three.SRGBColorSpace;
    texture.wrapS = three.ClampToEdgeWrapping;
    texture.wrapT = three.ClampToEdgeWrapping;
    texture.magFilter = three.LinearFilter;
    texture.minFilter = three.LinearFilter;
    texture.generateMipmaps = false;
    texture.premultiplyAlpha = false;
    texture.needsUpdate = true;
  }
}
