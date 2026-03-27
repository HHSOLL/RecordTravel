import 'package:core_ui/core_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../i18n/record_strings.dart';

const MethodChannel _recordRuntimeChannel = MethodChannel(
  'travel_atlas/runtime_capabilities',
);

enum RecordMapRuntimeCapability {
  available,
  unavailable,
}

final recordMapRuntimeCapabilityProvider =
    FutureProvider<RecordMapRuntimeCapability>((ref) async {
  if (kIsWeb) {
    return RecordMapRuntimeCapability.unavailable;
  }

  switch (defaultTargetPlatform) {
    case TargetPlatform.iOS:
    case TargetPlatform.android:
      try {
        final hasGoogleMapsKey = await _recordRuntimeChannel
                .invokeMethod<bool>(
                  'hasGoogleMapsKey',
                )
                .timeout(
                  const Duration(seconds: 2),
                  onTimeout: () => false,
                ) ??
            false;
        return hasGoogleMapsKey
            ? RecordMapRuntimeCapability.available
            : RecordMapRuntimeCapability.unavailable;
      } catch (_) {
        return RecordMapRuntimeCapability.unavailable;
      }
    case TargetPlatform.macOS:
    case TargetPlatform.windows:
    case TargetPlatform.linux:
    case TargetPlatform.fuchsia:
      return RecordMapRuntimeCapability.unavailable;
  }
});

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
