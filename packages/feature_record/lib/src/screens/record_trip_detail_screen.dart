import 'dart:async';

import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../i18n/record_strings.dart';
import '../models/record_models.dart';
import '../providers/record_provider.dart';
import 'widgets/record_naver_route_map.dart';
import 'widgets/record_map_runtime.dart';

class RecordTripDetailScreen extends ConsumerStatefulWidget {
  const RecordTripDetailScreen({
    super.key,
    required this.tripId,
    this.initialTabIndex = 0,
  });

  final String tripId;
  final int initialTabIndex;

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
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 1),
    );
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
    final displayTitle = strings.tripTitle(trip.id, trip.title);
    final displayDescription = strings.tripDescription(
      trip.id,
      trip.description,
    );
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 360,
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
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final compact = constraints.maxHeight < 220 ||
                            constraints.maxWidth < 360;
                        final titleStyle = compact
                            ? theme.textTheme.headlineSmall
                            : theme.textTheme.headlineMedium;
                        return Padding(
                          padding: EdgeInsets.fromLTRB(
                            24,
                            compact ? 12 : 24,
                            24,
                            compact ? 40 : 74,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              AtlasStatusPill(
                                label: strings.continentLabel(
                                  trip.countries.first.continent,
                                ),
                                color: Colors.white,
                                icon: Icons.public_rounded,
                              ),
                              SizedBox(height: compact ? 10 : 18),
                              Text(
                                displayTitle,
                                maxLines: compact ? 1 : 3,
                                overflow: TextOverflow.ellipsis,
                                style: titleStyle?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: compact ? 6 : 8),
                              Text(
                                displayDescription,
                                style: (compact
                                        ? theme.textTheme.bodyMedium
                                        : theme.textTheme.bodyLarge)
                                    ?.copyWith(
                                  color: Colors.white.withValues(
                                    alpha: 0.9,
                                  ),
                                ),
                                maxLines: compact ? 1 : 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      },
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
    final longDateTimeFormat = strings.dateFormat('MMM d, yyyy • HH:mm');
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
                        longDateTimeFormat.format(
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
    return _TripMapSurface(trip: trip, accentColor: accentColor);
  }
}

class _TripMapSurface extends ConsumerStatefulWidget {
  const _TripMapSurface({
    required this.trip,
    required this.accentColor,
  });

  final RecordTrip trip;
  final Color accentColor;

  @override
  ConsumerState<_TripMapSurface> createState() => _TripMapSurfaceState();
}

class _TripMapSurfaceState extends ConsumerState<_TripMapSurface> {
  final Completer<GoogleMapController> _controller = Completer();

  Future<void> _fitTripBounds(GoogleMapController controller) async {
    final orderedLocations = [...widget.trip.locations]
      ..sort((a, b) => a.date.compareTo(b.date));
    if (orderedLocations.isEmpty) {
      return;
    }

    final hasBounds = orderedLocations.any(
      (location) =>
          location.lat != orderedLocations.first.lat ||
          location.lng != orderedLocations.first.lng,
    );

    if (!hasBounds) {
      final only = orderedLocations.first;
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(only.lat, only.lng),
            zoom: 9.6,
          ),
        ),
      );
      return;
    }

    final latitudes = orderedLocations.map((location) => location.lat);
    final longitudes = orderedLocations.map((location) => location.lng);
    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(
            latitudes.reduce((a, b) => a < b ? a : b),
            longitudes.reduce((a, b) => a < b ? a : b),
          ),
          northeast: LatLng(
            latitudes.reduce((a, b) => a > b ? a : b),
            longitudes.reduce((a, b) => a > b ? a : b),
          ),
        ),
        52,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = RecordStrings.of(context);
    final trip = widget.trip;
    if (trip.locations.isEmpty) {
      return Center(child: Text(strings.text('trip.noMap')));
    }
    final runtimeConfig = ref.watch(recordMapRuntimeConfigProvider);
    final orderedLocations = [...trip.locations]
      ..sort((a, b) => a.date.compareTo(b.date));
    final initial = orderedLocations.first;
    final representativeStops = orderedLocations
        .where((location) => location.photos.isNotEmpty)
        .take(6)
        .toList(growable: false);
    final shortDateTimeFormat = strings.dateFormat('MMM d • HH:mm');

    return switch (runtimeConfig) {
      AsyncData(:final value) => switch (recordMapProviderForTrip(
          config: value,
          trip: trip,
        )) {
          RecordMapProviderKind.google => ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              children: [
                AtlasPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              strings.isKorean ? '여행 경로 지도' : 'Trip route map',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ),
                          AtlasStatusPill(
                            label: trip.isUpcoming
                                ? (strings.isKorean ? '예정 여행' : 'Upcoming')
                                : (strings.isKorean
                                    ? '기록된 이동'
                                    : 'Recorded route'),
                            color: widget.accentColor,
                            icon: Icons.route_rounded,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        strings.isKorean
                            ? '타임라인 순서대로 이동 경로를 이어서 보고, 사진이 남은 지점은 대표 컷으로 다시 확인합니다.'
                            : 'Trace the route in timeline order and revisit stops that still carry a representative photo.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        key: Key('record-trip-map-google-${trip.id}'),
                        height: 340,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: LatLng(initial.lat, initial.lng),
                              zoom: 7.2,
                            ),
                            myLocationButtonEnabled: false,
                            zoomControlsEnabled: false,
                            markers: {
                              for (var index = 0;
                                  index < orderedLocations.length;
                                  index++)
                                Marker(
                                  markerId:
                                      MarkerId(orderedLocations[index].id),
                                  position: LatLng(
                                    orderedLocations[index].lat,
                                    orderedLocations[index].lng,
                                  ),
                                  infoWindow: InfoWindow(
                                    title:
                                        '${index + 1}. ${orderedLocations[index].name}',
                                    snippet: orderedLocations[index]
                                            .photos
                                            .isEmpty
                                        ? (strings.isKorean
                                            ? '기록만 있음'
                                            : 'Notes only')
                                        : '${strings.text('common.photo')} • ${orderedLocations[index].photos.first}',
                                  ),
                                  icon: BitmapDescriptor.defaultMarkerWithHue(
                                    orderedLocations[index].photos.isEmpty
                                        ? BitmapDescriptor.hueAzure
                                        : BitmapDescriptor.hueRose,
                                  ),
                                ),
                            },
                            polylines: {
                              if (orderedLocations.length > 1)
                                Polyline(
                                  polylineId: const PolylineId('trip-route'),
                                  points: [
                                    for (final loc in orderedLocations)
                                      LatLng(loc.lat, loc.lng),
                                  ],
                                  color: widget.accentColor,
                                  width: 4,
                                ),
                            },
                            onMapCreated: (controller) {
                              debugPrint(
                                'record: Trip map provider ${trip.id} => google',
                              );
                              if (!_controller.isCompleted) {
                                _controller.complete(controller);
                              }
                              unawaited(_fitTripBounds(controller));
                              debugPrint(
                                'record: Google route map ready trip=${trip.id}',
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (representativeStops.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    strings.isKorean
                        ? '대표 사진 포인트'
                        : 'Representative photo stops',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 118,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: representativeStops.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final stop = representativeStops[index];
                        return SizedBox(
                          width: 188,
                          child: AtlasPanel(
                            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${index + 1}. ${stop.name}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: context.atlasPalette.surfaceMuted,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: context.atlasPalette.outline,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.photo_library_rounded,
                                        size: 16,
                                        color: widget.accentColor,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          stop.photos.first,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelMedium,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  shortDateTimeFormat.format(
                                    DateTime.parse(stop.date),
                                  ),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          RecordMapProviderKind.naver => ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              children: [
                AtlasPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              strings.isKorean ? '여행 경로 지도' : 'Trip route map',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ),
                          AtlasStatusPill(
                            label: trip.isUpcoming
                                ? (strings.isKorean ? '예정 여행' : 'Upcoming')
                                : (strings.isKorean
                                    ? '기록된 이동'
                                    : 'Recorded route'),
                            color: widget.accentColor,
                            icon: Icons.route_rounded,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        strings.isKorean
                            ? '타임라인 순서대로 이동 경로를 이어서 보고, 사진이 남은 지점은 대표 컷으로 다시 확인합니다.'
                            : 'Trace the route in timeline order and revisit stops that still carry a representative photo.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        key: Key('record-trip-map-naver-${trip.id}'),
                        height: 340,
                        child: Builder(
                          builder: (context) {
                            debugPrint(
                              'record: Trip map provider ${trip.id} => naver',
                            );
                            return RecordNaverRouteMap(
                              locations: orderedLocations,
                              accentColor: widget.accentColor,
                              initialZoom: 7.2,
                              singleStopZoom: 10.6,
                              markerTintBuilder: (location, index) =>
                                  location.photos.isEmpty
                                      ? const Color(0xFF43C4FF)
                                      : const Color(0xFFFF5A8B),
                              markerCaptionBuilder: (location, index) =>
                                  '${index + 1}. ${location.name}',
                              boundsPadding: const EdgeInsets.all(52),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                if (representativeStops.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    strings.isKorean
                        ? '대표 사진 포인트'
                        : 'Representative photo stops',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 118,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: representativeStops.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final stop = representativeStops[index];
                        return SizedBox(
                          width: 188,
                          child: AtlasPanel(
                            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${index + 1}. ${stop.name}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: context.atlasPalette.surfaceMuted,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: context.atlasPalette.outline,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.photo_library_rounded,
                                        size: 16,
                                        color: widget.accentColor,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          stop.photos.first,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelMedium,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  shortDateTimeFormat.format(
                                    DateTime.parse(stop.date),
                                  ),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          RecordMapProviderKind.unavailable => Padding(
              padding: const EdgeInsets.all(20),
              child:
                  RecordMapUnavailableSurface(accentColor: widget.accentColor),
            ),
        },
      AsyncLoading() => const Padding(
          padding: EdgeInsets.all(20),
          child: RecordMapLoadingSurface(),
        ),
      _ => Padding(
          padding: const EdgeInsets.all(20),
          child: RecordMapUnavailableSurface(accentColor: widget.accentColor),
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
