import 'package:core_data/core_data.dart';
import 'package:core_domain/core_domain.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AtlasHomeScreen extends ConsumerWidget {
  const AtlasHomeScreen({
    super.key,
    required this.onOpenTrip,
    required this.onOpenCountry,
    required this.onOpenCity,
    required this.onOpenJournal,
    required this.onImportPhotos,
  });

  final ValueChanged<String> onOpenTrip;
  final ValueChanged<String> onOpenCountry;
  final ValueChanged<String> onOpenCity;
  final VoidCallback onOpenJournal;
  final Future<void> Function() onImportPhotos;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(atlasHomeSnapshotProvider);
    final theme = Theme.of(context);
    final sync = snapshot.syncSnapshot;
    return AtlasBackground(
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
              sliver: SliverList.list(
                children: [
                  AtlasHeroPanel(
                    eyebrow: 'Travel Atlas Home',
                    title: 'Your next memory should feel one tap away.',
                    message:
                        'This is the shipped mobile home: calm, fast, and useful even before globe parity exists.',
                    trailing: AtlasStatusPill(
                      label: _statusLabel(sync),
                      color: _syncTone(sync.severity),
                      icon: Icons.bolt_rounded,
                    ),
                    metrics: [
                      AtlasMiniMetric(
                        label: 'Countries',
                        value: '${snapshot.visitedCountries}',
                        icon: Icons.public_rounded,
                      ),
                      AtlasMiniMetric(
                        label: 'Trips',
                        value: '${snapshot.totalTrips}',
                        icon: Icons.luggage_rounded,
                      ),
                      AtlasMiniMetric(
                        label: 'Uploads',
                        value: '${snapshot.pendingUploads}',
                        icon: Icons.cloud_upload_rounded,
                      ),
                    ],
                    actions: [
                      SizedBox(
                        width: 220,
                        child: AtlasActionTile(
                          icon: Icons.edit_note_rounded,
                          title: 'Write a fresh memory',
                          subtitle:
                              'Capture a note first. Sync can catch up later.',
                          onTap: onOpenJournal,
                        ),
                      ),
                      SizedBox(
                        width: 220,
                        child: AtlasActionTile(
                          icon: Icons.add_photo_alternate_outlined,
                          title: 'Import from camera roll',
                          subtitle:
                              'Use native metadata extraction, then confirm place.',
                          onTap: () => onImportPhotos(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  AtlasPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AtlasSectionHeader(
                          title: 'Catch up today',
                          subtitle: sync.needsAttention
                              ? 'Your atlas is safe locally. Clear the pending items below when you are ready.'
                              : 'Everything important is already in a good state.',
                          trailing: AtlasStatusPill(
                            label: sync.bannerTitle,
                            color: _syncTone(sync.severity),
                          ),
                        ),
                        const SizedBox(height: 18),
                        SyncBanner(
                          title: sync.bannerTitle,
                          message:
                              '${sync.bannerMessage}\nLast synced: ${formatRelativeSync(sync.lastSyncedAt)}',
                          tone: _syncTone(sync.severity),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            AtlasMetricChip(
                              label: 'Queued changes',
                              value: '${sync.pendingChanges}',
                            ),
                            AtlasMetricChip(
                              label: 'Pending uploads',
                              value: '${sync.pendingUploads}',
                            ),
                            AtlasMetricChip(
                              label: 'Latest sync',
                              value: _syncMetric(sync),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  AtlasSectionHeader(
                    title: 'Recent trips',
                    trailing: TextButton(
                      onPressed: snapshot.recentTrips.isNotEmpty
                          ? () => onOpenTrip(snapshot.recentTrips.first.id)
                          : null,
                      child: const Text('Open latest'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...snapshot.recentTrips.map(
                    (trip) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AtlasPanel(
                        child: InkWell(
                          onTap: () => onOpenTrip(trip.id),
                          borderRadius: BorderRadius.circular(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          trip.title,
                                          style: theme.textTheme.titleMedium,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          trip.subtitle,
                                          style: theme.textTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF13253B),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      trip.heroPlace.shortLabel,
                                      style: theme.textTheme.labelLarge,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                trip.coverHint,
                                style: theme.textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                trip.dateRangeLabel,
                                style: theme.textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  AtlasMetricChip(
                                    label: 'Memories',
                                    value: '${trip.memoryCount}',
                                  ),
                                  AtlasMetricChip(
                                    label: 'Photos',
                                    value: '${trip.photoCount}',
                                  ),
                                  AtlasMetricChip(
                                    label: 'Countries',
                                    value: '${trip.countryCount}',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const AtlasSectionHeader(
                    title: 'Places worth revisiting',
                    subtitle:
                        'The fastest way back into your atlas is still by place.',
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: snapshot.highlightCountries
                        .map(
                          (country) => ActionChip(
                            label: Text(
                              '${country.countryName} • ${country.cityCount} cities',
                            ),
                            onPressed: () => onOpenCountry(country.countryCode),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 28),
                  AtlasSectionHeader(
                    title: 'Recent memories',
                    trailing: TextButton(
                      onPressed: onOpenJournal,
                      child: const Text('See all'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...snapshot.recentEntries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AtlasPanel(
                        child: InkWell(
                          onTap: () => onOpenCity(entry.place.cityKey),
                          borderRadius: BorderRadius.circular(24),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF13253B),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Icon(
                                  entry.type == MemoryType.photo
                                      ? Icons.photo_library_rounded
                                      : Icons.menu_book_rounded,
                                  color: const Color(0xFF8DEBFF),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            entry.title,
                                            style: theme.textTheme.titleMedium,
                                          ),
                                        ),
                                        AtlasStatusPill(
                                          label: entry.type == MemoryType.photo
                                              ? 'Photo'
                                              : 'Note',
                                          color: entry.type == MemoryType.photo
                                              ? const Color(0xFF8DEBFF)
                                              : const Color(0xFF67E2B7),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      entry.body,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      '${entry.place.fullLabel} • ${formatLongDate(entry.recordedAt)}',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _statusLabel(SyncSnapshot snapshot) => switch (snapshot.severity) {
  SyncSeverity.synced => 'All calm',
  SyncSeverity.syncing => 'Syncing',
  SyncSeverity.pending => 'Needs follow-up',
  SyncSeverity.attention => 'Check sync',
};

String _syncMetric(SyncSnapshot snapshot) {
  if (snapshot.lastSyncedAt == null) return 'Not yet';
  return formatShortDate(snapshot.lastSyncedAt!);
}

Color _syncTone(SyncSeverity severity) => switch (severity) {
  SyncSeverity.synced => const Color(0xFF67E2B7),
  SyncSeverity.syncing => const Color(0xFF8DEBFF),
  SyncSeverity.pending => const Color(0xFFFFD37A),
  SyncSeverity.attention => const Color(0xFFFF8B8B),
};
