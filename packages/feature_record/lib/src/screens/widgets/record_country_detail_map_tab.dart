import 'dart:async';

import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../domain/record_travel_graph.dart';
import '../../i18n/record_strings.dart';
import 'record_country_detail_shared.dart';

class RecordCountryMapTab extends StatefulWidget {
  const RecordCountryMapTab({
    super.key,
    required this.projection,
    required this.accentColor,
  });

  final RecordCountryProjection projection;
  final Color accentColor;

  @override
  State<RecordCountryMapTab> createState() => _RecordCountryMapTabState();
}

class _RecordCountryMapTabState extends State<RecordCountryMapTab> {
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
    final plannedRoute = orderedLocations.where((location) => location.isPlanned);
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
            RecordCountryOverviewMetricCard(
              label: strings.isKorean ? '도시 레이어' : 'City layer',
              value: '${widget.projection.cityCount}',
              icon: Icons.location_city_rounded,
              accentColor: widget.accentColor,
            ),
            RecordCountryOverviewMetricCard(
              label: strings.isKorean ? '경유 지점' : 'Stops',
              value: '${orderedLocations.length}',
              icon: Icons.route_rounded,
              accentColor: widget.accentColor,
            ),
            RecordCountryOverviewMetricCard(
              label: strings.isKorean ? '예정 정차' : 'Planned',
              value: '${widget.projection.plannedStopCount}',
              icon: Icons.flag_circle_rounded,
              accentColor: widget.accentColor,
            ),
          ],
        ),
        const SizedBox(height: 18),
        RecordCountrySectionHeader(
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
              RecordCountryLocationChip(
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

class RecordCountryLocationChip extends StatelessWidget {
  const RecordCountryLocationChip({
    super.key,
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
