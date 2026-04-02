import 'package:core_ui/core_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/record_travel_graph.dart';
import '../../i18n/record_strings.dart';
import '../../models/record_models.dart';

const MethodChannel _recordRuntimeChannel = MethodChannel(
  'travel_atlas/runtime_capabilities',
);

enum RecordMapProviderKind {
  google,
  naver,
  unavailable,
}

@immutable
class RecordMapRuntimeConfig {
  const RecordMapRuntimeConfig({
    required this.hasGoogleMapsKey,
    required this.hasNaverMapClientId,
    required this.naverMapClientId,
  });

  final bool hasGoogleMapsKey;
  final bool hasNaverMapClientId;
  final String? naverMapClientId;

  bool get hasAnyMapProvider => hasGoogleMapsKey || hasNaverMapClientId;

  factory RecordMapRuntimeConfig.fromPlatformPayload(
    Map<Object?, Object?>? payload,
  ) {
    final rawNaverClientId = payload?['naverMapClientId'] as String?;
    final normalizedNaverClientId = _normalizeRuntimeString(rawNaverClientId);
    return RecordMapRuntimeConfig(
      hasGoogleMapsKey: payload?['hasGoogleMapsKey'] as bool? ?? false,
      hasNaverMapClientId: payload?['hasNaverMapClientId'] as bool? ??
          normalizedNaverClientId != null,
      naverMapClientId: normalizedNaverClientId,
    );
  }

  static String? _normalizeRuntimeString(String? value) {
    if (value == null) {
      return null;
    }
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.startsWith(r'$(')) {
      return null;
    }
    return trimmed;
  }
}

enum RecordMapRuntimeCapability {
  available,
  unavailable,
}

final recordMapRuntimeConfigProvider =
    FutureProvider<RecordMapRuntimeConfig>((ref) async {
  if (kIsWeb) {
    return const RecordMapRuntimeConfig(
      hasGoogleMapsKey: false,
      hasNaverMapClientId: false,
      naverMapClientId: null,
    );
  }

  switch (defaultTargetPlatform) {
    case TargetPlatform.iOS:
    case TargetPlatform.android:
      try {
        final payload = await _recordRuntimeChannel
            .invokeMapMethod<Object?, Object?>('getMapConfig')
            .timeout(
              const Duration(seconds: 2),
              onTimeout: () => null,
            );
        if (payload != null) {
          return RecordMapRuntimeConfig.fromPlatformPayload(payload);
        }
      } catch (_) {
        // Fall back to the legacy single-capability probe below.
      }

      try {
        final hasGoogleMapsKey = await _recordRuntimeChannel
                .invokeMethod<bool>('hasGoogleMapsKey')
                .timeout(
                  const Duration(seconds: 2),
                  onTimeout: () => false,
                ) ??
            false;
        return RecordMapRuntimeConfig(
          hasGoogleMapsKey: hasGoogleMapsKey,
          hasNaverMapClientId: false,
          naverMapClientId: null,
        );
      } catch (_) {
        return const RecordMapRuntimeConfig(
          hasGoogleMapsKey: false,
          hasNaverMapClientId: false,
          naverMapClientId: null,
        );
      }
    case TargetPlatform.macOS:
    case TargetPlatform.windows:
    case TargetPlatform.linux:
    case TargetPlatform.fuchsia:
      return const RecordMapRuntimeConfig(
        hasGoogleMapsKey: false,
        hasNaverMapClientId: false,
        naverMapClientId: null,
      );
  }
});

final recordMapRuntimeCapabilityProvider =
    FutureProvider<RecordMapRuntimeCapability>((ref) async {
  final config = await ref.watch(recordMapRuntimeConfigProvider.future);
  return config.hasAnyMapProvider
      ? RecordMapRuntimeCapability.available
      : RecordMapRuntimeCapability.unavailable;
});

RecordMapProviderKind recordMapProviderForCountry({
  required RecordMapRuntimeConfig config,
  required String countryCode,
}) {
  final normalizedCode = countryCode.trim().toUpperCase();
  if (normalizedCode == 'KR' && config.hasNaverMapClientId) {
    return RecordMapProviderKind.naver;
  }
  if (config.hasGoogleMapsKey) {
    return RecordMapProviderKind.google;
  }
  return RecordMapProviderKind.unavailable;
}

RecordMapProviderKind recordMapProviderForProjection({
  required RecordMapRuntimeConfig config,
  required RecordCountryProjection projection,
}) {
  return recordMapProviderForCountry(
    config: config,
    countryCode: projection.code,
  );
}

RecordMapProviderKind recordMapProviderForTrip({
  required RecordMapRuntimeConfig config,
  required RecordTrip trip,
}) {
  if (_isKoreaOnlyTrip(trip) && config.hasNaverMapClientId) {
    return RecordMapProviderKind.naver;
  }
  if (config.hasGoogleMapsKey) {
    return RecordMapProviderKind.google;
  }
  return RecordMapProviderKind.unavailable;
}

bool _isKoreaOnlyTrip(RecordTrip trip) {
  final normalizedCodes = <String>{
    for (final country in trip.countries) country.code.trim().toUpperCase(),
    for (final location in trip.locations)
      location.countryCode.trim().toUpperCase(),
  }..removeWhere((value) => value.isEmpty);

  return normalizedCodes.isNotEmpty &&
      normalizedCodes.every((value) => value == 'KR');
}

class RecordMapLoadingSurface extends StatelessWidget {
  const RecordMapLoadingSurface({
    super.key,
    this.height,
  });

  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.atlasPalette.surfaceMuted,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.atlasPalette.outline),
      ),
      alignment: Alignment.center,
      child: const SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(strokeWidth: 2.4),
      ),
    );
  }
}

class RecordMapUnavailableSurface extends StatelessWidget {
  const RecordMapUnavailableSurface({
    super.key,
    required this.accentColor,
    this.height,
  });

  final Color accentColor;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final strings = RecordStrings.of(context);
    return Container(
      height: height,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.atlasPalette.surfaceMuted,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.atlasPalette.outline),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.map_outlined,
              color: accentColor,
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            strings.text('map.unavailableTitle'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            strings.text('map.unavailableSubtitle'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
