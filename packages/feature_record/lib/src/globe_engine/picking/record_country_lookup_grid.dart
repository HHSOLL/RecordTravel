import 'dart:math' as math;
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

@immutable
class RecordCountryLookupGrid {
  const RecordCountryLookupGrid({
    required this.width,
    required this.height,
    required this.indices,
    required this.countryCodes,
  });

  final int width;
  final int height;
  final Uint8List indices;
  final List<String> countryCodes;

  static final Map<String, Future<RecordCountryLookupGrid>> _cache = {};

  static Future<RecordCountryLookupGrid> load({
    required String gridAsset,
    required String paletteAsset,
  }) {
    final cacheKey = '$gridAsset::$paletteAsset';
    return _cache.putIfAbsent(
      cacheKey,
      () async {
        final paletteRaw = await rootBundle.loadString(paletteAsset);
        final paletteJson = json.decode(paletteRaw) as Map<String, dynamic>;
        final width = paletteJson['width'] as int;
        final height = paletteJson['height'] as int;
        final countryCodes = List<String>.from(
          paletteJson['countryCodes'] as List<dynamic>,
        );
        final bytes = (await rootBundle.load(gridAsset)).buffer.asUint8List();
        final expectedLength = width * height;
        if (bytes.length != expectedLength) {
          throw FlutterError(
            'Country lookup grid size mismatch: expected $expectedLength bytes '
            'for $width x $height, got ${bytes.length}.',
          );
        }
        return RecordCountryLookupGrid(
          width: width,
          height: height,
          indices: bytes,
          countryCodes: countryCodes,
        );
      },
    );
  }

  String? countryCodeForUv(
    double u,
    double v, {
    int neighborhoodRadius = 1,
  }) {
    if (width == 0 || height == 0 || countryCodes.isEmpty) {
      return null;
    }

    final wrappedU = u - u.floorToDouble();
    final clampedV = v.clamp(0.0, 0.999999);
    final centerX = (wrappedU * width).floor();
    final centerY = (clampedV * height).floor();

    final counts = <int, int>{};
    for (var dy = -neighborhoodRadius; dy <= neighborhoodRadius; dy += 1) {
      for (var dx = -neighborhoodRadius; dx <= neighborhoodRadius; dx += 1) {
        final sampleX = (centerX + dx) % width;
        final normalizedX = sampleX < 0 ? sampleX + width : sampleX;
        final sampleY = (centerY + dy).clamp(0, height - 1);
        final index = indices[sampleY * width + normalizedX];
        if (index == 0) {
          continue;
        }
        counts[index] = (counts[index] ?? 0) + 1;
      }
    }

    if (counts.isEmpty) {
      return null;
    }

    var bestIndex = 0;
    var bestCount = -1;
    for (final entry in counts.entries) {
      if (entry.value > bestCount) {
        bestIndex = entry.key;
        bestCount = entry.value;
      }
    }

    if (bestIndex <= 0 || bestIndex >= countryCodes.length) {
      return null;
    }
    final code = countryCodes[bestIndex].trim();
    return code.isEmpty ? null : code;
  }
}

class RecordCountrySurfacePicker {
  const RecordCountrySurfacePicker({
    required this.lookupGrid,
  });

  final RecordCountryLookupGrid lookupGrid;

  String? countryCodeForLocalPoint(vm.Vector3 point) {
    final uv = uvForLocalPoint(point);
    return lookupGrid.countryCodeForUv(uv.x, uv.y);
  }

  static vm.Vector2 uvForLocalPoint(vm.Vector3 point) {
    final normalized = vm.Vector3.copy(point)..normalize();
    final u = 0.5 + math.atan2(normalized.x, normalized.z) / (math.pi * 2);
    final v = 0.5 - math.asin(normalized.y.clamp(-1.0, 1.0)) / math.pi;
    return vm.Vector2(u, v);
  }
}
