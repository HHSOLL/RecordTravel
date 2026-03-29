import 'package:flutter/material.dart';
import 'package:flutter_globe_3d/flutter_globe_3d.dart';

import '../../../models/record_models.dart';
import '../../domain/entities/record_globe_country.dart';
import '../../domain/entities/record_globe_scene_spec.dart';
import '../globe_view_state.dart';

const _recordGlobeShaderAsset =
    'packages/feature_record/assets/shaders/record_globe_surface.frag';
const _defaultDayTexture = AssetImage(
  'packages/flutter_globe_3d/assets/images/earth.jpg',
);
const _defaultNightTexture = AssetImage(
  'packages/flutter_globe_3d/assets/images/earth_night.jpg',
);

enum RecordGlobeVisualMode {
  night,
  day,
}

class RecordGlobeViewport extends StatefulWidget {
  const RecordGlobeViewport({
    super.key,
    required this.state,
    required this.trips,
    required this.visualMode,
    this.size,
    this.onCountrySelected,
    this.loadingBuilder,
  });

  static RouteObserver<ModalRoute<dynamic>> get navigatorObserver =>
      Earth3D.routeObserver;

  final RecordGlobeViewState state;
  final List<RecordTrip> trips;
  final RecordGlobeVisualMode visualMode;
  final double? size;
  final ValueChanged<String?>? onCountrySelected;
  final Widget Function(BuildContext context)? loadingBuilder;

  @override
  State<RecordGlobeViewport> createState() => _RecordGlobeViewportState();
}

class _RecordGlobeViewportState extends State<RecordGlobeViewport> {
  EarthController? _controller;
  String? _signature;

  @override
  void initState() {
    super.initState();
    _syncController();
  }

