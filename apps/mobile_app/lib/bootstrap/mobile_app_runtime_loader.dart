import 'package:core_data/core_data_mobile.dart';
import 'package:core_domain/core_domain.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../platform/local/draft_session_repository.dart';
import '../platform/native_photo_ingestion_adapter.dart';
import '../platform/supabase/supabase_remote_sync_gateway.dart';
import '../platform/supabase/supabase_runtime_config.dart';
import '../platform/supabase/supabase_travel_remote_data_source.dart';
import 'mobile_app_runtime.dart';

Future<MobileAppRuntime> loadMobileAppRuntime() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    return await _loadMobileAppRuntime().timeout(const Duration(seconds: 4));
  } catch (error, stackTrace) {
    debugPrint('TravelAtlas runtime fallback: $error');
    debugPrintStack(stackTrace: stackTrace);
    return _buildFallbackRuntime();
  }
}

Future<MobileAppRuntime> _loadMobileAppRuntime() async {
  debugPrint('TravelAtlas runtime: opening local store');

  final localStore = await DriftTravelLocalStore.open();
  debugPrint('TravelAtlas runtime: local store ready');
  final runtimeConfig = SupabaseRuntimeConfig.fromEnvironment;

  if (!runtimeConfig.isConfigured) {
    const backendProfile = BackendProfile(
      flavor: BackendFlavor.supabase,
      label: 'Preview-auth local-first mode',
      remoteSyncEnabled: false,
      remoteAuthEnabled: false,
      mediaUploadEnabled: false,
      notes:
          'Preview auth accepts any ID while the product flows are still being migrated. Local-first mobile flows stay usable without binding the app to a final auth contract yet.',
    );

    return MobileAppRuntime(
      backendProfile: backendProfile,
      sessionRepository: DraftSessionRepository(backendProfile: backendProfile),
      travelLocalStore: localStore,
      remoteSyncGateway: NoopRemoteSyncGateway(),
      travelRemoteDataSource: NoopTravelRemoteDataSource(),
      photoIngestionAdapter: NativePhotoIngestionAdapter(),
    );
  }

  debugPrint('TravelAtlas runtime: initializing Supabase');
  await Supabase.initialize(
    url: runtimeConfig.url,
    anonKey: runtimeConfig.anonKey,
  );
  final client = Supabase.instance.client;
  final remoteDataSource = SupabaseTravelRemoteDataSource(client);

  const backendProfile = BackendProfile(
    flavor: BackendFlavor.supabase,
    label: 'Supabase runtime with preview auth',
    remoteSyncEnabled: true,
    remoteAuthEnabled: false,
    mediaUploadEnabled: true,
    notes:
        'Supabase data adapters are available, but the login surface is temporarily running in preview mode so the product flows can be completed before real auth is enforced.',
  );

  return MobileAppRuntime(
    backendProfile: backendProfile,
    sessionRepository: DraftSessionRepository(backendProfile: backendProfile),
    travelLocalStore: localStore,
    remoteSyncGateway: SupabaseRemoteSyncGateway(
      client: client,
      remoteDataSource: remoteDataSource,
    ),
    travelRemoteDataSource: remoteDataSource,
    photoIngestionAdapter: NativePhotoIngestionAdapter(),
  );
}

MobileAppRuntime _buildFallbackRuntime() {
  const backendProfile = BackendProfile(
    flavor: BackendFlavor.supabase,
    label: 'Fallback local runtime',
    remoteSyncEnabled: false,
    remoteAuthEnabled: false,
    mediaUploadEnabled: false,
    notes:
        'The persistent local store did not become ready during startup, so the app fell back to an in-memory local-first runtime. Core UI flows remain usable while startup diagnostics stay isolated.',
  );

  return MobileAppRuntime(
    backendProfile: backendProfile,
    sessionRepository: DraftSessionRepository(backendProfile: backendProfile),
    travelLocalStore: InMemoryTravelLocalStore.seeded(),
    remoteSyncGateway: NoopRemoteSyncGateway(),
    travelRemoteDataSource: NoopTravelRemoteDataSource(),
    photoIngestionAdapter: NativePhotoIngestionAdapter(),
  );
}
