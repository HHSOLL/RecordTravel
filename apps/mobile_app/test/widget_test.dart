import 'package:core_data/core_data.dart';
import 'package:core_domain/core_domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/bootstrap/mobile_app_bootstrap.dart';
import 'package:mobile_app/bootstrap/mobile_app_runtime.dart';
import 'package:mobile_app/main.dart';
import 'package:mobile_app/platform/demo_photo_ingestion_adapter.dart';

void main() {
  testWidgets('app renders shipped atlas home', (tester) async {
    const backendProfile = BackendProfile(
      flavor: BackendFlavor.supabase,
      label: 'Widget test profile',
      remoteSyncEnabled: false,
      remoteAuthEnabled: false,
      mediaUploadEnabled: false,
      notes: 'test',
    );
    final runtime = MobileAppRuntime(
      backendProfile: backendProfile,
      sessionRepository: DemoSessionRepository(backendProfile: backendProfile),
      travelLocalStore: InMemoryTravelLocalStore.seeded(),
      remoteSyncGateway: NoopRemoteSyncGateway(),
      travelRemoteDataSource: NoopTravelRemoteDataSource(),
      photoIngestionAdapter: DemoPhotoIngestionAdapter(),
    );
    await tester.pumpWidget(
      MobileAppBootstrap(runtime: runtime, child: const TravelAtlasApp()),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Your next memory should feel one tap away.'),
      findsOneWidget,
    );
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Timeline'), findsOneWidget);
  });
}
