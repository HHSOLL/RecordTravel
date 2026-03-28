import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import '../components/record_metric_grid.dart';
import '../components/record_page_intro.dart';
import '../i18n/record_strings.dart';
import '../models/record_models.dart';
import '../providers/record_provider.dart';
import 'widgets/record_map_runtime.dart';
import 'record_trip_detail_screen.dart';

class RecordPlannerScreen extends ConsumerWidget {
  const RecordPlannerScreen({
    super.key,
    required this.onImportGallery,
    required this.onCreateTrip,
  });

  final VoidCallback onImportGallery;
  final VoidCallback onCreateTrip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = RecordStrings.of(context);
    final theme = Theme.of(context);
    final trips = ref.watch(recordTripsProvider);
    final upcomingTrips = trips.where((trip) => trip.isUpcoming).toList()
      ..sort(
        (a, b) =>
            DateTime.parse(a.startDate).compareTo(DateTime.parse(b.startDate)),
      );
    final nextTrip = upcomingTrips.isEmpty ? null : upcomingTrips.first;
    final mappedPlaces = upcomingTrips.fold<int>(
      0,
      (total, trip) => total + trip.locations.length,
    );

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
                        eyebrow: strings.text('nav.planner'),
                        title: strings.text('planner.title'),
                        subtitle: strings.upcomingTrips(upcomingTrips.length),
                        showTitle: false,
                      ),
                      const SizedBox(height: 16),
                      AtlasHeroPanel(
                        eyebrow: strings.text('planner.nextDeparture'),
                        title: strings.text('planner.heroTitle'),
                        message: strings.text('planner.heroSubtitle'),
                        trailing: const AtlasOrbitalGraphic(
                          size: 74,
                          glowColor: Color(0xFFF59E0B),
                        ),
                        metrics: [
                          RecordMetricGrid(
                            minTileWidth: 82,
                            children: [
                              AtlasMiniMetric(
                                minWidth: 0,
                                label: strings.text('nav.planner'),
                                value: '${upcomingTrips.length}',
                                icon: Icons.luggage_rounded,
                              ),
                              AtlasMiniMetric(
                                minWidth: 0,
                                label: strings.text('planner.mapped'),
                                value: '$mappedPlaces',
                                icon: Icons.map_rounded,
                              ),
                              AtlasMiniMetric(
                                minWidth: 0,
                                label: strings.text('planner.nextShort'),
                                value: nextTrip?.countries.first.code ?? '--',
                                icon: Icons.flight_takeoff_rounded,
                              ),
                            ],
                          ),
                        ],
                        actions: [
                          FilledButton.icon(
                            onPressed: onImportGallery,
                            icon: const Icon(Icons.photo_library_rounded),
                            label: Text(strings.text('planner.importLibrary')),
                          ),
                          OutlinedButton.icon(
                            onPressed: onCreateTrip,
                            icon: const Icon(Icons.add_rounded),
                            label: Text(strings.text('planner.planNew')),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (upcomingTrips.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: AtlasEmptyState(
                        title: strings.text('planner.noUpcoming'),
                        message: strings.text('planner.planNew'),
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
                      final crossAxisCount = crossAxisExtent < 220 ? 2 : 3;
                      const spacing = 14.0;
                      final tileWidth = (crossAxisExtent -
                              spacing * (crossAxisCount - 1)) /
                          crossAxisCount;
                      final aspectRatio = crossAxisCount == 3
                          ? (tileWidth < 112 ? 0.66 : 0.72)
                          : 0.84;

                      return SliverGrid(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return _PlannerTripCard(trip: upcomingTrips[index]);
                        }, childCount: upcomingTrips.length),
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
            ],
          ),
        ),
      ),
    );
  }
}

class _PlannerTripCard extends StatelessWidget {
  const _PlannerTripCard({required this.trip});

  final RecordTrip trip;

