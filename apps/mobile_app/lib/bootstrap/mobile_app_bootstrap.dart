import 'package:core_data/core_data.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'mobile_app_runtime.dart';

final mobileAppRuntimeProvider = Provider<MobileAppRuntime>(
  (ref) => throw UnimplementedError(
    'mobileAppRuntimeProvider must be overridden by the app bootstrap.',
  ),
);

class MobileAppBootstrap extends StatelessWidget {
  const MobileAppBootstrap({
    super.key,
    required this.runtime,
    required this.child,
  });

  final MobileAppRuntime runtime;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        mobileAppRuntimeProvider.overrideWithValue(runtime),
        backendProfileProvider.overrideWithValue(runtime.backendProfile),
        sessionRepositoryProvider.overrideWith(
          (ref) => runtime.sessionRepository,
        ),
        travelLocalStoreProvider.overrideWithValue(runtime.travelLocalStore),
        remoteSyncGatewayProvider.overrideWithValue(runtime.remoteSyncGateway),
        travelRemoteDataSourceProvider.overrideWithValue(
          runtime.travelRemoteDataSource,
        ),
        photoIngestionAdapterProvider.overrideWithValue(
          runtime.photoIngestionAdapter,
        ),
      ],
      child: child,
    );
  }
}
