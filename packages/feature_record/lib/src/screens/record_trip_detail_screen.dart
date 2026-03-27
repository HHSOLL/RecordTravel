import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import '../i18n/record_strings.dart';
import '../models/record_models.dart';
import '../providers/record_provider.dart';
import 'widgets/record_map_runtime.dart';

class RecordTripDetailScreen extends ConsumerStatefulWidget {
  const RecordTripDetailScreen({super.key, required this.tripId});

  final String tripId;

  @override
  ConsumerState<RecordTripDetailScreen> createState() =>
      _RecordTripDetailScreenState();
}

class _RecordTripDetailScreenState extends ConsumerState<RecordTripDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = RecordStrings.of(context);
    final trips = ref.watch(recordTripsProvider);
    final trip = trips.firstWhere((item) => item.id == widget.tripId);
    final tripColor = Color(int.parse(trip.color.replaceAll('#', '0xFF')));
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 260,
              pinned: true,
              backgroundColor: theme.scaffoldBackgroundColor,
              surfaceTintColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        tripColor.withValues(alpha: 0.96),
                        tripColor.withValues(alpha: 0.52),
                        theme.scaffoldBackgroundColor,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 74),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AtlasStatusPill(
                            label: trip.countries.first.continent,
                            color: Colors.white,
                            icon: Icons.public_rounded,
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
                            trip.description,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TripTabHeader(
                TabBar(
                  controller: _tabController,
                  indicatorColor: tripColor,
                  tabs: [
                    Tab(
                      icon: const Icon(Icons.timeline_rounded),
                      text: strings.text('trip.timeline'),
                    ),
                    Tab(
                      icon: const Icon(Icons.map_rounded),
                      text: strings.text('trip.map'),
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _TripTimelineTab(trip: trip, accentColor: tripColor),
            _TripMapTab(trip: trip, accentColor: tripColor),
          ],
        ),
      ),
    );
  }
}

class _TripTimelineTab extends StatelessWidget {
  const _TripTimelineTab({required this.trip, required this.accentColor});

  final RecordTrip trip;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final strings = RecordStrings.of(context);
    final theme = Theme.of(context);
    if (trip.locations.isEmpty) {
      return Center(
        child: Text(strings.text('trip.noEntries'),
            style: theme.textTheme.bodyMedium),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
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
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
                if (index != trip.locations.length - 1)
                  Container(
                    width: 2,
                    height: location.photos.isEmpty ? 90 : 126,
                    color: accentColor.withValues(alpha: 0.28),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: AtlasPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        DateFormat('MMM d, yyyy • HH:mm').format(
                          DateTime.parse(location.date),
                        ),
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 10),
                      if (location.photos.isEmpty)
                        Text(
                          strings.text('common.note'),
                          style: theme.textTheme.bodyMedium,
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final label in location.photos)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: context.atlasPalette.surfaceMuted,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: context.atlasPalette.outline,
                                  ),
                                ),
                                child: Text(
                                  '${strings.text('common.photo')} • $label',
                                  style: theme.textTheme.labelLarge,
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TripMapTab extends ConsumerWidget {
  const _TripMapTab({required this.trip, required this.accentColor});

  final RecordTrip trip;
  final Color accentColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = RecordStrings.of(context);
    if (trip.locations.isEmpty) {
      return Center(child: Text(strings.text('trip.noMap')));
    }
    final capability = ref.watch(recordMapRuntimeCapabilityProvider);
    final initial = trip.locations.first;
    return switch (capability) {
      AsyncData(value: RecordMapRuntimeCapability.available) => GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(initial.lat, initial.lng),
          zoom: 4.7,
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
              points:
                  trip.locations.map((loc) => LatLng(loc.lat, loc.lng)).toList(),
              color: accentColor,
              width: 3,
            ),
        },
      ),
      AsyncLoading() => const Padding(
        padding: EdgeInsets.all(20),
        child: RecordMapLoadingSurface(),
      ),
      _ => Padding(
        padding: const EdgeInsets.all(20),
        child: RecordMapUnavailableSurface(accentColor: accentColor),
      ),
    };
  }
}

class _TripTabHeader extends SliverPersistentHeaderDelegate {
  const _TripTabHeader(this.tabBar);

  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant _TripTabHeader oldDelegate) => false;
}
