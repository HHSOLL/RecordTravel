import 'package:core_data/core_data.dart';
import 'package:core_domain/core_domain.dart';
import 'package:mobile_app/bootstrap/mobile_app_runtime.dart';
import 'package:mobile_app/platform/demo_photo_ingestion_adapter.dart';

MobileAppRuntime buildTestMobileAppRuntime({String? startupWarningMessage}) {
  const backendProfile = BackendProfile(
    flavor: BackendFlavor.supabase,
    label: 'Widget test profile',
    remoteSyncEnabled: false,
    remoteAuthEnabled: false,
    mediaUploadEnabled: false,
    notes: 'test',
  );

  return MobileAppRuntime(
    backendProfile: backendProfile,
    sessionRepository: DemoSessionRepository(backendProfile: backendProfile),
    travelLocalStore: InMemoryTravelLocalStore.seeded(),
    remoteSyncGateway: NoopRemoteSyncGateway(),
    travelRemoteDataSource: NoopTravelRemoteDataSource(),
    photoIngestionAdapter: DemoPhotoIngestionAdapter(),
    startupWarningMessage: startupWarningMessage,
  );
}
