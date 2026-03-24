import 'dart:async';

import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import '../domain/record_travel_graph.dart';
import '../i18n/record_strings.dart';
import '../providers/record_provider.dart';

class RecordCountryDetailScreen extends ConsumerStatefulWidget {
  const RecordCountryDetailScreen({super.key, required this.countryCode});

  final String countryCode;

  @override
  ConsumerState<RecordCountryDetailScreen> createState() =>
      _RecordCountryDetailScreenState();
}

class _RecordCountryDetailScreenState
    extends ConsumerState<RecordCountryDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = RecordStrings.of(context);
    final projection =
        ref.watch(recordCountryProjectionProvider(widget.countryCode));

    if (projection == null) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: AtlasEmptyState(
            title: strings.text('trip.noMap'),
            message: strings.text('home.empty'),
          ),
        ),
      );
    }

    final accentColor = _colorFromHex(projection.accentColor);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 288,
              pinned: true,
              backgroundColor: theme.scaffoldBackgroundColor,
              surfaceTintColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                background: _CountryHero(
                  projection: projection,
                  accentColor: accentColor,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                child: _CountryOverviewStrip(
                  projection: projection,
                  accentColor: accentColor,
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _CountryTabHeader(
                TabBar(
                  controller: _tabController,
                  indicatorColor: accentColor,
                  tabs: [
                    Tab(
                      icon: const Icon(Icons.map_rounded),
                      text: strings.text('trip.map'),
                    ),
                    Tab(
                      icon: const Icon(Icons.timeline_rounded),
                      text: strings.text('trip.timeline'),
                    ),
                    Tab(
                      icon: const Icon(Icons.photo_library_rounded),
                      text: strings.isKorean ? '앨범' : 'Album',
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
            _CountryMapTab(
              projection: projection,
              accentColor: accentColor,
            ),
            _CountryTimelineTab(
              projection: projection,
              accentColor: accentColor,
            ),
            _CountryAlbumTab(
              projection: projection,
              accentColor: accentColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _CountryHero extends StatelessWidget {
  const _CountryHero({
    required this.projection,
    required this.accentColor,
  });

  final RecordCountryProjection projection;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = RecordStrings.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withValues(alpha: 0.96),
            accentColor.withValues(alpha: 0.48),
            theme.scaffoldBackgroundColor,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 76),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _RoundHeroButton(
                icon: Icons.arrow_back_rounded,
                onTap: () => Navigator.of(context).maybePop(),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      AtlasStatusPill(
                        label: projection.continent,
                        color: Colors.white,
                        icon: Icons.public_rounded,
                      ),
                      AtlasStatusPill(
                        label: _signalLabel(strings, projection.signal),
                        color: Colors.white.withValues(alpha: 0.24),
                        icon: projection.hasUpcomingTrip
                            ? Icons.flight_takeoff_rounded
                            : Icons.auto_graph_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    projection.name,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    strings.isKorean
                        ? '하나의 여행 그래프를 지도, 타임라인, 앨범 세 가지 투영으로 정리했습니다.'
                        : 'One travel graph, rendered as map, timeline, and album projections.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _HeroMetric(
                        label: strings.profileTrips(projection.tripCount),
                        value: '${projection.tripCount}',
                      ),
                      _HeroMetric(
                        label: strings.timelineEntries(projection.visitCount),
                        value: '${projection.visitCount}',
                      ),
                      _HeroMetric(
                        label: strings.isKorean ? '도시' : 'Cities',
                        value: '${projection.cityCount}',
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountryOverviewStrip extends StatelessWidget {
  const _CountryOverviewStrip({
    required this.projection,
    required this.accentColor,
  });

  final RecordCountryProjection projection;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final strings = RecordStrings.of(context);

    return AtlasPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.isKorean ? '국가 레벨 요약' : 'Country summary',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            strings.isKorean
                ? '방문 강도, 예정 여행, 최근 활동 신호를 같은 모델에서 계산합니다.'
                : 'Visit intensity, planned travel, and recency are derived from the same graph.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _OverviewMetricCard(
                label: strings.isKorean ? '활동 점수' : 'Activity',
                value: projection.activityScore.toStringAsFixed(1),
                icon: Icons.auto_graph_rounded,
                accentColor: accentColor,
              ),
              _OverviewMetricCard(
                label: strings.isKorean ? '기록 일수' : 'Days',
                value: '${projection.totalDays}',
                icon: Icons.calendar_month_rounded,
                accentColor: accentColor,
              ),
              _OverviewMetricCard(
                label: strings.isKorean ? '사진' : 'Photos',
                value: '${projection.photoCount}',
                icon: Icons.photo_library_rounded,
                accentColor: accentColor,
              ),
              _OverviewMetricCard(
                label: strings.isKorean ? '예정 정차' : 'Planned stops',
                value: '${projection.plannedStopCount}',
                icon: Icons.flight_takeoff_rounded,
                accentColor: accentColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CountryMapTab extends StatefulWidget {
  const _CountryMapTab({
    required this.projection,
    required this.accentColor,
  });

  final RecordCountryProjection projection;
  final Color accentColor;

  @override
  State<_CountryMapTab> createState() => _CountryMapTabState();
}

class _CountryMapTabState extends State<_CountryMapTab> {
  final Completer<GoogleMapController> _controller = Completer();

  Future<void> _fitProjectionBounds(GoogleMapController controller) async {
    final projection = widget.projection;
    final hasBounds = projection.minLat != projection.maxLat ||
        projection.minLng != projection.maxLng;

    if (!hasBounds) {
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(projection.centerLat, projection.centerLng),
            zoom: 5.4,
          ),
        ),
      );
      return;
    }

    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(projection.minLat, projection.minLng),
          northeast: LatLng(projection.maxLat, projection.maxLng),
        ),
        54,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = RecordStrings.of(context);
    final orderedLocations = [...widget.projection.locations]
      ..sort((a, b) => a.date.compareTo(b.date));

    if (orderedLocations.isEmpty) {
      return Center(child: Text(strings.text('trip.noMap')));
    }

    final visitedRoute =
        orderedLocations.where((location) => !location.isPlanned);
    final plannedRoute =
        orderedLocations.where((location) => location.isPlanned);
    final uniqueCities = <String>{
      for (final location in orderedLocations) location.name,
    }.toList(growable: false);

    return ListView(
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
                      strings.isKorean ? '2D 국가 지도' : '2D country map',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                  AtlasStatusPill(
                    label: widget.projection.hasRecentVisit
                        ? (strings.isKorean ? '최근 활동' : 'Recent activity')
                        : (strings.isKorean ? '아카이브' : 'Archive'),
                    color: widget.accentColor,
                    icon: Icons.explore_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                strings.isKorean
                    ? '방문 지점, 예정 정차, 이동 흐름을 하나의 지도에서 이어서 봅니다.'
                    : 'Visited places, planned stops, and route flow stay in one map projection.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 320,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        widget.projection.centerLat,
                        widget.projection.centerLng,
                      ),
                      zoom: 4.2,
                    ),
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    markers: {
                      for (final location in orderedLocations)
                        Marker(
                          markerId: MarkerId(location.id),
                          position: LatLng(location.lat, location.lng),
                          infoWindow: InfoWindow(
                            title: location.name,
                            snippet: location.countryName,
                          ),
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                            location.isPlanned
                                ? BitmapDescriptor.hueOrange
                                : BitmapDescriptor.hueAzure,
                          ),
                        ),
                    },
                    polylines: {
                      if (visitedRoute.length > 1)
                        Polyline(
                          polylineId: const PolylineId('visited-route'),
                          points: [
                            for (final location in visitedRoute)
                              LatLng(location.lat, location.lng),
                          ],
                          color: widget.accentColor,
                          width: 4,
                        ),
                      if (plannedRoute.length > 1)
                        Polyline(
                          polylineId: const PolylineId('planned-route'),
                          points: [
                            for (final location in plannedRoute)
                              LatLng(location.lat, location.lng),
                          ],
                          color: widget.accentColor.withValues(alpha: 0.42),
                          width: 4,
                          patterns: [
                            PatternItem.dash(18),
                            PatternItem.gap(10),
                          ],
                        ),
                    },
                    onMapCreated: (controller) {
                      if (!_controller.isCompleted) {
                        _controller.complete(controller);
                      }
                      unawaited(_fitProjectionBounds(controller));
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _OverviewMetricCard(
              label: strings.isKorean ? '도시 레이어' : 'City layer',
              value: '${widget.projection.cityCount}',
              icon: Icons.location_city_rounded,
              accentColor: widget.accentColor,
            ),
            _OverviewMetricCard(
              label: strings.isKorean ? '경유 지점' : 'Stops',
              value: '${orderedLocations.length}',
              icon: Icons.route_rounded,
              accentColor: widget.accentColor,
            ),
            _OverviewMetricCard(
              label: strings.isKorean ? '예정 정차' : 'Planned',
              value: '${widget.projection.plannedStopCount}',
              icon: Icons.flag_circle_rounded,
              accentColor: widget.accentColor,
            ),
          ],
        ),
        const SizedBox(height: 18),
        _SectionHeader(
          title: strings.isKorean ? '도시 포인트' : 'City points',
          subtitle: strings.isKorean
              ? '국가 내부에서 기록된 도시와 예정 정차를 빠르게 훑습니다.'
              : 'Quickly scan the cities and planned stops linked to this country.',
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final city in uniqueCities.take(14))
              _LocationChip(
                name: city,
                subtitle: strings.isKorean ? '기록됨' : 'Mapped',
                accentColor: widget.accentColor,
              ),
          ],
        ),
      ],
    );
  }
}

