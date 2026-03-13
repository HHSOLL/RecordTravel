import 'package:core_data/core_data_mobile.dart';
import 'package:core_domain/core_domain.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../platform/native_photo_ingestion_adapter.dart';
import '../platform/supabase/supabase_remote_sync_gateway.dart';
import '../platform/supabase/supabase_runtime_config.dart';
import '../platform/supabase/supabase_session_repository.dart';
import '../platform/supabase/supabase_travel_remote_data_source.dart';
import 'mobile_app_runtime.dart';

Future<MobileAppRuntime> loadMobileAppRuntime() async {
  WidgetsFlutterBinding.ensureInitialized();

  final localStore = await DriftTravelLocalStore.open();
  final runtimeConfig = SupabaseRuntimeConfig.fromEnvironment;

  if (!runtimeConfig.isConfigured) {
    const backendProfile = BackendProfile(
      flavor: BackendFlavor.supabase,
      label: 'Supabase-ready local-first mode',
      remoteSyncEnabled: false,
      remoteAuthEnabled: false,
      mediaUploadEnabled: false,
      notes:
          'Supabase keys are not configured yet. Local-first mobile product flows stay fully usable while backend wiring remains replaceable.',
    );

    return MobileAppRuntime(
      backendProfile: backendProfile,
      sessionRepository: DemoSessionRepository(backendProfile: backendProfile),
      travelLocalStore: localStore,
      remoteSyncGateway: NoopRemoteSyncGateway(),
      travelRemoteDataSource: NoopTravelRemoteDataSource(),
      photoIngestionAdapter: NativePhotoIngestionAdapter(),
    );
  }

  await Supabase.initialize(
    url: runtimeConfig.url,
    anonKey: runtimeConfig.anonKey,
  );
  final client = Supabase.instance.client;
  final remoteDataSource = SupabaseTravelRemoteDataSource(client);

  const backendProfile = BackendProfile(
    flavor: BackendFlavor.supabase,
    label: 'Supabase mobile runtime',
    remoteSyncEnabled: true,
    remoteAuthEnabled: true,
    mediaUploadEnabled: true,
    notes:
        'Auth/session, Postgres-backed data sync, and storage upload paths are routed through Supabase adapters. API boundaries remain compatible with a later Spring migration.',
  );

  return MobileAppRuntime(
    backendProfile: backendProfile,
    sessionRepository: SupabaseSessionRepository(
      client: client,
      backendProfile: backendProfile,
    ),
    travelLocalStore: localStore,
    remoteSyncGateway: SupabaseRemoteSyncGateway(
      client: client,
      remoteDataSource: remoteDataSource,
    ),
    travelRemoteDataSource: remoteDataSource,
    photoIngestionAdapter: NativePhotoIngestionAdapter(),
  );
}
