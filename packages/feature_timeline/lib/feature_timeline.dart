import 'package:core_data/core_data.dart';
import 'package:core_domain/core_domain.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _TimelineFilter { all, notes, photos }

class TimelineScreen extends ConsumerStatefulWidget {
  const TimelineScreen({
    super.key,
    required this.onOpenTrip,
    required this.onOpenCity,
    required this.onComposeEntry,
    required this.onImportPhotos,
  });

  final ValueChanged<String> onOpenTrip;
  final ValueChanged<String> onOpenCity;
  final VoidCallback onComposeEntry;
  final Future<void> Function() onImportPhotos;

  @override
  ConsumerState<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends ConsumerState<TimelineScreen> {
  _TimelineFilter _filter = _TimelineFilter.all;

  @override
  Widget build(BuildContext context) {
    final trips = ref.watch(tripsProvider);
    final allGroups = ref.watch(allTimelineGroupsProvider);
    final groups = _applyFilter(allGroups, _filter);
    final totalEntries = allGroups.fold<int>(
      0,
      (sum, group) => sum + group.entries.length,
    );
    final photoEntries = allGroups.fold<int>(
      0,
      (sum, group) =>
          sum +
          group.entries.where((entry) => entry.type == MemoryType.photo).length,
    );
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
                    eyebrow: 'Timeline',
                    title: 'Playback should stay readable, not noisy.',
                    message:
                        'This is where day-by-day travel recall becomes useful. Keep the chronology calm and the actions close.',
                    trailing: const AtlasOrbitalGraphic(size: 100),
                    metrics: [
                      AtlasMiniMetric(
                        label: 'Entries',
                        value: '$totalEntries',
                        icon: Icons.auto_stories_rounded,
                      ),
                      AtlasMiniMetric(
                        label: 'Photos',
                        value: '$photoEntries',
                        icon: Icons.photo_library_rounded,
                      ),
                      AtlasMiniMetric(
                        label: 'Trips',
                        value: '${trips.length}',
                        icon: Icons.luggage_rounded,
                      ),
                    ],
                    actions: [
                      SizedBox(
                        width: 220,
                        child: AtlasActionTile(
                          icon: Icons.edit_note_rounded,
                          title: 'Add a fresh entry',
                          subtitle:
                              'Drop a note into the timeline immediately.',
                          onTap: widget.onComposeEntry,
                        ),
                      ),
                      SizedBox(
                        width: 220,
                        child: AtlasActionTile(
                          icon: Icons.add_photo_alternate_outlined,
                          title: 'Bring in camera roll',
                          subtitle: 'Turn metadata into timeline memories.',
                          onTap: () => widget.onImportPhotos(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  AtlasSectionHeader(
                    title: 'Trip timeline',
                    subtitle:
                        'Chronological travel playback, ready for daily use.',
                    trailing: FilledButton.tonalIcon(
                      onPressed: widget.onComposeEntry,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('New'),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _FilterChip(
                        label: 'All',
                        selected: _filter == _TimelineFilter.all,
                        onTap: () =>
                            setState(() => _filter = _TimelineFilter.all),
                      ),
                      _FilterChip(
                        label: 'Notes',
                        selected: _filter == _TimelineFilter.notes,
                        onTap: () =>
                            setState(() => _filter = _TimelineFilter.notes),
                      ),
                      _FilterChip(
                        label: 'Photos',
                        selected: _filter == _TimelineFilter.photos,
                        onTap: () =>
                            setState(() => _filter = _TimelineFilter.photos),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 148,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: trips.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final trip = trips[index];
                        return SizedBox(
                          width: 250,
                          child: AtlasPanel(
                            child: InkWell(
                              onTap: () => widget.onOpenTrip(trip.id),
                              borderRadius: BorderRadius.circular(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    trip.title,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    trip.dateRangeLabel,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                  const Spacer(),
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
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: widget.onImportPhotos,
                          icon: const Icon(Icons.add_photo_alternate_outlined),
                          label: const Text('Import to timeline'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (groups.isEmpty)
                    AtlasEmptyState(
                      title: 'Nothing matches this timeline filter',
                      message: _filter == _TimelineFilter.all
                          ? 'Import photos or write a memory to start your chronology.'
                          : 'Switch filters or add more ${_filter == _TimelineFilter.photos ? 'photo' : 'note'} memories.',
                      action: FilledButton.icon(
                        onPressed: _filter == _TimelineFilter.photos
                            ? widget.onImportPhotos
                            : widget.onComposeEntry,
                        icon: Icon(
                          _filter == _TimelineFilter.photos
                              ? Icons.add_photo_alternate_outlined
                              : Icons.edit_note_rounded,
                        ),
                        label: Text(
                          _filter == _TimelineFilter.photos
                              ? 'Import photos'
                              : 'Write memory',
                        ),
                      ),
                    ),
                  ...groups.map(
                    (group) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: AtlasPanel(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              formatLongDate(group.date),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 14),
                            ...group.entries.map(
                              (entry) => Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(top: 6),
                                      child: TimelineMarker(),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: InkWell(
                                        onTap: () => widget.onOpenCity(
                                          entry.place.cityKey,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        child: Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      entry.title,
                                                      style: Theme.of(
                                                        context,
                                                      ).textTheme.titleMedium,
                                                    ),
                                                  ),
                                                  AtlasStatusPill(
                                                    label:
                                                        entry.type ==
                                                            MemoryType.photo
                                                        ? 'Photo'
                                                        : 'Note',
                                                    color:
                                                        entry.type ==
                                                            MemoryType.photo
                                                        ? const Color(
                                                            0xFF8DEBFF,
                                                          )
                                                        : const Color(
                                                            0xFF67E2B7,
                                                          ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                entry.body,
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.bodyMedium,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                '${entry.place.fullLabel} • ${entry.type.name}',
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.bodyMedium,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
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

List<TimelineDayGroup> _applyFilter(
  List<TimelineDayGroup> groups,
  _TimelineFilter filter,
) {
  if (filter == _TimelineFilter.all) return groups;
  final type = filter == _TimelineFilter.photos
      ? MemoryType.photo
      : MemoryType.note;
  final filtered = <TimelineDayGroup>[];
  for (final group in groups) {
    final entries = group.entries.where((entry) => entry.type == type).toList();
    if (entries.isNotEmpty) {
      filtered.add(TimelineDayGroup(date: group.date, entries: entries));
    }
  }
  return filtered;
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}

class TripDetailScreen extends ConsumerWidget {
  const TripDetailScreen({
    super.key,
    required this.tripId,
    required this.onOpenCity,
    required this.onComposeEntry,
    required this.onImportPhotos,
  });

  final String tripId;
  final ValueChanged<String> onOpenCity;
  final VoidCallback onComposeEntry;
  final Future<void> Function() onImportPhotos;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trip = ref.watch(tripByIdProvider(tripId));
    final groups = ref.watch(tripTimelineGroupsProvider(tripId));
    if (trip == null) {
      return const Scaffold(body: Center(child: Text('Trip not found')));
    }
    return Scaffold(
      appBar: AppBar(title: Text(trip.title)),
      body: AtlasBackground(
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
            children: [
              AtlasPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.subtitle,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${trip.heroPlace.fullLabel} • ${trip.dateRangeLabel}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: onComposeEntry,
                            icon: const Icon(Icons.edit_note_rounded),
                            label: const Text('Write memory'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onImportPhotos,
                            icon: const Icon(
                              Icons.add_photo_alternate_outlined,
                            ),
                            label: const Text('Import photos'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ...groups.map(
                (group) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AtlasPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formatLongDate(group.date),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        ...group.entries.map(
                          (entry) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              entry.type == MemoryType.photo
                                  ? Icons.photo_library_rounded
                                  : Icons.menu_book_rounded,
                            ),
                            title: Text(entry.title),
                            subtitle: Text(
                              '${entry.place.fullLabel}\n${entry.body}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () => onOpenCity(entry.place.cityKey),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