class _CountryTimelineTab extends StatelessWidget {
  const _CountryTimelineTab({
    required this.projection,
    required this.accentColor,
  });

  final RecordCountryProjection projection;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final strings = RecordStrings.of(context);

    if (projection.timelineDays.isEmpty) {
      return Center(child: Text(strings.text('trip.noEntries')));
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        _SectionHeader(
          title: strings.isKorean
              ? 'Day / Segment / Moment'
              : 'Day / Segment / Moment',
          subtitle: strings.isKorean
              ? '날짜별로 여행 흐름을 묶고, 순간 단위의 기록과 사진을 아래로 이어 보여줍니다.'
              : 'Grouped by day, then rendered as moments with notes, locations, and photos.',
        ),
        const SizedBox(height: 14),
        for (final day in projection.timelineDays) ...[
          _TimelineDaySection(
            day: day,
            accentColor: accentColor,
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _CountryAlbumTab extends StatelessWidget {
  const _CountryAlbumTab({
    required this.projection,
    required this.accentColor,
  });

  final RecordCountryProjection projection;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final strings = RecordStrings.of(context);

    if (projection.albumMoments.isEmpty) {
      return Center(
        child: Text(
          strings.isKorean
              ? '아직 연결된 사진이 없습니다.'
              : 'No photo-backed moments yet.',
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      itemBuilder: (context, index) {
        final moment = projection.albumMoments[index];
        return _AlbumMomentCard(
          moment: moment,
          accentColor: accentColor,
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemCount: projection.albumMoments.length,
    );
  }
}

class _TimelineDaySection extends StatelessWidget {
  const _TimelineDaySection({
    required this.day,
    required this.accentColor,
  });

  final RecordTimelineDay day;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('EEE, MMM d');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          formatter.format(day.date),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 10),
        for (var index = 0; index < day.moments.length; index++) ...[
          _TimelineMomentCard(
            moment: day.moments[index],
            accentColor: accentColor,
            isLast: index == day.moments.length - 1,
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _TimelineMomentCard extends StatelessWidget {
  const _TimelineMomentCard({
    required this.moment,
    required this.accentColor,
    required this.isLast,
  });

  final RecordTimelineMoment moment;
  final Color accentColor;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final strings = RecordStrings.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: accentColor,
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 96,
                color: accentColor.withValues(alpha: 0.26),
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: AtlasPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        moment.title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                    ),
                    if (moment.isPlanned)
                      AtlasStatusPill(
                        label: strings.isKorean ? '예정' : 'Planned',
                        color: accentColor,
                        icon: Icons.schedule_rounded,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${moment.tripTitle} • ${moment.locationName}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  DateFormat('MMM d, yyyy • HH:mm').format(moment.happenedAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (moment.summary.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    moment.summary,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                if (moment.photoLabels.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final label in moment.photoLabels)
                        _PhotoTag(
                          label: label,
                          accentColor: accentColor,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AlbumMomentCard extends StatelessWidget {
  const _AlbumMomentCard({
    required this.moment,
    required this.accentColor,
  });

  final RecordAlbumMoment moment;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final strings = RecordStrings.of(context);

    return AtlasPanel(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 168,
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(26),
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accentColor.withValues(alpha: 0.96),
                  accentColor.withValues(alpha: 0.58),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AtlasStatusPill(
                  label: moment.isPlanned
                      ? (strings.isKorean ? '예정 여행' : 'Planned trip')
                      : (strings.isKorean ? '기록된 순간' : 'Recorded moment'),
                  color: Colors.white.withValues(alpha: 0.2),
                  icon: Icons.photo_rounded,
                ),
                const Spacer(),
                Text(
                  moment.primaryPhotoLabel,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${moment.tripTitle} • ${moment.locationName}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    AtlasStatusPill(
                      label: strings.isKorean
                          ? '사진 ${moment.photoCount}장'
                          : '${moment.photoCount} photos',
                      color: accentColor,
                      icon: Icons.collections_rounded,
                    ),
                    AtlasStatusPill(
                      label:
                          DateFormat('MMM d, yyyy').format(moment.happenedAt),
                      color: accentColor.withValues(alpha: 0.2),
                      icon: Icons.schedule_rounded,
                    ),
                  ],
                ),
                if (moment.summary.trim().isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(
                    moment.summary,
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

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.82),
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
          ),
        ],
      ),
    );
  }
}

class _OverviewMetricCard extends StatelessWidget {
  const _OverviewMetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 108),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: context.atlasPalette.surfaceMuted,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: context.atlasPalette.outline.withValues(alpha: 0.32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: accentColor),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _RoundHeroButton extends StatelessWidget {
  const _RoundHeroButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Ink(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.16),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}

class _LocationChip extends StatelessWidget {
  const _LocationChip({
    required this.name,
    required this.subtitle,
    required this.accentColor,
  });

  final String name;
  final String subtitle;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: context.atlasPalette.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.atlasPalette.outline.withValues(alpha: 0.32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: accentColor,
                ),
          ),
        ],
      ),
    );
  }
}

class _PhotoTag extends StatelessWidget {
  const _PhotoTag({
    required this.label,
    required this.accentColor,
  });

  final String label;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );
  }
}

class _CountryTabHeader extends SliverPersistentHeaderDelegate {
  const _CountryTabHeader(this.tabBar);

  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant _CountryTabHeader oldDelegate) => false;
}

Color _colorFromHex(String color) {
  final normalized = color.replaceAll('#', '');
  return Color(int.parse('FF$normalized', radix: 16));
}

String _signalLabel(RecordStrings strings, RecordCountrySignal signal) {
  return switch (signal) {
    RecordCountrySignal.neutral => strings.isKorean ? '준비 중' : 'Warm',
    RecordCountrySignal.planned => strings.isKorean ? '예정 여행' : 'Planned',
    RecordCountrySignal.visited => strings.isKorean ? '방문 기록' : 'Visited',
  };
}
