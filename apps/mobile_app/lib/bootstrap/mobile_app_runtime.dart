import 'package:core_data/core_data.dart';
import 'package:core_domain/core_domain.dart';

class MobileAppRuntime {
  const MobileAppRuntime({
    required this.backendProfile,
    required this.sessionRepository,
    required this.travelLocalStore,
    required this.remoteSyncGateway,
    required this.travelRemoteDataSource,
    required this.photoIngestionAdapter,
    this.startupWarningMessage,
  });

  final BackendProfile backendProfile;
  final SessionRepository sessionRepository;
  final TravelLocalStore travelLocalStore;
  final RemoteSyncGateway remoteSyncGateway;
  final TravelRemoteDataSource travelRemoteDataSource;
  final PhotoIngestionPlatformAdapter photoIngestionAdapter;
  final String? startupWarningMessage;

  bool get hasStartupWarning => startupWarningMessage != null;
}