  @override
  Widget build(BuildContext context) {
    final strings = RecordStrings.of(context);
    final theme = Theme.of(context);
    final palette = context.atlasPalette;
    final tripColor = Color(int.parse(trip.color.replaceAll('#', '0xFF')));
    final startDate = DateTime.parse(trip.startDate);
    final endDate = DateTime.parse(trip.endDate);
    final daysLeft = startDate.difference(DateTime.now()).inDays;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compactCard = constraints.maxWidth < 120;
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: EdgeInsets.all(compactCard ? 10 : 12),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(26),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        tripColor.withValues(alpha: 0.94),
                        tripColor.withValues(alpha: 0.62),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              strings.plannerCountdownLabel(daysLeft),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.luggage_rounded,
                            size: compactCard ? 16 : 18,
                            color: Colors.white.withValues(alpha: 0.92),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        trip.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(compactCard ? 10 : 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${DateFormat('MMM d').format(startDate)} - ${DateFormat('MMM d').format(endDate)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          trip.countries.first.name,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: palette.accentSoft,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          trip.description,
                          style: theme.textTheme.bodySmall,
                          maxLines: compactCard ? 2 : 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            AtlasStatusPill(
                              label: '${trip.locations.length}',
                              color: tripColor,
                              icon: Icons.route_rounded,
                            ),
                            AtlasStatusPill(
                              label: strings.continentLabel(
                                trip.countries.first.continent,
                              ),
                              color: palette.accentSoft,
                              icon: Icons.public_rounded,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _PlannerActionButton(
                                icon: Icons.map_outlined,
                                onTap: () => _openMapModal(context, trip),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _PlannerActionButton(
                                icon: Icons.calendar_month_outlined,
                                onTap: () => _openScheduleModal(context, trip),
                              ),
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

  void _openMapModal(BuildContext context, RecordTrip trip) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MapModal(trip: trip),
    );
  }

  void _openScheduleModal(BuildContext context, RecordTrip trip) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ScheduleModal(trip: trip),
    );
  }
}

class _PlannerActionButton extends StatelessWidget {
  const _PlannerActionButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
      ),
      child: Icon(icon, size: 18),
    );
  }
}

class _MapModal extends ConsumerWidget {
  const _MapModal({required this.trip});

  final RecordTrip trip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final palette = context.atlasPalette;
    final initial = trip.locations.first;
    final tripColor = Color(int.parse(trip.color.replaceAll('#', '0xFF')));
    final capability = ref.watch(recordMapRuntimeCapabilityProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.76,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(trip.title, style: theme.textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text(
                        '${trip.locations.length} mapped places',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded, color: palette.accentSoft),
                ),
              ],
            ),
          ),
          Expanded(
            child: switch (capability) {
              AsyncData(value: RecordMapRuntimeCapability.available) =>
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(26),
                  ),
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(initial.lat, initial.lng),
                      zoom: 4.6,
                    ),
                    myLocationButtonEnabled: false,
                    markers: trip.locations
                        .map(
                          (loc) => Marker(
                            markerId: MarkerId(loc.id),
                            position: LatLng(loc.lat, loc.lng),
                            infoWindow: InfoWindow(title: loc.name),
                          ),
                        )
                        .toSet(),
                    polylines: {
                      if (trip.locations.length > 1)
                        Polyline(
                          polylineId: const PolylineId('route'),
                          points: trip.locations
                              .map((loc) => LatLng(loc.lat, loc.lng))
                              .toList(),
                          color: tripColor,
                          width: 3,
                        ),
                    },
                  ),
                ),
              AsyncLoading() => const Padding(
                  padding: EdgeInsets.all(20),
                  child: RecordMapLoadingSurface(),
                ),
              _ => Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: RecordMapUnavailableSurface(accentColor: tripColor),
                ),
            },
          ),
        ],
      ),
    );
  }
}

class _ScheduleModal extends StatelessWidget {
  const _ScheduleModal({required this.trip});

  final RecordTrip trip;

  @override
  Widget build(BuildContext context) {
    final strings = RecordStrings.of(context);
    final theme = Theme.of(context);
    final tripColor = Color(int.parse(trip.color.replaceAll('#', '0xFF')));

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(trip.title, style: theme.textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text(
                        '${DateFormat('MMM d').format(DateTime.parse(trip.startDate))} - ${DateFormat('MMM d').format(DateTime.parse(trip.endDate))}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          Expanded(
            child: trip.locations.isEmpty
                ? Center(
                    child: Text(
                      strings.text('trip.noEntries'),
                      style: theme.textTheme.bodyMedium,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: trip.locations.length,
                    itemBuilder: (context, index) {
                      final location = trip.locations[index];
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: tripColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              if (index != trip.locations.length - 1)
                                Container(
                                  width: 2,
                                  height: 72,
                                  color: tripColor.withValues(alpha: 0.28),
                                ),
                            ],
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 18),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: context.atlasPalette.surfaceMuted,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: context.atlasPalette.outline,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    location.name,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    DateFormat(
                                      'MMM d, yyyy • HH:mm',
                                    ).format(DateTime.parse(location.date)),
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
