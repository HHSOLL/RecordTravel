import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/shell/globe_runtime_capability.dart';

void main() {
  test('3D globe remains disabled on fuchsia', () async {
    final previousPlatform = debugDefaultTargetPlatformOverride;
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
    addTearDown(() {
      debugDefaultTargetPlatformOverride = previousPlatform;
    });

    final container = ProviderContainer();
    addTearDown(container.dispose);

    final availability = await container.read(globe3dAvailabilityProvider.future);
    expect(availability, Globe3dAvailability.unsupported);
  });
}
