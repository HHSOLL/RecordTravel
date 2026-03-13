import 'package:core_data/core_data.dart';
import 'package:core_domain/core_domain.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _JournalFilter { all, notes, photos }

class JournalHubScreen extends ConsumerStatefulWidget {
  const JournalHubScreen({super.key, required this.onOpenCity});

  final ValueChanged<String> onOpenCity;

  @override
  ConsumerState<JournalHubScreen> createState() => _JournalHubScreenState();
}

class _JournalHubScreenState extends ConsumerState<JournalHubScreen> {
  _JournalFilter _filter = _JournalFilter.all;

  @override
  Widget build(BuildContext context) {
    final allEntries = [...ref.watch(entriesProvider)]
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    final entries = _filter == _JournalFilter.all
        ? allEntries
        : allEntries
              .where(
                (entry) => _filter == _JournalFilter.photos
                    ? entry.type == MemoryType.photo
                    : entry.type == MemoryType.note,
              )
              .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Journal')),
      body: AtlasBackground(
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
            children: [
              AtlasHeroPanel(
                eyebrow: 'Journal',
                title:
                    'Your journal should read like a collection, not a dump.',
                message:
                    'This screen is for re-reading, scanning, and deciding what is worth keeping visible later.',
                metrics: [
                  AtlasMiniMetric(
                    label: 'Entries',
                    value: '${allEntries.length}',
                    icon: Icons.menu_book_rounded,
                  ),
                  AtlasMiniMetric(
                    label: 'Photos',
                    value:
                        '${allEntries.where((entry) => entry.type == MemoryType.photo).length}',
                    icon: Icons.photo_library_rounded,
                  ),
                  AtlasMiniMetric(
                    label: 'Notes',
                    value:
                        '${allEntries.where((entry) => entry.type == MemoryType.note).length}',
                    icon: Icons.edit_note_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _JournalFilterChip(
                    label: 'All',
                    selected: _filter == _JournalFilter.all,
                    onTap: () => setState(() => _filter = _JournalFilter.all),
                  ),
                  _JournalFilterChip(
                    label: 'Notes',
                    selected: _filter == _JournalFilter.notes,
                    onTap: () => setState(() => _filter = _JournalFilter.notes),
                  ),
                  _JournalFilterChip(
                    label: 'Photos',
                    selected: _filter == _JournalFilter.photos,
                    onTap: () =>
                        setState(() => _filter = _JournalFilter.photos),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              if (entries.isEmpty)
                AtlasEmptyState(
                  title: 'Nothing in this journal filter yet',
                  message: _filter == _JournalFilter.photos
                      ? 'Imported photo memories will appear here once you attach them to a trip.'
                      : 'Write a memory and it will land here immediately.',
                )
              else
                ...entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AtlasPanel(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF13253B),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            entry.type == MemoryType.photo
                                ? Icons.photo_rounded
                                : Icons.edit_note_rounded,
                          ),
                        ),
                        title: Text(entry.title),
                        subtitle: Text(
                          '${entry.place.fullLabel}\n${entry.body}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: AtlasStatusPill(
                          label: entry.type == MemoryType.photo
                              ? 'Photo'
                              : 'Note',
                          color: entry.type == MemoryType.photo
                              ? const Color(0xFF8DEBFF)
                              : const Color(0xFF67E2B7),
                        ),
                        onTap: () => widget.onOpenCity(entry.place.cityKey),
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}

class _JournalFilterChip extends StatelessWidget {
  const _JournalFilterChip({
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

Future<void> showJournalComposerSheet(
  BuildContext context,
  WidgetRef ref, {
  String? initialTripId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _JournalComposerSheet(initialTripId: initialTripId),
  );
}

Future<void> showPhotoImportSheet(
  BuildContext context,
  WidgetRef ref, {
  String? tripId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _PhotoImportSheet(initialTripId: tripId),
  );
}

class _JournalComposerSheet extends ConsumerStatefulWidget {
  const _JournalComposerSheet({this.initialTripId});

  final String? initialTripId;

  @override
  ConsumerState<_JournalComposerSheet> createState() =>
      _JournalComposerSheetState();
}

class _JournalComposerSheetState extends ConsumerState<_JournalComposerSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  String? _tripId;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _bodyController = TextEditingController();
    _tripId = widget.initialTripId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trips = ref.watch(tripsProvider);
    _tripId ??= trips.first.id;
    final trip = trips.firstWhere(
      (item) => item.id == _tripId,
      orElse: () => trips.first,
    );
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: AtlasPanel(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AtlasSectionHeader(
              title: 'New memory',
              subtitle: 'Drafts save locally first. Sync can catch up later.',
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _tripId,
              items: trips
                  .map(
                    (candidate) => DropdownMenuItem(
                      value: candidate.id,
                      child: Text(candidate.title),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _tripId = value),
              decoration: const InputDecoration(labelText: 'Trip'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bodyController,
              minLines: 4,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'What should future-you remember?',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Will be anchored to ${trip.heroPlace.fullLabel}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: () async {
                    await ref
                        .read(travelAppControllerProvider.notifier)
                        .createJournalEntry(
                          tripId: trip.id,
                          title: _titleController.text.trim().isEmpty
                              ? 'Untitled memory'
                              : _titleController.text.trim(),
                          body: _bodyController.text.trim(),
                          place: trip.heroPlace,
                        );
                    if (!context.mounted) return;
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save draft'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoImportSheet extends ConsumerStatefulWidget {
  const _PhotoImportSheet({this.initialTripId});

  final String? initialTripId;

  @override
  ConsumerState<_PhotoImportSheet> createState() => _PhotoImportSheetState();
}

class _PhotoImportSheetState extends ConsumerState<_PhotoImportSheet> {
  late Future<List<PhotoImportDraft>> _draftsFuture;
  String? _tripId;

  @override
  void initState() {
    super.initState();
    _tripId = widget.initialTripId;
    _draftsFuture = ref
        .read(travelAppControllerProvider.notifier)
        .preparePhotoImportDrafts(tripId: _tripId);
  }

  @override
  Widget build(BuildContext context) {
    final trips = ref.watch(tripsProvider);
    _tripId ??= trips.first.id;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: AtlasPanel(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: FutureBuilder<List<PhotoImportDraft>>(
          future: _draftsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final drafts = snapshot.data ?? const <PhotoImportDraft>[];
            if (drafts.isEmpty) {
              return const SizedBox(
                height: 200,
                child: AtlasEmptyState(
                  title: 'No photos selected',
                  message:
                      'The shared confirmation flow is ready. Select travel photos from the platform picker to continue.',
                ),
              );
            }
            return StatefulBuilder(
              builder: (context, setSheetState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AtlasSectionHeader(
                      title: 'Confirm imported photos',
                      subtitle:
                          'Platform metadata is extracted natively. Place inference is shared.',
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _tripId,
                      items: trips
                          .map(
                            (trip) => DropdownMenuItem(
                              value: trip.id,
                              child: Text(trip.title),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() => _tripId = value),
                      decoration: const InputDecoration(
                        labelText: 'Attach to trip',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: drafts.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final draft = drafts[index];
                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF13253B),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0D1728),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    draft.metadata.previewLabel,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelLarge,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        draft.metadata.displayName,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${draft.metadata.format} • ${formatLongDate(draft.metadata.takenAt)}',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Suggested place: ${draft.selectedPlace.fullLabel}',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.labelLarge,
                                      ),
                                      Text(
                                        draft.suggestion.reason,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () async {
                        await ref
                            .read(travelAppControllerProvider.notifier)
                            .importPhotoDrafts(
                              tripId: _tripId!,
                              drafts: drafts,
                            );
                        if (!context.mounted) return;
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.cloud_upload_rounded),
                      label: Text('Save ${drafts.length} imports locally'),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
