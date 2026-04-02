import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

import '../../models/record_models.dart';

typedef RecordMarkerTintBuilder = Color Function(
  RecordLocation location,
  int index,
);

typedef RecordMarkerCaptionBuilder = String Function(
  RecordLocation location,
  int index,
);

class RecordNaverRouteMap extends StatefulWidget {
  const RecordNaverRouteMap({
    super.key,
    required this.locations,
    required this.accentColor,
    required this.initialZoom,
    this.singleStopZoom = 9.8,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.boundsPadding = const EdgeInsets.all(54),
    this.splitPlannedRoute = false,
    this.markerTintBuilder,
    this.markerCaptionBuilder,
  });

  final List<RecordLocation> locations;
  final Color accentColor;
  final double initialZoom;
  final double singleStopZoom;
  final BorderRadius borderRadius;
  final EdgeInsets boundsPadding;
  final bool splitPlannedRoute;
  final RecordMarkerTintBuilder? markerTintBuilder;
  final RecordMarkerCaptionBuilder? markerCaptionBuilder;

  @override
  State<RecordNaverRouteMap> createState() => _RecordNaverRouteMapState();
}

class _RecordNaverRouteMapState extends State<RecordNaverRouteMap> {
  Future<void> _configureMap(NaverMapController controller) async {
    if (kDebugMode) {
      debugPrint(
        'record: Naver route map ready '
        '(stops=${widget.locations.length}, split=${widget.splitPlannedRoute})',
      );
    }
    await controller.clearOverlays();

    final locations = widget.locations;
    for (var index = 0; index < locations.length; index += 1) {
      final location = locations[index];
      final marker = NMarker(
        id: location.id,
        position: NLatLng(location.lat, location.lng),
        iconTintColor: widget.markerTintBuilder?.call(location, index) ??
            widget.accentColor,
        caption: NOverlayCaption(
          text: widget.markerCaptionBuilder?.call(location, index) ??
              location.name,
          color: Colors.white,
          haloColor: const Color(0xFF111827),
          textSize: 12,
          requestWidth: 120,
        ),
      );
      await controller.addOverlay(marker);
    }

    if (widget.splitPlannedRoute) {
      final visitedRoute = locations.where((location) => !location.isPlanned);
      final plannedRoute = locations.where((location) => location.isPlanned);

      if (visitedRoute.length > 1) {
        await controller.addOverlay(
          NPolylineOverlay(
            id: 'visited-route',
            coords: [
              for (final location in visitedRoute)
                NLatLng(location.lat, location.lng),
            ],
            color: widget.accentColor,
            width: 4,
          ),
        );
      }

      if (plannedRoute.length > 1) {
        await controller.addOverlay(
          NPolylineOverlay(
            id: 'planned-route',
            coords: [
              for (final location in plannedRoute)
                NLatLng(location.lat, location.lng),
            ],
            color: widget.accentColor.withValues(alpha: 0.42),
            width: 4,
            pattern: const [18, 10],
          ),
        );
      }
    } else if (locations.length > 1) {
      await controller.addOverlay(
        NPolylineOverlay(
          id: 'trip-route',
          coords: [
            for (final location in locations)
              NLatLng(location.lat, location.lng),
          ],
          color: widget.accentColor,
          width: 4,
        ),
      );
    }

    final points = [
      for (final location in locations) NLatLng(location.lat, location.lng),
    ];
    final uniquePointKeys = {
      for (final point in points)
        '${point.latitude.toStringAsFixed(5)}:${point.longitude.toStringAsFixed(5)}',
    };

    final cameraUpdate = uniquePointKeys.length <= 1
        ? NCameraUpdate.scrollAndZoomTo(
            target: points.first,
            zoom: widget.singleStopZoom,
          )
        : NCameraUpdate.fitBounds(
            NLatLngBounds.from(points),
            padding: widget.boundsPadding,
          );
    cameraUpdate.setAnimation(duration: const Duration(milliseconds: 900));
    await controller.updateCamera(cameraUpdate);
  }

  @override
  Widget build(BuildContext context) {
    final initial = widget.locations.first;
    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: NaverMap(
        options: NaverMapViewOptions(
          mapType: NMapType.basic,
          indoorEnable: false,
          scaleBarEnable: false,
          locationButtonEnable: false,
          compassEnable: false,
          logoClickEnable: true,
          initialCameraPosition: NCameraPosition(
            target: NLatLng(initial.lat, initial.lng),
            zoom: widget.initialZoom,
          ),
        ),
        onMapReady: _configureMap,
      ),
    );
  }
}
