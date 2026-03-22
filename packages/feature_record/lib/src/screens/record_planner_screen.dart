import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import '../components/record_page_intro.dart';
import '../i18n/record_strings.dart';
import '../models/record_models.dart';
import '../providers/record_provider.dart';
import 'record_trip_detail_screen.dart';

class RecordPlannerScreen extends ConsumerWidget {
  const RecordPlannerScreen({super.key});

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
                      ),
                      const SizedBox(height: 16),
                      AtlasStatusPill(
                        label: strings.text('planner.planNew'),
                        color: const Color(0xFFF59E0B),
                        icon: Icons.flight_takeoff_rounded,
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
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final trip = upcomingTrips[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: _PlannerTripCard(trip: trip),
                      );
                    }, childCount: upcomingTrips.length),
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

    return AtlasPanel(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(26),
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  tripColor.withValues(alpha: 0.92),
                  tripColor.withValues(alpha: 0.52),
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
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        daysLeft > 0
                            ? 'D-$daysLeft'
                            : (daysLeft == 0 ? 'D-Day' : 'Started'),
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.luggage_rounded,
                      color: Colors.white.withValues(alpha: 0.92),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  trip.title,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  trip.countries.map((country) => country.name).join(' • '),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.88),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${DateFormat('MMM d, yyyy').format(startDate)} - ${DateFormat('MMM d, yyyy').format(endDate)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.82),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip.description,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    AtlasStatusPill(
                      label:
                          '${trip.locations.length} stop${trip.locations.length == 1 ? '' : 's'}',
                      color: tripColor,
                      icon: Icons.route_rounded,
                    ),
                    AtlasStatusPill(
                      label: trip.countries.first.continent,
                      color: palette.accentSoft,
                      icon: Icons.public_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _openMapModal(context, trip),
                        icon: const Icon(Icons.map_outlined),
                        label: Text(strings.text('planner.openMap')),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _openScheduleModal(context, trip),
                        icon: const Icon(Icons.calendar_month_outlined),
                        label: Text(strings.text('planner.schedule')),
                      ),
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                RecordTripDetailScreen(tripId: trip.id),
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: tripColor,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(strings.text('planner.view')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
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

class _MapModal extends StatelessWidget {
  const _MapModal({required this.trip});

  final RecordTrip trip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.atlasPalette;
    final initial = trip.locations.first;
    final tripColor = Color(int.parse(trip.color.replaceAll('#', '0xFF')));

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
            child: ClipRRect(
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
