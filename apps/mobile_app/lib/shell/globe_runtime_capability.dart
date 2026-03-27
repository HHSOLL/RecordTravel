import 'dart:async';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _forceGlobeFallback = bool.fromEnvironment('ATLAS_FORCE_GLOBE_FALLBACK');

enum Globe3dAvailability { checking, supported, unsupported }

final globe3dAvailabilityProvider = FutureProvider<Globe3dAvailability>((
  ref,
) async {
  if (_forceGlobeFallback) {
    return Globe3dAvailability.unsupported;
  }
  if (kIsWeb) {
    return Globe3dAvailability.unsupported;
  }

  try {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        final iosInfo = await DeviceInfoPlugin().iosInfo.timeout(
          const Duration(seconds: 2),
          onTimeout: () => throw TimeoutException('iosInfo timed out'),
        );
        return iosInfo.isPhysicalDevice
            ? Globe3dAvailability.supported
            : Globe3dAvailability.unsupported;
      case TargetPlatform.android:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return Globe3dAvailability.supported;
      case TargetPlatform.fuchsia:
        return Globe3dAvailability.unsupported;
    }
  } catch (_) {
    return Globe3dAvailability.unsupported;
  }
});
