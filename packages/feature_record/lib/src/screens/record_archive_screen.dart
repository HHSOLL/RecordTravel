import 'dart:math' as math;

import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../components/record_metric_grid.dart';
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
  String? _selectedContinent;

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
    }.toList()
      ..sort();
    final filteredTrips = _selectedContinent == null
        ? pastTrips
        : pastTrips
            .where(
              (trip) => trip.countries.first.continent == _selectedContinent,
            )
            .toList();

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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RecordPageIntro(
                        eyebrow: strings.text('nav.archive'),
                        title: strings.text('archive.title'),
                        subtitle: strings.pastTrips(
                          pastTrips.length,
                          filteredTrips.length,
                        ),
                        showTitle: false,
                      ),
                      const SizedBox(height: 20),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _ContinentChip(
                              label: strings.text('archive.allCompanions'),
                              selected: _selectedContinent == null,
                              onTap: () =>
                                  setState(() => _selectedContinent = null),
                            ),
                            for (final continent in continents)
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: _ContinentChip(
                                  label: strings.continentLabel(continent),
                                  selected: _selectedContinent == continent,
                                  onTap: () => setState(
                                    () => _selectedContinent = continent,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      RecordMetricGrid(
                        spacing: 12,
                        children: [
                          AtlasMiniMetric(
                            minWidth: 0,
                            label: strings.text('archive.trips'),
                            value: '${filteredTrips.length}',
                            icon: Icons.workspaces_rounded,
                          ),
                          AtlasMiniMetric(
                            minWidth: 0,
                            label: strings.text('archive.countries'),
                            value:
                                '${filteredTrips.map((trip) => trip.countries.first.code).toSet().length}',
                            icon: Icons.public_rounded,
                          ),
                          AtlasMiniMetric(
                            minWidth: 0,
                            label: strings.text('archive.continents'),
                            value:
                                '${filteredTrips.map((trip) => trip.countries.first.continent).toSet().length}',
                            icon: Icons.flight_rounded,
                          ),
                        ],
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
                  sliver: SliverLayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisExtent = constraints.crossAxisExtent;
                      final crossAxisCount = switch (crossAxisExtent) {
                        >= 920 => 3,
                        >= 280 => 2,
                        _ => 1,
                      };
                      const spacing = 14.0;
                      final tileWidth = (crossAxisExtent -
                              spacing * math.max(0, crossAxisCount - 1)) /
                          crossAxisCount;
                      final aspectRatio = tileWidth < 180
                          ? 0.72
                          : tileWidth < 320
                              ? 0.82
                              : 0.92;

                      if (crossAxisCount == 1) {
                        return SliverList(
                          delegate:
                              SliverChildBuilderDelegate((context, index) {
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom:
                                    index == filteredTrips.length - 1 ? 0 : 14,
                              ),
                              child: AspectRatio(
                                aspectRatio: aspectRatio,
                                child: _ArchiveTripCard(
                                  trip: filteredTrips[index],
                                ),
                              ),
                            );
                          }, childCount: filteredTrips.length),
                        );
                      }
                      return SliverGrid(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return _ArchiveTripCard(trip: filteredTrips[index]);
                        }, childCount: filteredTrips.length),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: spacing,
                          crossAxisSpacing: spacing,
                          childAspectRatio: aspectRatio,
                        ),
                      );
                    },
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
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
  const _ArchiveTripCard({
    required this.trip,
  });

  final RecordTrip trip;

  @override
  Widget build(BuildContext context) {
    final strings = RecordStrings.of(context);
    final theme = Theme.of(context);
    final tripColor = Color(int.parse(trip.color.replaceAll('#', '0xFF')));
    final startDate = DateTime.parse(trip.startDate);
    final endDate = DateTime.parse(trip.endDate);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compactCard = constraints.maxWidth < 340;
        final heroHeight = (constraints.maxWidth * (compactCard ? 0.44 : 0.40))
            .clamp(128.0, 156.0);
        final bodyPadding = compactCard ? 10.0 : 14.0;
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: heroHeight,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(26),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        tripColor.withValues(alpha: 0.96),
                        tripColor.withValues(alpha: 0.60),
                        tripColor.withValues(alpha: 0.30),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ArchiveInfoPill(
                        label: strings.continentLabel(
                          trip.countries.first.continent,
                        ),
                        color: Colors.white,
                        icon: Icons.public_rounded,
                      ),
                      const Spacer(),
                      Icon(
                        Icons.public_rounded,
                        color: Colors.white.withValues(alpha: 0.92),
                        size: compactCard ? 26 : 30,
                      ),
                      SizedBox(height: compactCard ? 10 : 12),
                      Text(
                        trip.title,
                        style: (compactCard
                                ? theme.textTheme.titleMedium
                                : theme.textTheme.titleLarge)
                            ?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(bodyPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${DateFormat('MMM d').format(startDate)} - ${DateFormat('MMM d, yyyy').format(endDate)}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: compactCard ? 6 : 8),
                            Text(
                              trip.description,
                              style: theme.textTheme.bodyMedium,
                              maxLines: compactCard ? 1 : 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        SizedBox(height: compactCard ? 6 : 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _ArchiveInfoPill(
                              label: trip.countries.first.name,
                              color: tripColor,
                              icon: Icons.flight_rounded,
                            ),
                            _ArchiveInfoPill(
                              label: strings.stopCount(trip.locations.length),
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
      },
    );
  }
}

class _ArchiveInfoPill extends StatelessWidget {
  const _ArchiveInfoPill({
    required this.label,
    required this.color,
    this.icon,
  });

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: 0.26)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 12, color: color),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
