import 'package:core_domain/core_domain.dart';

import '../contracts/remote_sync_gateway.dart';
import '../contracts/travel_local_store.dart';

class NoopRemoteSyncGateway implements RemoteSyncGateway {
  @override
  Future<SyncSnapshot> requestSync(TravelLocalStore store) async {
    final state = store.snapshot;
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return state.syncSnapshot.copyWith(
      severity: SyncSeverity.syncing,
      bannerTitle: 'Sync in progress',
      bannerMessage: 'Local changes are queued behind a backend-safe boundary.',
    );
  }

  @override
  Future<SyncSnapshot> markResolved(TravelLocalStore store) async {
    final outbox = await store.getPendingOutboxItems();
    final uploads = await store.getPendingMediaUploads();
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return SyncSnapshot(
      severity: SyncSeverity.synced,
      bannerTitle: 'Everything is saved',
      bannerMessage:
          'Trips, memories, and upload intents are stored cleanly for later sync.',
      pendingChanges: outbox.length,
      pendingUploads: uploads.length,
      lastSyncedAt: DateTime.now(),
    );
  }
}
