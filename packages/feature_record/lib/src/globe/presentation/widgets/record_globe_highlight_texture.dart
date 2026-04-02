import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';

import '../../domain/entities/record_globe_country.dart';
import '../../../globe_engine/picking/record_country_lookup_grid.dart';

const _recordCountryLookupGridAsset = 'assets/globe/country_lookup_v1.bin';
const _recordCountryLookupPaletteAsset =
    'assets/globe/country_lookup_v1_palette.json';

class RecordGlobeHighlightTextureBuilder {
  const RecordGlobeHighlightTextureBuilder._();

  static Future<ui.Image?> build(List<RecordGlobeCountry> countries) async {
    final lookupGrid = await RecordCountryLookupGrid.load(
      gridAsset: _recordCountryLookupGridAsset,
      paletteAsset: _recordCountryLookupPaletteAsset,
    );
    final rgbaBytes = buildPixels(lookupGrid, countries);
    if (!_hasVisiblePixels(rgbaBytes)) {
      return null;
    }
    return _decodeRgba(
      rgbaBytes,
      width: lookupGrid.width,
      height: lookupGrid.height,
    );
  }

  @visibleForTesting
  static Uint8List buildPixels(
    RecordCountryLookupGrid lookupGrid,
    List<RecordGlobeCountry> countries,
  ) {
    final styles = <String, _HighlightPixel>{};
    for (final country in countries) {
      final style = _styleFor(country);
      if (style != null) {
        styles[country.code] = style;
      }
    }

    final pixels = Uint8List(lookupGrid.width * lookupGrid.height * 4);
    final alphaMask = Uint8List(lookupGrid.width * lookupGrid.height);
    for (var index = 0; index < lookupGrid.indices.length; index += 1) {
      final paletteIndex = lookupGrid.indices[index];
      if (paletteIndex <= 0 || paletteIndex >= lookupGrid.countryCodes.length) {
        continue;
      }
      final code = lookupGrid.countryCodes[paletteIndex].trim();
      final style = styles[code];
      if (style == null) {
        continue;
      }
      final offset = index * 4;
      pixels[offset] = style.r;
      pixels[offset + 1] = style.g;
      pixels[offset + 2] = style.b;
      pixels[offset + 3] = style.a;
      alphaMask[index] = style.a;
    }
    _softenEdges(pixels, alphaMask, lookupGrid.width, lookupGrid.height);
    return pixels;
  }

  static _HighlightPixel? _styleFor(RecordGlobeCountry country) {
    switch (country.signal) {
      case RecordGlobeCountrySignal.visited:
        final activity = country.activityLevel.clamp(0, 4);
        return _HighlightPixel(
          r: 132 + (activity * 12),
          g: 225 + (activity * 4),
          b: 255,
          a: 92 + (activity * 26) + (country.hasRecentVisit ? 18 : 0),
        );
      case RecordGlobeCountrySignal.planned:
        return _HighlightPixel(
          r: 118,
          g: 224,
          b: 236,
          a: 66 + (country.hasUpcomingTrip ? 22 : 0),
        );
      case RecordGlobeCountrySignal.neutral:
        return null;
    }
  }

  static void _softenEdges(
    Uint8List rgbaPixels,
    Uint8List alphaMask,
    int width,
    int height,
  ) {
    if (width == 0 || height == 0) {
      return;
    }
    final softened = Uint8List.fromList(alphaMask);
    for (var y = 0; y < height; y += 1) {
      for (var x = 0; x < width; x += 1) {
        final index = (y * width) + x;
        final alpha = alphaMask[index];
        if (alpha == 0) {
          continue;
        }
        var touchesEdge = false;
        for (var dy = -1; dy <= 1 && !touchesEdge; dy += 1) {
          for (var dx = -1; dx <= 1; dx += 1) {
            final nx = x + dx;
            final ny = y + dy;
            if (nx < 0 || nx >= width || ny < 0 || ny >= height) {
              touchesEdge = true;
              break;
            }
            if (alphaMask[(ny * width) + nx] == 0) {
              touchesEdge = true;
              break;
            }
          }
        }
        if (touchesEdge) {
          softened[index] = (alpha * 0.68).round().clamp(0, 255);
        }
      }
    }

    for (var index = 0; index < softened.length; index += 1) {
      rgbaPixels[(index * 4) + 3] = softened[index];
    }
  }

  static Future<ui.Image> _decodeRgba(
    Uint8List bytes, {
    required int width,
    required int height,
  }) {
    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      bytes,
      width,
      height,
      ui.PixelFormat.rgba8888,
      (image) => completer.complete(image),
    );
    return completer.future;
  }

  static bool _hasVisiblePixels(Uint8List rgbaBytes) {
    for (var index = 3; index < rgbaBytes.length; index += 4) {
      if (rgbaBytes[index] > 0) {
        return true;
      }
    }
    return false;
  }
}

class _HighlightPixel {
  const _HighlightPixel({
    required this.r,
    required this.g,
    required this.b,
    required this.a,
  });

  final int r;
  final int g;
  final int b;
  final int a;
}