  @override
  void didUpdateWidget(covariant RecordGlobeViewport oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_sameViewportState(oldWidget, widget)) {
      _syncController();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  bool _sameViewportState(
    RecordGlobeViewport previousWidget,
    RecordGlobeViewport nextWidget,
  ) {
    final previous = previousWidget.state;
    final next = nextWidget.state;
    final previousSpec = previous.sceneSpec;
    final nextSpec = next.sceneSpec;
    if (previousSpec == null || nextSpec == null) {
      return previousSpec == nextSpec;
    }

    return previous.selectedCountryCode == next.selectedCountryCode &&
        previous.focusedCountryCode == next.focusedCountryCode &&
        previousSpec.style == nextSpec.style &&
        previousWidget.visualMode == nextWidget.visualMode &&
        previousSpec.countries.length == nextSpec.countries.length &&
        _tripSignature(previousWidget.trips) ==
            _tripSignature(nextWidget.trips) &&
        _countrySignature(previousSpec.countries) ==
            _countrySignature(nextSpec.countries);
  }

  void _syncController() {
    final sceneSpec = widget.state.sceneSpec;
    final signature = sceneSpec == null
        ? null
        : [
            sceneSpec.style.name,
            widget.visualMode.name,
            widget.state.focusedCountryCode ?? '',
            widget.state.selectedCountryCode ?? '',
            _tripSignature(widget.trips),
            _countrySignature(sceneSpec.countries),
          ].join('|');

    if (signature == _signature) {
      return;
    }

    final nextController = sceneSpec == null
        ? null
        : _buildController(sceneSpec.countries, widget.trips, widget.state);

    _controller?.dispose();
    _controller = nextController;
    _signature = signature;
  }

  EarthController _buildController(
    List<RecordGlobeCountry> countries,
    List<RecordTrip> trips,
    RecordGlobeViewState state,
  ) {
    final maxZoom = _resolveMaxZoom();
    final controller = EarthController()
      ..enableAutoRotate = state.selectedCountryCode == null
      ..rotateSpeed = 0.14
      ..minZoom = 1.0
      ..maxZoom = maxZoom
      ..lockNorthSouth = false
      ..lockZoom = false;

    controller.setLightMode(EarthLightMode.followCamera);

    final focusedCountry = _resolveFocusedCountry(countries, state);
    if (focusedCountry != null) {
      controller.setCameraFocus(
        focusedCountry.anchorLatitude,
        focusedCountry.anchorLongitude,
      );
      controller.setZoom(
        state.selectedCountryCode == null ? maxZoom - 0.12 : maxZoom,
      );
    }

    for (final country in countries) {
      controller.addNode(
        EarthNode(
          id: country.code,
          latitude: country.anchorLatitude,
          longitude: country.anchorLongitude,
          child: _CountryMarker(
            country: country,
            isSelected: state.selectedCountryCode == country.code,
            isFocused: state.focusedCountryCode == country.code,
            onTap: () => widget.onCountrySelected?.call(country.code),
          ),
        ),
      );
    }

    _addAnimatedTripConnections(controller, trips);

    return controller;
  }

  RecordGlobeCountry? _resolveFocusedCountry(
    List<RecordGlobeCountry> countries,
    RecordGlobeViewState state,
  ) {
    final preferredCodes = [
      state.focusedCountryCode,
      state.selectedCountryCode,
      state.sceneSpec?.initialCountryCode,
    ];

    for (final code in preferredCodes) {
      if (code == null) {
        continue;
      }
      for (final country in countries) {
        if (country.code == code) {
          return country;
        }
      }
    }

    return countries.isEmpty ? null : countries.first;
  }

  String _countrySignature(List<RecordGlobeCountry> countries) {
    return countries
        .map(
          (country) => [
            country.code,
            country.anchorLatitude.toStringAsFixed(4),
            country.anchorLongitude.toStringAsFixed(4),
            country.signal.name,
            country.activityLevel,
            country.hasUpcomingTrip ? '1' : '0',
            country.hasRecentVisit ? '1' : '0',
          ].join(':'),
        )
        .join('|');
  }

  String _tripSignature(List<RecordTrip> trips) {
    return trips
        .map(
          (trip) => [
            trip.id,
            trip.isUpcoming ? '1' : '0',
            trip.color,
            for (final location in trip.locations)
              [
                location.id,
                location.lat.toStringAsFixed(3),
                location.lng.toStringAsFixed(3),
              ].join(':'),
          ].join('|'),
        )
        .join('||');
  }

  void _addAnimatedTripConnections(
    EarthController controller,
    List<RecordTrip> trips,
  ) {
    final seenConnections = <String>{};

    for (final trip in trips.take(6)) {
      final routeStops = trip.locations
          .where(
            (location) =>
                location.lat.isFinite &&
                location.lng.isFinite &&
                location.lat.abs() <= 90 &&
                location.lng.abs() <= 180,
          )
          .toList(growable: false);
      if (routeStops.length < 2) {
        continue;
      }

      final routeColor = Color(int.parse(trip.color.replaceAll('#', '0xFF')));

      for (final stop in routeStops) {
        controller.addNode(
          EarthNode(
            id: _routeNodeId(trip.id, stop.id),
            latitude: stop.lat,
            longitude: stop.lng,
            child: IgnorePointer(
              child: _RouteNode(color: routeColor),
            ),
          ),
        );
      }

      for (var index = 0; index < routeStops.length - 1; index++) {
        final from = routeStops[index];
        final to = routeStops[index + 1];
        final fromId = _routeNodeId(trip.id, from.id);
        final toId = _routeNodeId(trip.id, to.id);
        final edgeKey = '$fromId->$toId';
        if (!seenConnections.add(edgeKey)) {
          continue;
        }
        controller.connect(
          EarthConnection(
            fromId: fromId,
            toId: toId,
            color: routeColor.withValues(alpha: trip.isUpcoming ? 0.92 : 0.82),
            isDashed: true,
            showArrow: true,
            width: trip.isUpcoming ? 2.1 : 1.8,
          ),
        );
      }
    }
  }

  String _routeNodeId(String tripId, String locationId) {
    return 'route:$tripId:$locationId';
  }

  @override
  Widget build(BuildContext context) {
    final sceneSpec = widget.state.sceneSpec;
    final controller = _controller;
    if ((sceneSpec == null || controller == null) &&
        widget.loadingBuilder != null) {
      return widget.loadingBuilder!(context);
    }
    if (sceneSpec == null || controller == null) {
      return SizedBox.square(dimension: widget.size);
    }

    return SizedBox.square(
      dimension: widget.size,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0x3D5B8CFF),
              blurRadius: 44,
              spreadRadius: 6,
            ),
          ],
        ),
        child: ClipOval(
          clipBehavior: Clip.antiAlias,
          child: ColoredBox(
            color: Colors.transparent,
            child: Earth3D(
              key: ValueKey(_signature),
              shaderAsset: _recordGlobeShaderAsset,
              controller: controller,
              texture: _textureForMode(widget.visualMode),
              nightTexture: null,
              initialScale: _resolveInitialScale(widget.visualMode),
            ),
          ),
        ),
      ),
    );
  }

  ImageProvider _textureForMode(RecordGlobeVisualMode mode) {
    return mode == RecordGlobeVisualMode.night
        ? _defaultNightTexture
        : _defaultDayTexture;
  }

  double _resolveInitialScale(RecordGlobeVisualMode mode) {
    final size = widget.size ?? 0;
    if (size >= 420) {
      return mode == RecordGlobeVisualMode.night ? 1.74 : 1.68;
    }
    if (size >= 360) {
      return mode == RecordGlobeVisualMode.night ? 1.84 : 1.78;
    }
    if (size >= 300) {
      return mode == RecordGlobeVisualMode.night ? 1.96 : 1.90;
    }
    return mode == RecordGlobeVisualMode.night ? 2.06 : 2.00;
  }

  double _resolveMaxZoom() {
    final size = widget.size ?? 0;
    if (size >= 420) {
      return 1.62;
    }
    if (size >= 360) {
      return 1.56;
    }
    if (size >= 300) {
      return 1.48;
    }
    return 1.42;
  }
}

