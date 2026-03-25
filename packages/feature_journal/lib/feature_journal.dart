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
                trailing: const AtlasOrbitalGraphic(
                  size: 94,
                  glowColor: Color(0xFF67E2B7),
                ),
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
  PhotoIngestionScope scope = PhotoIngestionScope.selection,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _PhotoImportSheet(initialTripId: tripId, scope: scope),
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
            const AtlasHeroPanel(
              eyebrow: 'Write',
              title:
                  'A memory draft should feel lightweight, not like filling out a form.',
              message:
                  'Capture the moment first. Place and sync can catch up later without making the writing surface feel heavy.',
              trailing: AtlasOrbitalGraphic(
                size: 82,
                glowColor: Color(0xFF67E2B7),
              ),
            ),
            const SizedBox(height: 16),
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
  const _PhotoImportSheet({
    this.initialTripId,
    required this.scope,
  });

  final String? initialTripId;
  final PhotoIngestionScope scope;

  @override
  ConsumerState<_PhotoImportSheet> createState() => _PhotoImportSheetState();
}

class _PhotoImportSheetState extends ConsumerState<_PhotoImportSheet> {
  late Future<List<PhotoImportDraft>> _draftsFuture;
  String? _tripId;

  @override
  void initState() {
    super.initState();
    final trips = ref.read(tripsProvider);
    _tripId = widget.initialTripId ?? (trips.isEmpty ? null : trips.first.id);
    _draftsFuture = _loadDrafts();
  }

  Future<List<PhotoImportDraft>> _loadDrafts() {
    return ref
        .read(travelAppControllerProvider.notifier)
        .preparePhotoImportDrafts(tripId: _tripId, scope: widget.scope);
  }

