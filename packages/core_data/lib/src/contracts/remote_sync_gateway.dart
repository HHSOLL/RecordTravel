import 'package:core_domain/core_domain.dart';

import 'travel_local_store.dart';

abstract class RemoteSyncGateway {
  Future<SyncSnapshot> requestSync(TravelLocalStore store);
  Future<SyncSnapshot> markResolved(TravelLocalStore store);
}