class _CountryMarker extends StatelessWidget {
  const _CountryMarker({
    required this.country,
    required this.isSelected,
    required this.isFocused,
    required this.onTap,
  });

  final RecordGlobeCountry country;
  final bool isSelected;
  final bool isFocused;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (coreColor, ringColor, haloColor) = _markerPalette(country.signal);
    final size = isSelected
        ? 34.0
        : (isFocused || country.hasUpcomingTrip)
            ? 24.0
            : 18.0;
    final showLabel = isSelected || (isFocused && country.activityLevel > 0);
    final label = DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xD9020617),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: ringColor.withValues(alpha: 0.34)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          country.name,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
        ),
      ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showLabel) ...[
            label,
            Container(
              width: 2,
              height: isSelected ? 14 : 10,
              margin: const EdgeInsets.only(top: 2, bottom: 2),
              decoration: BoxDecoration(
                color: ringColor.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ],
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  haloColor.withValues(alpha: isSelected ? 0.84 : 0.66),
                  haloColor.withValues(alpha: 0.16),
                  Colors.transparent,
                ],
                stops: const [0, 0.52, 1],
              ),
            ),
            alignment: Alignment.center,
            child: Container(
              width: size * 0.48,
              height: size * 0.48,
              decoration: BoxDecoration(
                color: coreColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: ringColor,
                  width: isSelected ? 2.2 : 1.6,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        haloColor.withValues(alpha: isSelected ? 0.52 : 0.34),
                    blurRadius: isSelected ? 16 : 10,
                    spreadRadius: isSelected ? 1.5 : 0.0,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color, Color) _markerPalette(RecordGlobeCountrySignal signal) {
    return switch (signal) {
      RecordGlobeCountrySignal.planned => (
          const Color(0xFFF59E0B),
          const Color(0xFFFDE68A),
          const Color(0xFFFBBF24),
        ),
      RecordGlobeCountrySignal.visited => (
          const Color(0xFF60A5FA),
          const Color(0xFFE0F2FE),
          const Color(0xFF38BDF8),
        ),
      RecordGlobeCountrySignal.neutral => (
          const Color(0xFFCBD5E1),
          const Color(0xFFF8FAFC),
          const Color(0xFF94A3B8),
        ),
    };
  }
}

class _RouteNode extends StatelessWidget {
  const _RouteNode({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.42),
            blurRadius: 8,
            spreadRadius: 1.5,
          ),
        ],
      ),
    );
  }
}
