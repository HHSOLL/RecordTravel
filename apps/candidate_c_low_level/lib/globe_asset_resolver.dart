import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:globe_poc_core/globe_poc_core.dart';

import 'runtime_asset_fetcher.dart';

class GlobeResolvedAssets {
  const GlobeResolvedAssets({
    required this.textureBundle,
    required this.bordersRgba,
    required this.starfieldRgba,
    required this.countries,
    required this.atmosphereProfile,
  });

  final GlobeTextureBundle textureBundle;
  final Uint8List bordersRgba;
  final Uint8List starfieldRgba;
  final List<GlobeCountryLookupEntry> countries;
  final Map<String, dynamic> atmosphereProfile;
}

class GlobeAssetResolver {
  GlobeAssetResolver({RuntimeAssetFetcher? fetcher})
    : _fetcher =
          fetcher ?? createRuntimeAssetFetcher(Uri.base.resolve('runtime-assets/'));

  final RuntimeAssetFetcher _fetcher;

  Future<GlobeResolvedAssets> loadWebStandard() async {
    _log('load:start');
    final manifest = jsonDecode(
          await _fetcher.loadString('asset_manifest.json'),
        )
        as Map<String, dynamic>;
    _log('load:manifest');
    final slots = (manifest['runtime'] as Map<String, dynamic>)['bundles']
            as Map<String, dynamic>;
    final webStandard = slots['web_standard'] as Map<String, dynamic>;
    final slotMap = webStandard['slots'] as Map<String, dynamic>;

    final earth = await _loadDecodedRaster(slotMap['earth_day_albedo'] as Map<String, dynamic>);
    _log('load:earth');
    final borders = await _loadDecodedRaster(slotMap['earth_borders_overlay'] as Map<String, dynamic>);
    _log('load:borders');
    final countryId = await _loadDecodedRaster(slotMap['earth_country_id_map'] as Map<String, dynamic>);
    _log('load:countryId');
    final starfield = await _loadDecodedRaster(slotMap['starfield_background'] as Map<String, dynamic>);
    _log('load:starfield');
    final atmosphereProfile = jsonDecode(
          await _fetcher.loadString(_relativeRuntimePath((slotMap['earth_atmosphere_profile'] as Map<String, dynamic>)['runtime_path'] as String)),
        )
        as Map<String, dynamic>;
    _log('load:atmosphere');
    final palettePath = (slotMap['earth_country_id_map'] as Map<String, dynamic>)['palette_manifest'] as String;
    final paletteJson = jsonDecode(
          await _fetcher.loadString(_relativeRuntimePath(palettePath)),
        )
        as Map<String, dynamic>;
    _log('load:palette');

    final countries = ((paletteJson['entries'] as List<dynamic>))
        .where((entry) => entry['iso_a2'] != null)
        .map(
          (entry) => GlobeCountryLookupEntry(
            index: entry['id'] as int,
            code: entry['iso_a2'] as String,
            isoA3: entry['iso_a3'] as String,
            name: entry['display_name'] as String,
            centerLat: (entry['center_lat'] as num).toDouble(),
            centerLon: (entry['center_lon'] as num).toDouble(),
            bbox: ((entry['bbox'] as List<dynamic>).cast<num>())
                .map((value) => value.toDouble())
                .toList(growable: false),
          ),
        )
        .toList(growable: false);
    _log('load:countries:${countries.length}');

    return GlobeResolvedAssets(
      textureBundle: GlobeTextureBundle(
        width: earth.width,
        height: earth.height,
        earthRgba: earth.bytes,
        countryIdRgba: countryId.bytes,
      ),
      bordersRgba: borders.bytes,
      starfieldRgba: starfield.bytes,
      countries: countries,
      atmosphereProfile: atmosphereProfile,
    );
  }

  void _log(String message) {
    debugPrint('POC_ASSET_RESOLVER_STEP|$message');
  }

  String _relativeRuntimePath(String runtimePath) {
    if (runtimePath.startsWith('/runtime-assets/')) {
      return runtimePath.replaceFirst('/runtime-assets/', '');
    }
    return runtimePath.replaceFirst(RegExp(r'^/+'), '');
  }

  Future<_DecodedRaster> _loadDecodedRaster(Map<String, dynamic> slot) async {
    final runtimePath = _relativeRuntimePath(slot['runtime_path'] as String);
    final bytes = await _fetcher.loadBytes(runtimePath);
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final byteData = await frame.image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) {
      throw StateError('Failed to decode runtime asset: $runtimePath');
    }
    return _DecodedRaster(
      width: frame.image.width,
      height: frame.image.height,
      bytes: byteData.buffer.asUint8List(),
    );
  }
}

class _DecodedRaster {
  const _DecodedRaster({
    required this.width,
    required this.height,
    required this.bytes,
  });

  final int width;
  final int height;
  final Uint8List bytes;
}
