import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../components/record_page_intro.dart';
import '../i18n/record_strings.dart';
import '../models/record_models.dart';
import '../providers/record_provider.dart';
import 'record_trip_detail_screen.dart';

class RecordArchiveScreen extends ConsumerStatefulWidget {
  const RecordArchiveScreen({super.key});

  @override
  ConsumerState<RecordArchiveScreen> createState() =>
      _RecordArchiveScreenState();
}

class _RecordArchiveScreenState extends ConsumerState<RecordArchiveScreen> {
  String _selectedContinent = 'All';

  @override
  Widget build(BuildContext context) {
    final strings = RecordStrings.of(context);
    final theme = Theme.of(context);
    final trips = ref.watch(recordTripsProvider);
    final pastTrips = trips.where((trip) => !trip.isUpcoming).toList()
      ..sort(
        (a, b) =>
            DateTime.parse(b.startDate).compareTo(DateTime.parse(a.startDate)),
      );

    final continents = <String>{
      for (final trip in pastTrips) trip.countries.first.continent,
    }.toList()..sort();
    final filteredTrips = _selectedContinent == 'All'
        ? pastTrips
        : pastTrips
              .where(
                (trip) => trip.countries.first.continent == _selectedContinent,
              )
              .toList();

    final groupedTrips = <String, List<RecordTrip>>{};
    for (final trip in filteredTrips) {
      groupedTrips.putIfAbsent(trip.countries.first.name, () => []).add(trip);
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: AtlasBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      RecordPageIntro(
                        eyebrow: strings.text('nav.archive'),
                        title: strings.text('archive.title'),
                        subtitle: strings.pastTrips(
                          pastTrips.length,
                          filteredTrips.length,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _ContinentChip(
                              label: strings.text('archive.allCompanions'),
                              selected: _selectedContinent == 'All',
                              onTap: () =>
                                  setState(() => _selectedContinent = 'All'),
                            ),
                            for (final continent in continents)
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: _ContinentChip(
                                  label: continent,
                                  selected: _selectedContinent == continent,
                                  onTap: () => setState(
                                    () => _selectedContinent = continent,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (filteredTrips.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: AtlasEmptyState(
                        title: strings.text('archive.empty'),
                        message: strings.text('nav.create'),
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      for (final entry in groupedTrips.entries) ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 14),
                          child: Text(
                            entry.key.toUpperCase(),
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.3,
                              color: const Color(0xFFF59E0B),
                            ),
                          ),
                        ),
                        for (final trip in entry.value)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _ArchiveTripCard(trip: trip),
                          ),
                      ],
                      const SizedBox(height: 120),
                    ]),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContinentChip extends StatelessWidget {
  const _ContinentChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.atlasPalette;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      backgroundColor: palette.surfaceMuted,
      selectedColor: palette.accentSoft.withValues(alpha: 0.2),
      side: BorderSide(color: selected ? palette.accentSoft : palette.outline),
      labelStyle: TextStyle(
        color: selected
            ? palette.accentSoft
            : Theme.of(context).colorScheme.onSurface,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _ArchiveTripCard extends StatelessWidget {
  const _ArchiveTripCard({required this.trip});

  final RecordTrip trip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tripColor = Color(int.parse(trip.color.replaceAll('#', '0xFF')));
    final startDate = DateTime.parse(trip.startDate);
    final endDate = DateTime.parse(trip.endDate);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RecordTripDetailScreen(tripId: trip.id),
          ),
        );
      },
      borderRadius: BorderRadius.circular(24),
      child: AtlasPanel(
        padding: EdgeInsets.zero,
        child: Row(
          children: [
            Container(
              width: 108,
              height: 128,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(26),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    tripColor.withValues(alpha: 0.95),
                    tripColor.withValues(alpha: 0.46),
                  ],
                ),
              ),
              child: const Icon(
                Icons.public_rounded,
                color: Colors.white,
                size: 34,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${DateFormat('MMM d, yyyy').format(startDate)} - ${DateFormat('MMM d, yyyy').format(endDate)}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      trip.description,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        AtlasStatusPill(
                          label: trip.countries.first.continent,
                          color: tripColor,
                          icon: Icons.flight_rounded,
                        ),
                        AtlasStatusPill(
                          label: '${trip.locations.length} stops',
                          color: context.atlasPalette.accentSoft,
                          icon: Icons.route_rounded,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
