import 'package:core_data/core_data.dart';
import 'package:core_domain/core_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestAdapter implements PhotoIngestionPlatformAdapter {
  @override
  Future<List<ExtractedPhotoMetadata>> pickPhotos(
    PhotoIngestionRequest request,
  ) async => const [];
}

void main() {
  test(
    'atlas home provider exposes seeded trips through backend-safe overrides',
    () {
      const backendProfile = BackendProfile(
        flavor: BackendFlavor.supabase,
        label: 'Test profile',
        remoteSyncEnabled: false,
        remoteAuthEnabled: false,
        mediaUploadEnabled: false,
        notes: 'test',
      );

      final container = ProviderContainer(
        overrides: [
          backendProfileProvider.overrideWithValue(backendProfile),
          sessionRepositoryProvider.overrideWith(
            (ref) => DemoSessionRepository(backendProfile: backendProfile),
          ),
          travelLocalStoreProvider.overrideWithValue(
            InMemoryTravelLocalStore.seeded(),
          ),
          remoteSyncGatewayProvider.overrideWithValue(NoopRemoteSyncGateway()),
          travelRemoteDataSourceProvider.overrideWithValue(
            NoopTravelRemoteDataSource(),
          ),
          photoIngestionAdapterProvider.overrideWithValue(_TestAdapter()),
        ],
      );
      addTearDown(container.dispose);

      final snapshot = container.read(atlasHomeSnapshotProvider);
      final session = container.read(sessionSnapshotProvider);
      expect(snapshot.totalTrips, greaterThan(0));
      expect(session.backendProfile.flavor, BackendFlavor.supabase);
    },
  );
}
