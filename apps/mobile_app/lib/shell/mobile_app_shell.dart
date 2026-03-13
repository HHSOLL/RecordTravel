import 'package:core_data/core_data.dart';
import 'package:core_domain/core_domain.dart';
import 'package:core_navigation/core_navigation.dart';
import 'package:core_ui/core_ui.dart';
import 'package:feature_account/feature_account.dart';
import 'package:feature_atlas_home/feature_atlas_home.dart';
import 'package:feature_journal/feature_journal.dart';
import 'package:feature_places/feature_places.dart';
import 'package:feature_search/feature_search.dart';
import 'package:feature_timeline/feature_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MobileAppShell extends ConsumerStatefulWidget {
  const MobileAppShell({super.key});

  @override
  ConsumerState<MobileAppShell> createState() => _MobileAppShellState();
}

class _MobileAppShellState extends ConsumerState<MobileAppShell> {
  AppTab _currentTab = AppTab.home;

  @override
  Widget build(BuildContext context) {
    final sync = ref.watch(syncSnapshotProvider);
    final pages = <Widget>[
      AtlasHomeScreen(
        onOpenTrip: _openTrip,
        onOpenCountry: _openCountry,
        onOpenCity: _openCity,
        onOpenJournal: _openJournalHub,
        onImportPhotos: _openPhotoImport,
      ),
      TimelineScreen(
        onOpenTrip: _openTrip,
        onOpenCity: _openCity,
        onComposeEntry: _openJournalComposer,
        onImportPhotos: _openPhotoImport,
      ),
      SearchScreen(
        onOpenTrip: _openTrip,
        onOpenCountry: _openCountry,
        onOpenCity: _openCity,
      ),
      AccountScreen(onSyncNow: _syncNow),
    ];

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(index: _currentTab.index, children: pages),
          Positioned(
            left: 20,
            right: 20,
            bottom: 92,
            child: IgnorePointer(
              ignoring: true,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 180),
                opacity: sync.needsAttention ? 1 : 0,
                child: SyncBanner(
                  title: sync.bannerTitle,
                  message: sync.bannerMessage,
                  tone: _syncTone(sync.severity),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateMenu,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Capture'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTab.index,
        onDestinationSelected: (index) =>
            setState(() => _currentTab = AppTab.values[index]),
        destinations: [
          for (final tab in AppTab.values)
            NavigationDestination(icon: Icon(tab.icon), label: tab.label),
        ],
      ),
    );
  }

  Future<void> _showCreateMenu() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AtlasPanel(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.edit_note_rounded),
                title: const Text('Write memory'),
                subtitle: const Text('Quick note with local-first draft save'),
                onTap: () {
                  Navigator.of(context).pop();
                  _openJournalComposer();
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.add_photo_alternate_outlined),
                title: const Text('Import photos'),
                subtitle: const Text(
                  'Use platform metadata extraction, then confirm inferred place',
                ),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _openPhotoImport();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _openTrip(String tripId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TripDetailScreen(
          tripId: tripId,
          onOpenCity: _openCity,
          onComposeEntry: _openJournalComposer,
          onImportPhotos: _openPhotoImport,
        ),
      ),
    );
  }

  void _openCountry(String countryCode) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CountryDetailScreen(
          countryCode: countryCode,
          onOpenCity: _openCity,
        ),
      ),
    );
  }

  void _openCity(String cityKey) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CityDetailScreen(cityKey: cityKey)),
    );
  }

  void _openJournalHub() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => JournalHubScreen(onOpenCity: _openCity),
      ),
    );
  }

  void _openJournalComposer() {
    showJournalComposerSheet(context, ref);
  }

  Future<void> _openPhotoImport() {
    return showPhotoImportSheet(context, ref);
  }

  void _syncNow() {
    ref.read(travelAppControllerProvider.notifier).markSyncRequested();
  }
}

Color _syncTone(SyncSeverity severity) => switch (severity) {
  SyncSeverity.synced => const Color(0xFF67E2B7),
  SyncSeverity.syncing => const Color(0xFF8DEBFF),
  SyncSeverity.pending => const Color(0xFFFFD37A),
  SyncSeverity.attention => const Color(0xFFFF8B8B),
};