  void _handleTripChanged(String? value) {
    if (value == null || value == _tripId) {
      return;
    }
    setState(() {
      _tripId = value;
      _draftsFuture = _loadDrafts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final trips = ref.watch(tripsProvider);
    if (trips.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const AtlasPanel(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: SizedBox(
            height: 200,
            child: Center(
              child: AtlasEmptyState(
                title: 'Create a trip first',
                message:
                    'Photo import needs a destination trip so auto-placement can stay coherent.',
              ),
            ),
          ),
        ),
      );
    }
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
            final isLibrary = widget.scope == PhotoIngestionScope.library;
            if (drafts.isEmpty) {
              return SizedBox(
                height: 200,
                child: AtlasEmptyState(
                  title: isLibrary
                      ? 'No gallery photos were available'
                      : 'No photos selected',
                  message: isLibrary
                      ? 'Grant photo access and try scanning the gallery again.'
                      : 'Select travel photos from the platform picker to continue.',
                ),
              );
            }
            return StatefulBuilder(
              builder: (context, setSheetState) {
                final selectedTrip = trips.firstWhere(
                  (trip) => trip.id == _tripId,
                  orElse: () => trips.first,
                );
                final review = _buildPhotoImportReviewProjection(drafts);
                final importableDrafts = review.autoResolved;
                final readyPreview = isLibrary
                    ? review.autoResolved.take(3).toList(growable: false)
                    : review.autoResolved;
                final unresolvedCount = drafts.length - importableDrafts.length;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AtlasHeroPanel(
                      eyebrow: isLibrary ? 'Library import' : 'Photo import',
                      title: isLibrary
                          ? 'Scan first, auto-place second, review only what is uncertain.'
                          : 'Bring in the ready moments first and inspect the uncertain ones separately.',
                      message: isLibrary
                          ? 'Gallery metadata already ran through place inference. This sheet now separates ready imports from the photos that still need a human decision.'
                          : 'Native metadata extraction is done. Confirm the destination trip, then queue the photos that already have a confident place match.',
                      trailing: const AtlasOrbitalGraphic(size: 82),
                      metrics: [
                        AtlasMiniMetric(
                          label: 'Scanned',
                          value: '${drafts.length}',
                          icon: Icons.photo_library_rounded,
                        ),
                        AtlasMiniMetric(
                          label: 'Ready',
                          value: '${review.autoResolved.length}',
                          icon: Icons.auto_awesome_rounded,
                        ),
                        AtlasMiniMetric(
                          label: 'Review',
                          value: '${review.needsReviewCount}',
                          icon: Icons.fact_check_rounded,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AtlasSectionHeader(
                      title: isLibrary
                          ? 'Import destination'
                          : 'Destination trip',
                      subtitle: isLibrary
                          ? 'Auto-resolved photos will attach here. Review items stay separate until you confirm them.'
                          : 'Ready photos queue into this trip. Uncertain items stay in review instead of being force-attached.',
                    ),
                    const SizedBox(height: 12),
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
                      onChanged: _handleTripChanged,
                      decoration: const InputDecoration(
                        labelText: 'Attach to trip',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _PhotoImportSummaryCard(
                              tripTitle: selectedTrip.title,
                              projection: review,
                            ),
                            if (readyPreview.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              const AtlasSectionHeader(
                                title: 'Auto placement',
                                subtitle:
                                    'These photos already have a confident place match and can queue immediately.',
                              ),
                              const SizedBox(height: 12),
                              for (final draft in readyPreview) ...[
                                _PhotoImportDraftCard(
                                  draft: draft,
                                  statusLabel: 'Ready',
                                  statusColor: const Color(0xFF67E2B7),
                                  helperText:
                                      'Will attach to ${draft.selectedPlace.fullLabel}',
                                  supplementalText: draft.suggestion.reason,
                                ),
                                const SizedBox(height: 10),
                              ],
                              if (review.autoResolved.length > readyPreview.length)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    '${review.autoResolved.length - readyPreview.length} more ready items will follow the same auto-placement rule.',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                            ],
                            if (review.needsPlaceReview.isNotEmpty) ...[
                              const SizedBox(height: 18),
                              const AtlasSectionHeader(
                                title: 'Needs place review',
                                subtitle:
                                    'These photos are missing reliable location metadata or the match is too weak to auto-attach safely.',
                              ),
                              const SizedBox(height: 12),
                              for (final draft in review.needsPlaceReview) ...[
                                _PhotoImportDraftCard(
                                  draft: draft,
                                  statusLabel: 'Check place',
                                  statusColor: const Color(0xFFFFD37A),
                                  helperText:
                                      'Suggested fallback: ${draft.selectedPlace.fullLabel}',
                                  supplementalText: draft.suggestion.reason,
                                ),
                                const SizedBox(height: 10),
                              ],
                            ],
                            if (review.needsTimeReview.isNotEmpty) ...[
                              const SizedBox(height: 18),
                              const AtlasSectionHeader(
                                title: 'Needs time review',
                                subtitle:
                                    'These photos need a timeline decision before they can land in the trip.',
                              ),
                              const SizedBox(height: 12),
                              for (final draft in review.needsTimeReview) ...[
                                _PhotoImportDraftCard(
                                  draft: draft,
                                  statusLabel: 'Check time',
                                  statusColor: const Color(0xFF8DEBFF),
                                  helperText: formatLongDate(
                                    draft.metadata.takenAt,
                                  ),
                                  supplementalText:
                                      'Time review is required before auto-placement.',
                                ),
                                const SizedBox(height: 10),
                              ],
                            ],
                            if (review.duplicateCandidates.isNotEmpty) ...[
                              const SizedBox(height: 18),
                              const AtlasSectionHeader(
                                title: 'Possible duplicates',
                                subtitle:
                                    'These look similar to photos already attached to your travel graph.',
                              ),
                              const SizedBox(height: 12),
                              for (final draft in review.duplicateCandidates) ...[
                                _PhotoImportDraftCard(
                                  draft: draft,
                                  statusLabel: 'Duplicate?',
                                  statusColor: const Color(0xFFFFA6A6),
                                  helperText: draft.selectedPlace.fullLabel,
                                  supplementalText:
                                      'Check before you queue this item again.',
                                ),
                                const SizedBox(height: 10),
                              ],
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (unresolvedCount > 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          '$unresolvedCount item${unresolvedCount == 1 ? '' : 's'} still need review and will stay out of this import batch.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close_rounded),
                            label: const Text('Not now'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: importableDrafts.isEmpty
                                ? null
                                : () async {
                              await ref
                                  .read(travelAppControllerProvider.notifier)
                                  .importPhotoDrafts(
                                    tripId: _tripId!,
                                    drafts: importableDrafts,
                                  );
                              if (!context.mounted) return;
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(Icons.cloud_upload_rounded),
                            label: Text(
                              importableDrafts.isEmpty
                                  ? 'Review required'
                                  : isLibrary
                                  ? 'Queue ${importableDrafts.length} ready items'
                                  : 'Queue ${importableDrafts.length} ready photos',
                            ),
                          ),
                        ),
                      ],
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

String _formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  final kb = bytes / 1024;
  if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
  final mb = kb / 1024;
  return '${mb.toStringAsFixed(1)} MB';
}

class _PhotoImportReviewProjection {
  const _PhotoImportReviewProjection({
    required this.autoResolved,
    required this.needsPlaceReview,
    required this.needsTimeReview,
    required this.duplicateCandidates,
  });

  final List<PhotoImportDraft> autoResolved;
  final List<PhotoImportDraft> needsPlaceReview;
  final List<PhotoImportDraft> needsTimeReview;
  final List<PhotoImportDraft> duplicateCandidates;

  int get needsReviewCount =>
      needsPlaceReview.length +
      needsTimeReview.length +
      duplicateCandidates.length;
}

_PhotoImportReviewProjection _buildPhotoImportReviewProjection(
  List<PhotoImportDraft> drafts,
) {
  final autoResolved = <PhotoImportDraft>[];
  final needsPlaceReview = <PhotoImportDraft>[];
  final needsTimeReview = <PhotoImportDraft>[];
  final duplicateCandidates = <PhotoImportDraft>[];

  for (final draft in drafts) {
    switch (draft.reviewState) {
      case PhotoImportReviewState.autoResolved:
        autoResolved.add(draft);
      case PhotoImportReviewState.needsPlaceReview:
        needsPlaceReview.add(draft);
      case PhotoImportReviewState.needsTimeReview:
        needsTimeReview.add(draft);
      case PhotoImportReviewState.duplicateCandidate:
        duplicateCandidates.add(draft);
    }
  }

  return _PhotoImportReviewProjection(
    autoResolved: autoResolved,
    needsPlaceReview: needsPlaceReview,
    needsTimeReview: needsTimeReview,
    duplicateCandidates: duplicateCandidates,
  );
}

class _PhotoImportSummaryCard extends StatelessWidget {
  const _PhotoImportSummaryCard({
    required this.tripTitle,
    required this.projection,
  });

  final String tripTitle;
  final _PhotoImportReviewProjection projection;

  @override
  Widget build(BuildContext context) {
    final palette = context.atlasPalette;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surfaceMuted,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Scan summary',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          _PhotoImportSummaryLine(
            icon: Icons.luggage_rounded,
            text:
                '${projection.autoResolved.length} item${projection.autoResolved.length == 1 ? '' : 's'} are ready to land in $tripTitle.',
            color: const Color(0xFF67E2B7),
          ),
          if (projection.needsPlaceReview.isNotEmpty) ...[
            const SizedBox(height: 8),
            _PhotoImportSummaryLine(
              icon: Icons.place_rounded,
              text:
                  '${projection.needsPlaceReview.length} item${projection.needsPlaceReview.length == 1 ? '' : 's'} need place confirmation.',
              color: const Color(0xFFFFD37A),
            ),
          ],
          if (projection.needsTimeReview.isNotEmpty) ...[
            const SizedBox(height: 8),
            _PhotoImportSummaryLine(
              icon: Icons.schedule_rounded,
              text:
                  '${projection.needsTimeReview.length} item${projection.needsTimeReview.length == 1 ? '' : 's'} need time review.',
              color: const Color(0xFF8DEBFF),
            ),
          ],
          if (projection.duplicateCandidates.isNotEmpty) ...[
            const SizedBox(height: 8),
            _PhotoImportSummaryLine(
              icon: Icons.copy_rounded,
              text:
                  '${projection.duplicateCandidates.length} item${projection.duplicateCandidates.length == 1 ? '' : 's'} look like duplicates.',
              color: const Color(0xFFFFA6A6),
            ),
          ],
        ],
      ),
    );
  }
}

class _PhotoImportSummaryLine extends StatelessWidget {
  const _PhotoImportSummaryLine({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class _PhotoImportDraftCard extends StatelessWidget {
  const _PhotoImportDraftCard({
    required this.draft,
    required this.statusLabel,
    required this.statusColor,
    required this.helperText,
    required this.supplementalText,
  });

  final PhotoImportDraft draft;
  final String statusLabel;
  final Color statusColor;
  final String helperText;
  final String supplementalText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.atlasPalette.surfaceMuted,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.atlasPalette.outline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: context.atlasPalette.surfacePanel,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Text(
              draft.metadata.previewLabel,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        draft.metadata.displayName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(width: 8),
                    AtlasStatusPill(label: statusLabel, color: statusColor),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${draft.metadata.format} • ${formatLongDate(draft.metadata.takenAt)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  helperText,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  supplementalText,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (draft.metadata.sourcePath == null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Metadata-only asset. The original can remain in the photo library until you need it.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                if (draft.metadata.byteSize != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'File size: ${_formatBytes(draft.metadata.byteSize!)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
