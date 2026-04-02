import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_globe_3d/flutter_globe_3d.dart';

import '../../../models/record_models.dart';
import '../../domain/entities/record_globe_country.dart';
import '../../../i18n/record_strings.dart';
import '../../../globe_engine/picking/record_country_lookup_grid.dart';
import '../globe_view_state.dart';
import 'record_globe_highlight_texture.dart';

const _recordGlobeShaderAsset =
    'packages/feature_record/assets/shaders/record_globe_surface.frag';
const _defaultDayTexture = AssetImage(
  'assets/globe/earth_storybook_light.png',
);
const _defaultNightTexture = AssetImage(
  'assets/globe/earth_storybook_dark.png',
);
const _defaultBorderTexture = AssetImage(
  'assets/globe/earth_borders_overlay_v1_4096.png',
);
const _recordCountryLookupGridAsset = 'assets/globe/country_lookup_v1.bin';
const _recordCountryLookupPaletteAsset =
    'assets/globe/country_lookup_v1_palette.json';

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

class _RecordGlobeViewportState extends State<RecordGlobeViewport>
    with SingleTickerProviderStateMixin {
  EarthController? _controller;
  ui.Image? _highlightTexture;
  String? _dataSignature;
  String? _selectionSignature;
  String? _highlightSignature;
  int _highlightRequestId = 0;
  RecordCountryLookupGrid? _lookupGrid;
  double _lastViewportSize = 0;
  double _lastBleedSize = 0;
  double _lastShaderScale = 1.0;
  late final AnimationController _focusAnimationController;
  Animation<Offset>? _focusOffsetAnimation;
  Animation<double>? _focusZoomAnimation;

  @override
  void initState() {
    super.initState();
    _focusAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 560),
    )
      ..addListener(_applyFocusAnimation)
      ..addStatusListener(_handleFocusAnimationStatus);
    _loadLookupGrid();
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
    _focusAnimationController.dispose();
    _controller?.dispose();
    _highlightTexture?.dispose();
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
    final dataSignature = sceneSpec == null
        ? null
        : [
            sceneSpec.style.name,
            widget.visualMode.name,
            _tripSignature(widget.trips),
            _countrySignature(sceneSpec.countries),
          ].join('|');
    final selectionSignature = sceneSpec == null
        ? null
        : [
            widget.state.focusedCountryCode ?? '',
            widget.state.selectedCountryCode ?? '',
          ].join('|');

    if (sceneSpec == null) {
      _focusAnimationController.stop();
      _controller?.dispose();
      _controller = null;
      _dataSignature = null;
      _selectionSignature = null;
      return;
    }

    if (_controller == null || dataSignature != _dataSignature) {
      _focusAnimationController.stop();
      _controller?.dispose();
      final nextController = _buildController(
        sceneSpec.countries,
        widget.trips,
        widget.state,
        centerOnFocusedCountry: true,
      );
      _controller = nextController;
      _dataSignature = dataSignature;
      _selectionSignature = selectionSignature;
      _refreshHighlightTexture(sceneSpec.countries);
      return;
    }

    if (selectionSignature != _selectionSignature) {
      _focusAnimationController.stop();
      _configureController(
        _controller!,
        sceneSpec.countries,
        widget.trips,
        widget.state,
        centerOnFocusedCountry: false,
      );
      final focusedCountry =
          _resolveFocusedCountry(sceneSpec.countries, widget.state);
      if (focusedCountry != null) {
        _animateCameraFocus(
          controller: _controller!,
          latitude: focusedCountry.anchorLatitude,
          longitude: focusedCountry.anchorLongitude,
          targetZoom: _resolveInitialZoom(widget.state.selectedCountryCode),
        );
      } else {
        _animateCameraFocus(
          controller: _controller!,
          latitude: 26.0,
          longitude: 24.0,
          targetZoom: _resolveInitialZoom(null),
        );
      }
      _selectionSignature = selectionSignature;
    }

    _refreshHighlightTexture(sceneSpec.countries);
  }

  EarthController _buildController(List<RecordGlobeCountry> countries,
      List<RecordTrip> trips, RecordGlobeViewState state,
      {required bool centerOnFocusedCountry}) {
    final maxZoom = _resolveMaxZoom();
    final controller = EarthController()
      ..rotateSpeed = 0.14
      ..minZoom = 1.0
      ..maxZoom = maxZoom
      ..lockNorthSouth = false
      ..lockZoom = false;

    controller.setLightMode(EarthLightMode.followCamera);
    _configureController(
      controller,
      countries,
      trips,
      state,
      centerOnFocusedCountry: centerOnFocusedCountry,
    );
    return controller;
  }

  void _configureController(
    EarthController controller,
    List<RecordGlobeCountry> countries,
    List<RecordTrip> trips,
    RecordGlobeViewState state, {
    required bool centerOnFocusedCountry,
  }) {
    controller
      ..enableAutoRotate = state.selectedCountryCode == null
      ..minZoom = 1.0
      ..maxZoom = _resolveMaxZoom();

    controller.nodes.clear();
    controller.connections.clear();
    controller.projectedPositions.clear();
    controller.nodeVisibility.clear();
    controller.connectionPaths.clear();

    if (centerOnFocusedCountry) {
      final focusedCountry = _resolveFocusedCountry(countries, state);
      if (focusedCountry != null) {
        controller.setCameraFocus(
          focusedCountry.anchorLatitude,
          focusedCountry.anchorLongitude,
        );
        controller.setZoom(_resolveInitialZoom(state.selectedCountryCode));
      } else {
        // Default framing keeps Europe / Africa / West Asia in the front.
        controller.setCameraFocus(26.0, 24.0);
        controller.setZoom(_resolveInitialZoom(state.selectedCountryCode));
      }
    }

    for (final country in countries) {
      controller.nodes.add(
        EarthNode(
          id: country.code,
          latitude: country.anchorLatitude,
          longitude: country.anchorLongitude,
          child: _CountryMarker(
            country: country,
            isSelected: state.selectedCountryCode == country.code,
            isFocused: state.focusedCountryCode == country.code,
          ),
        ),
      );
    }

    _addAnimatedTripConnections(controller, trips);
    controller.refresh();
  }

  void _applyFocusAnimation() {
    final controller = _controller;
    final offsetAnimation = _focusOffsetAnimation;
    final zoomAnimation = _focusZoomAnimation;
    if (controller == null ||
        offsetAnimation == null ||
        zoomAnimation == null) {
      return;
    }

    controller.enableAutoRotate = false;
    controller.setOffset(offsetAnimation.value);
    controller.setZoom(zoomAnimation.value);
  }

  void _handleFocusAnimationStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed &&
        status != AnimationStatus.dismissed) {
      return;
    }

    final controller = _controller;
    if (controller == null) {
      return;
    }

    controller
      ..enableAutoRotate = widget.state.selectedCountryCode == null
      ..refresh();
    _focusOffsetAnimation = null;
    _focusZoomAnimation = null;
  }

  Future<void> _loadLookupGrid() async {
    final lookupGrid = await RecordCountryLookupGrid.load(
      gridAsset: _recordCountryLookupGridAsset,
      paletteAsset: _recordCountryLookupPaletteAsset,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _lookupGrid = lookupGrid;
    });
  }

  void _animateCameraFocus({
    required EarthController controller,
    required double latitude,
    required double longitude,
    required double targetZoom,
  }) {
    final beginOffset = controller.offset;
    final endOffset = _offsetForFocus(latitude, longitude);
    final beginZoom = controller.zoom;
    final endZoom = targetZoom.clamp(controller.minZoom, controller.maxZoom);
    final delta =
        (endOffset - beginOffset).distance + ((endZoom - beginZoom).abs() * 90);
    if (delta < 0.6) {
      controller
        ..setOffset(endOffset)
        ..setZoom(endZoom)
        ..enableAutoRotate = widget.state.selectedCountryCode == null
        ..refresh();
      return;
    }

    _focusOffsetAnimation = Tween<Offset>(
      begin: beginOffset,
      end: endOffset,
    ).animate(
      CurvedAnimation(
        parent: _focusAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );
    _focusZoomAnimation = Tween<double>(
      begin: beginZoom,
      end: endZoom,
    ).animate(
      CurvedAnimation(
        parent: _focusAnimationController,
        curve: Curves.easeInOutCubic,
      ),
    );
    _focusAnimationController
      ..stop()
      ..reset()
      ..forward();
  }

  Offset _offsetForFocus(double lat, double lon) {
    final radLat = lat * math.pi / 180.0;
    final radLon = (lon + 90.0) * math.pi / 180.0;
    final dx = -radLon * 200.0;
    final dy = (radLat * 200.0).clamp(-300.0, 300.0);
    return Offset(dx, dy);
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

    return null;
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

    final sortedTrips = [...trips]..sort((a, b) {
        if (a.isUpcoming != b.isUpcoming) {
          return a.isUpcoming ? -1 : 1;
        }
        return b.endDate.compareTo(a.endDate);
      });

    for (final trip in sortedTrips.take(4)) {
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
        controller.nodes.add(
          EarthNode(
            id: _routeNodeId(trip.id, stop.id),
            latitude: stop.lat,
            longitude: stop.lng,
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
        controller.connections.add(
          EarthConnection(
            fromId: fromId,
            toId: toId,
            color: routeColor.withValues(alpha: trip.isUpcoming ? 0.92 : 0.82),
            isDashed: trip.isUpcoming,
            showArrow: true,
            width: trip.isUpcoming ? 2.6 : 2.2,
            curveScale: _curveScaleForSegment(from, to, trip.isUpcoming),
            label: _routeLabel(from, to),
          ),
        );
      }
    }
  }

  String? _routeLabel(RecordLocation from, RecordLocation to) {
    if (from.countryCode == to.countryCode && _segmentDistance(from, to) < 8) {
      return null;
    }
    final fromCode = _shortCodeFor(from.name);
    final toCode = _shortCodeFor(to.name);
    return '$fromCode → $toCode';
  }

  String _shortCodeFor(String name) {
    final compact = name.replaceAll(RegExp(r'[^A-Za-z가-힣0-9]'), '');
    if (compact.isEmpty) {
      return 'STOP';
    }
    if (RegExp(r'^[A-Za-z]+$').hasMatch(compact)) {
      final end = compact.length < 3 ? compact.length : 3;
      return compact.substring(0, end).toUpperCase();
    }
    final end = compact.length < 3 ? compact.length : 3;
    return compact.substring(0, end).toUpperCase();
  }

  double _curveScaleForSegment(
    RecordLocation from,
    RecordLocation to,
    bool isUpcoming,
  ) {
    final distance = _segmentDistance(from, to);
    final base = distance > 60
        ? 1.1
        : distance > 28
            ? 0.95
            : 0.72;
    return isUpcoming ? base + 0.12 : base;
  }

  double _segmentDistance(RecordLocation from, RecordLocation to) {
    final latDelta = from.lat - to.lat;
    final lngDelta = from.lng - to.lng;
    return math.sqrt((latDelta * latDelta) + (lngDelta * lngDelta));
  }

  void _refreshHighlightTexture(List<RecordGlobeCountry> countries) {
    final signature = countries
        .map(
          (country) => [
            country.code,
            country.signal.name,
            country.activityLevel,
            country.hasRecentVisit ? '1' : '0',
            country.hasUpcomingTrip ? '1' : '0',
          ].join(':'),
        )
        .join('|');
    if (signature == _highlightSignature) {
      return;
    }
    _highlightSignature = signature;
    final requestId = ++_highlightRequestId;
    RecordGlobeHighlightTextureBuilder.build(countries).then((image) {
      if (!mounted || requestId != _highlightRequestId) {
        image?.dispose();
        return;
      }
      final previous = _highlightTexture;
      setState(() {
        _highlightTexture = image;
      });
      previous?.dispose();
    });
  }

  String _routeNodeId(String tripId, String locationId) {
    return 'route:$tripId:$locationId';
  }

  List<_OverlayCountryCardModel> _overlayCountryCards(
    List<RecordGlobeCountry> countries,
    List<RecordTrip> trips,
    EarthController controller,
    double viewportSize,
  ) {
    final visible = <RecordGlobeCountry>[];
    for (final country in countries) {
      if ((controller.nodeVisibility[country.code] ?? false) &&
          controller.projectedPositions[country.code] != null) {
        visible.add(country);
      }
    }
    if (visible.isEmpty) {
      return const [];
    }

    visible.sort(
      (a, b) => _overlayPriorityScore(b).compareTo(_overlayPriorityScore(a)),
    );
    final hiddenCount = visible.length;
    final detailLimit = switch (viewportSize) {
      < 340 => 3,
      < 390 => hiddenCount > 8 ? 3 : 4,
      _ => hiddenCount > 10 ? 4 : 5,
    };
    final selected = visible.take(detailLimit).toList(growable: false);
    final center = Offset(viewportSize * 0.5, viewportSize * 0.5);
    final models = <_OverlayCountryCardModel>[];
    final occupied = <Rect>[];

    for (var index = 0; index < selected.length; index++) {
      final country = selected[index];
      final point = controller.projectedPositions[country.code];
      if (point == null) {
        continue;
      }
      final cardSize = Size(country.hasUpcomingTrip ? 180 : 164, 54);
      final vector = point - center;
      final normal =
          vector.distance < 8 ? const Offset(0, -1) : vector / vector.distance;
      final tangent = Offset(-normal.dy, normal.dx);
      final radiusPush = 74.0 + (index % 2 == 0 ? 8.0 : 0.0);
      final tangentPush = (index - 1.5) * 16.0;
      Offset cardCenter =
          point + (normal * radiusPush) + (tangent * tangentPush);
      Rect candidateRect = Rect.fromCenter(
        center: cardCenter,
        width: cardSize.width,
        height: cardSize.height,
      );
      var attempts = 0;
      while (attempts < 8 &&
          occupied
              .any((occupiedRect) => occupiedRect.overlaps(candidateRect))) {
        attempts += 1;
        final additionalPush = 18.0 + (attempts * 7.0);
        cardCenter = point + (normal * (radiusPush + additionalPush));
        candidateRect = Rect.fromCenter(
          center: cardCenter,
          width: cardSize.width,
          height: cardSize.height,
        );
      }
      cardCenter = Offset(
        cardCenter.dx.clamp(
          cardSize.width * 0.5 + 6,
          viewportSize - cardSize.width * 0.5 - 6,
        ),
        cardCenter.dy.clamp(
          cardSize.height * 0.5 + 6,
          viewportSize - cardSize.height * 0.5 - 6,
        ),
      );
      candidateRect = Rect.fromCenter(
        center: cardCenter,
        width: cardSize.width,
        height: cardSize.height,
      );
      occupied.add(candidateRect.inflate(6));

      final accent = _countryAccent(country.signal);
      final trip = _latestTripForCountry(country.code, trips);
      models.add(
        _OverlayCountryCardModel(
          country: country,
          nodePoint: point,
          cardCenter: cardCenter,
          cardSize: cardSize,
          accentColor: accent,
          badgeValue: country.visitCount > 0
              ? country.visitCount
              : country.activityLevel,
          thumbnailColor:
              trip == null ? accent : _safeColorFromHex(trip.color, accent),
          thumbnailLabel: trip?.coverImage ?? country.continent,
          showPlusAction: country.hasUpcomingTrip,
        ),
      );
    }

    return models;
  }

  List<_OverlaySummaryCardModel> _overlaySummaryCards(
    List<RecordGlobeCountry> countries,
    List<_OverlayCountryCardModel> detailCards,
    EarthController controller,
    double viewportSize,
    RecordStrings strings,
  ) {
    final visible = <RecordGlobeCountry>[];
    for (final country in countries) {
      if ((controller.nodeVisibility[country.code] ?? false) &&
          controller.projectedPositions[country.code] != null) {
        visible.add(country);
      }
    }
    if (visible.isEmpty) {
      return const [];
    }

    final shownCodes = detailCards.map((card) => card.country.code).toSet();
    final hidden = visible
        .where((country) => !shownCodes.contains(country.code))
        .toList(growable: false);
    if (hidden.isEmpty) {
      return const [];
    }

    final grouped = <String, List<RecordGlobeCountry>>{};
    for (final country in hidden) {
      grouped.putIfAbsent(country.continent, () => []).add(country);
    }
    final entries = grouped.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));

    final center = Offset(viewportSize * 0.5, viewportSize * 0.5);
    final occupied = detailCards
        .map(
          (card) => Rect.fromCenter(
            center: card.cardCenter,
            width: card.cardSize.width,
            height: card.cardSize.height,
          ).inflate(8),
        )
        .toList(growable: true);
    final summaries = <_OverlaySummaryCardModel>[];

    final summaryLimit = viewportSize >= 400 ? 3 : 2;
    for (var index = 0;
        index < entries.length && summaries.length < summaryLimit;
        index++) {
      final entry = entries[index];
      final anchor = _averageProjectedPosition(entry.value, controller);
      if (anchor == null) {
        continue;
      }
      final count = entry.value.length;
      if (count <= 0) {
        continue;
      }
      if (count == 1) {
        continue;
      }
      final cardSize = const Size(124, 44);
      final vector = anchor - center;
      final normal =
          vector.distance < 8 ? const Offset(-1, 0) : vector / vector.distance;
      final tangent = Offset(-normal.dy, normal.dx);
      final basePush = 56.0 + (index * 8.0);
      var cardCenter =
          anchor + (normal * basePush) + (tangent * (index == 0 ? -12 : 12));
      Rect cardRect = Rect.fromCenter(
        center: cardCenter,
        width: cardSize.width,
        height: cardSize.height,
      );
      var attempts = 0;
      while (attempts < 8 &&
          occupied.any((occupiedRect) => occupiedRect.overlaps(cardRect))) {
        attempts += 1;
        cardCenter = anchor + (normal * (basePush + (attempts * 10.0)));
        cardRect = Rect.fromCenter(
          center: cardCenter,
          width: cardSize.width,
          height: cardSize.height,
        );
      }
      cardCenter = Offset(
        cardCenter.dx.clamp(
          cardSize.width * 0.5 + 6,
          viewportSize - cardSize.width * 0.5 - 6,
        ),
        cardCenter.dy.clamp(
          cardSize.height * 0.5 + 6,
          viewportSize - cardSize.height * 0.5 - 6,
        ),
      );
      cardRect = Rect.fromCenter(
        center: cardCenter,
        width: cardSize.width,
        height: cardSize.height,
      );
      occupied.add(cardRect.inflate(6));

      summaries.add(
        _OverlaySummaryCardModel(
          label: '${strings.continentLabel(entry.key)} +$count',
          anchorPoint: anchor,
          cardCenter: cardCenter,
          cardSize: cardSize,
          accentColor: _summaryAccent(entry.value),
        ),
      );
    }

    return summaries;
  }

  Offset? _averageProjectedPosition(
    List<RecordGlobeCountry> countries,
    EarthController controller,
  ) {
    var sumX = 0.0;
    var sumY = 0.0;
    var count = 0;
    for (final country in countries) {
      final point = controller.projectedPositions[country.code];
      if (point == null) {
        continue;
      }
      sumX += point.dx;
      sumY += point.dy;
      count += 1;
    }
    if (count == 0) {
      return null;
    }
    return Offset(sumX / count, sumY / count);
  }

  Color _summaryAccent(List<RecordGlobeCountry> countries) {
    if (countries
        .any((country) => country.signal == RecordGlobeCountrySignal.visited)) {
      return const Color(0xFF53CFF7);
    }
    if (countries
        .any((country) => country.signal == RecordGlobeCountrySignal.planned)) {
      return const Color(0xFF7CD8FF);
    }
    return const Color(0xFFAFC3D9);
  }

  int _overlayPriorityScore(RecordGlobeCountry country) {
    final signalWeight = switch (country.signal) {
      RecordGlobeCountrySignal.visited => 200,
      RecordGlobeCountrySignal.planned => 140,
      RecordGlobeCountrySignal.neutral => 80,
    };
    return signalWeight +
        (country.activityLevel * 12) +
        (country.visitCount * 8);
  }

  Color _countryAccent(RecordGlobeCountrySignal signal) {
    return switch (signal) {
      RecordGlobeCountrySignal.visited => const Color(0xFF53CFF7),
      RecordGlobeCountrySignal.planned => const Color(0xFF7CD8FF),
      RecordGlobeCountrySignal.neutral => const Color(0xFFAFC3D9),
    };
  }

  RecordTrip? _latestTripForCountry(
      String countryCode, List<RecordTrip> trips) {
    RecordTrip? best;
    DateTime? bestEnd;
    for (final trip in trips) {
      final hasCountry =
          trip.countries.any((country) => country.code == countryCode);
      if (!hasCountry) {
        continue;
      }
      final end = DateTime.tryParse(trip.endDate) ??
          DateTime.fromMillisecondsSinceEpoch(0);
      if (best == null || end.isAfter(bestEnd!)) {
        best = trip;
        bestEnd = end;
      }
    }
    return best;
  }

  Color _safeColorFromHex(String rawHex, Color fallback) {
    final hex = rawHex.replaceAll('#', '');
    if (hex.length != 6) {
      return fallback;
    }
    final value = int.tryParse(hex, radix: 16);
    if (value == null) {
      return fallback;
    }
    return Color(0xFF000000 | value);
  }

  List<_OverlayRouteLabelModel> _overlayRouteLabels(
    EarthController controller,
    double viewportSize,
    List<Rect> blockedRects,
  ) {
    final candidates = <_RouteLabelCandidate>[];
    for (final entry in controller.connectionPaths.entries) {
      final label = entry.key.label;
      if (label == null || label.trim().isEmpty) {
        continue;
      }
      final metric = _longestMetric(entry.value);
      if (metric == null || metric.length < 36) {
        continue;
      }
      final tangent = metric.getTangentForOffset(metric.length * 0.54);
      if (tangent == null) {
        continue;
      }
      final position = tangent.position;
      if (position.dx < 8 ||
          position.dy < 8 ||
          position.dx > viewportSize - 8 ||
          position.dy > viewportSize - 8) {
        continue;
      }
      candidates.add(
        _RouteLabelCandidate(
          text: label,
          position: position,
          color: entry.key.color,
          weight: metric.length,
        ),
      );
    }

    candidates.sort((a, b) => b.weight.compareTo(a.weight));
    final labels = <_OverlayRouteLabelModel>[];
    final occupied = <Rect>[];
    final maxLabels = switch (viewportSize) {
      < 340 => 2,
      < 390 => 3,
      _ => 4,
    };
    for (final candidate in candidates) {
      final estimatedWidth = (candidate.text.length * 7.2) + 28;
      final rect = Rect.fromCenter(
        center: candidate.position,
        width: estimatedWidth.clamp(70.0, 170.0),
        height: 30,
      );
      if (blockedRects.any((blockedRect) => blockedRect.overlaps(rect))) {
        continue;
      }
      if (occupied.any((occupiedRect) => occupiedRect.overlaps(rect))) {
        continue;
      }
      occupied.add(rect.inflate(4));
      labels.add(
        _OverlayRouteLabelModel(
          text: candidate.text,
          position: candidate.position,
          color: candidate.color,
        ),
      );
      if (labels.length >= maxLabels) {
        break;
      }
    }
    return labels;
  }

  ui.PathMetric? _longestMetric(Path path) {
    ui.PathMetric? longest;
    for (final metric in path.computeMetrics()) {
      if (longest == null || metric.length > longest.length) {
        longest = metric;
      }
    }
    return longest;
  }

  String? _pickCountryCodeFromTap(Offset localPosition) {
    final controller = _controller;
    final lookupGrid = _lookupGrid;
    if (controller == null || lookupGrid == null) {
      return null;
    }

    final viewportSize =
        _lastViewportSize > 0 ? _lastViewportSize : (widget.size ?? 0.0);
    if (viewportSize <= 0) {
      return null;
    }
    final bleedSize = _lastBleedSize > 0 ? _lastBleedSize : viewportSize;
    final pixelInBleed = _localPointToBleedPoint(localPosition);
    final uv = _surfaceUvAtPixel(
      pixelInBleed,
      Size.square(bleedSize),
      controller.offset,
      controller.zoom,
      _lastShaderScale,
    );
    if (uv == null) {
      return null;
    }
    return lookupGrid.countryCodeForUv(
      uv.dx,
      uv.dy,
      neighborhoodRadius: 1,
    );
  }

  Offset _localPointToBleedPoint(Offset localPosition) {
    final viewportSize =
        _lastViewportSize > 0 ? _lastViewportSize : (widget.size ?? 0.0);
    final bleedSize = _lastBleedSize > 0 ? _lastBleedSize : viewportSize;
    final bleedPadding = (bleedSize - viewportSize) * 0.5;
    return Offset(
      localPosition.dx + bleedPadding,
      localPosition.dy + bleedPadding,
    );
  }

  Offset? _surfaceUvAtPixel(
    Offset pixel,
    Size resolution,
    Offset controllerOffset,
    double zoom,
    double shaderScale,
  ) {
    if (resolution.height <= 0) {
      return null;
    }
    final cameraUv = Offset(
      (pixel.dx - (resolution.width * 0.5)) / resolution.height,
      -((pixel.dy - (resolution.height * 0.5)) / resolution.height),
    );
    final camDistance = 5.0 / math.max(zoom, 0.01);
    final yaw = -controllerOffset.dx / 200.0;
    final pitch = (controllerOffset.dy / 200.0).clamp(-1.5, 1.5);

    var rayOrigin = const _RayVec3(0, 0, -1);
    rayOrigin = _rotateYZ(rayOrigin * camDistance, pitch);
    rayOrigin = _rotateXZ(rayOrigin, yaw);

    const target = _RayVec3.zero();
    final forward = (target - rayOrigin).normalized();
    final right = const _RayVec3(0, 1, 0).cross(forward).normalized();
    final up = forward.cross(right);
    final rayDirection =
        (forward + (right * cameraUv.dx) + (up * cameraUv.dy)).normalized();

    final sphereRadius = shaderScale * 0.5;
    final originToSphere = rayOrigin - target;
    final b = originToSphere.dot(rayDirection);
    final c =
        originToSphere.dot(originToSphere) - (sphereRadius * sphereRadius);
    final h = (b * b) - c;
    if (h <= 0) {
      return null;
    }
    final t = -b - math.sqrt(h);
    if (t <= 0) {
      return null;
    }
    final hit = rayOrigin + (rayDirection * t);
    final normal = hit.normalized();
    final u = 0.5 + math.atan2(normal.z, normal.x) / (2 * math.pi);
    final v = 0.5 - math.asin(normal.y.clamp(-1.0, 1.0)) / math.pi;
    return Offset(u, v);
  }

  _RayVec3 _rotateYZ(_RayVec3 vector, double angle) {
    final c = math.cos(angle);
    final s = math.sin(angle);
    return _RayVec3(
      vector.x,
      (vector.y * c) - (vector.z * s),
      (vector.y * s) + (vector.z * c),
    );
  }

  _RayVec3 _rotateXZ(_RayVec3 vector, double angle) {
    final c = math.cos(angle);
    final s = math.sin(angle);
    return _RayVec3(
      (vector.x * c) - (vector.z * s),
      vector.y,
      (vector.x * s) + (vector.z * c),
    );
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
    final strings = RecordStrings.of(context);
    final isDark = widget.visualMode == RecordGlobeVisualMode.night;

    return SizedBox.square(
      dimension: widget.size,
      child: ClipOval(
        clipBehavior: Clip.antiAlias,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTapUp: (details) => _handleViewportTap(details.localPosition),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final viewportSize = constraints.biggest.shortestSide;
              final bleedSize = viewportSize * 1.18;
              _lastViewportSize = viewportSize;
              _lastBleedSize = bleedSize;
              _lastShaderScale = _resolveInitialScale(widget.visualMode);
              return OverflowBox(
                maxWidth: bleedSize,
                maxHeight: bleedSize,
                child: SizedBox.square(
                  dimension: bleedSize,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: ColoredBox(
                          color: Colors.transparent,
                          child: Earth3D(
                            shaderAsset: _recordGlobeShaderAsset,
                            controller: controller,
                            texture: _textureForMode(widget.visualMode),
                            nightTexture: null,
                            borderTexture: _defaultBorderTexture,
                            highlightTexture: _highlightTexture,
                            darkTheme: isDark,
                            initialScale:
                                _resolveInitialScale(widget.visualMode),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: ListenableBuilder(
                          listenable: controller,
                          builder: (context, _) {
                            final overlayCards = _overlayCountryCards(
                              sceneSpec.countries,
                              widget.trips,
                              controller,
                              bleedSize,
                            );
                            final summaryCards = _overlaySummaryCards(
                              sceneSpec.countries,
                              overlayCards,
                              controller,
                              bleedSize,
                              strings,
                            );
                            final blockedRouteRects = <Rect>[
                              ...overlayCards.map(
                                (card) => Rect.fromCenter(
                                  center: card.cardCenter,
                                  width: card.cardSize.width,
                                  height: card.cardSize.height,
                                ).inflate(8),
                              ),
                              ...summaryCards.map(
                                (summary) => Rect.fromCenter(
                                  center: summary.cardCenter,
                                  width: summary.cardSize.width,
                                  height: summary.cardSize.height,
                                ).inflate(8),
                              ),
                            ];
                            final routeLabels = _overlayRouteLabels(
                              controller,
                              bleedSize,
                              blockedRouteRects,
                            );
                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                for (final card in overlayCards) ...[
                                  Positioned.fill(
                                    child: IgnorePointer(
                                      child: CustomPaint(
                                        painter: _DottedConnectorPainter(
                                          from: card.nodePoint,
                                          to: card.cardCenter,
                                          color: card.accentColor.withValues(
                                            alpha: isDark ? 0.48 : 0.4,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: card.cardCenter.dx -
                                        (card.cardSize.width * 0.5),
                                    top: card.cardCenter.dy -
                                        (card.cardSize.height * 0.5),
                                    width: card.cardSize.width,
                                    height: card.cardSize.height,
                                    child: _PointerBlocker(
                                      child: _OverlayCountryCard(
                                        countryName: strings.countryName(
                                          card.country.code,
                                          card.country.name,
                                        ),
                                        badgeValue: card.badgeValue,
                                        accentColor: card.accentColor,
                                        thumbnailColor: card.thumbnailColor,
                                        thumbnailLabel: card.thumbnailLabel,
                                        showPlusAction: card.showPlusAction,
                                        isDark: isDark,
                                      ),
                                    ),
                                  ),
                                ],
                                for (final summary in summaryCards) ...[
                                  Positioned.fill(
                                    child: IgnorePointer(
                                      child: CustomPaint(
                                        painter: _DottedConnectorPainter(
                                          from: summary.anchorPoint,
                                          to: summary.cardCenter,
                                          color: summary.accentColor.withValues(
                                            alpha: isDark ? 0.34 : 0.3,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: summary.cardCenter.dx -
                                        (summary.cardSize.width * 0.5),
                                    top: summary.cardCenter.dy -
                                        (summary.cardSize.height * 0.5),
                                    width: summary.cardSize.width,
                                    height: summary.cardSize.height,
                                    child: _PointerBlocker(
                                      child: _OverlaySummaryCard(
                                        label: summary.label,
                                        accentColor: summary.accentColor,
                                        isDark: isDark,
                                      ),
                                    ),
                                  ),
                                ],
                                for (final label in routeLabels)
                                  Positioned(
                                    left: label.position.dx,
                                    top: label.position.dy,
                                    child: FractionalTranslation(
                                      translation: const Offset(-0.5, -0.5),
                                      child: _PointerBlocker(
                                        child: _OverlayRouteLabel(
                                          text: label.text,
                                          color: label.color,
                                        ),
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
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _handleViewportTap(Offset localPosition) {
    final controller = _controller;
    final sceneSpec = widget.state.sceneSpec;
    if (controller == null || sceneSpec == null) {
      return;
    }

    final bleedPoint = _localPointToBleedPoint(localPosition);

    final pickedCode = _pickCountryCodeFromTap(localPosition);
    if (pickedCode != null &&
        sceneSpec.countries.any((country) => country.code == pickedCode)) {
      widget.onCountrySelected?.call(pickedCode);
      return;
    }

    final visibleCountries = <RecordGlobeCountry>[];
    for (final country in sceneSpec.countries) {
      if (controller.nodeVisibility[country.code] ?? false) {
        visibleCountries.add(country);
      }
    }
    if (visibleCountries.isEmpty) {
      return;
    }

    RecordGlobeCountry? nearest;
    double nearestDistance = double.infinity;
    for (final country in visibleCountries) {
      final projected = controller.projectedPositions[country.code];
      if (projected == null) {
        continue;
      }
      final distance = (projected - bleedPoint).distance;
      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearest = country;
      }
    }

    final threshold = _tapThresholdForSize();
    if (nearest != null && nearestDistance <= threshold) {
      widget.onCountrySelected?.call(nearest.code);
    }
  }

  double _tapThresholdForSize() {
    final size = widget.size ?? 0;
    if (size >= 420) {
      return 36;
    }
    if (size >= 360) {
      return 32;
    }
    if (size >= 300) {
      return 30;
    }
    return 26;
  }

  ImageProvider _textureForMode(RecordGlobeVisualMode mode) {
    return mode == RecordGlobeVisualMode.night
        ? _defaultNightTexture
        : _defaultDayTexture;
  }

  double _resolveInitialScale(RecordGlobeVisualMode mode) {
    final size = widget.size ?? 0;
    if (size >= 420) {
      return mode == RecordGlobeVisualMode.night ? 1.76 : 1.72;
    }
    if (size >= 360) {
      return mode == RecordGlobeVisualMode.night ? 1.84 : 1.8;
    }
    if (size >= 300) {
      return mode == RecordGlobeVisualMode.night ? 1.94 : 1.9;
    }
    return mode == RecordGlobeVisualMode.night ? 2.02 : 1.98;
  }

  double _resolveMaxZoom() {
    final size = widget.size ?? 0;
    if (size >= 420) {
      return 2.38;
    }
    if (size >= 360) {
      return 2.3;
    }
    if (size >= 300) {
      return 2.2;
    }
    return 2.12;
  }

  double _resolveInitialZoom(String? selectedCountryCode) {
    final maxZoom = _resolveMaxZoom();
    return selectedCountryCode == null ? maxZoom - 0.28 : maxZoom - 0.12;
  }
}

class _OverlayCountryCardModel {
  const _OverlayCountryCardModel({
    required this.country,
    required this.nodePoint,
    required this.cardCenter,
    required this.cardSize,
    required this.accentColor,
    required this.badgeValue,
    required this.thumbnailColor,
    required this.thumbnailLabel,
    required this.showPlusAction,
  });

  final RecordGlobeCountry country;
  final Offset nodePoint;
  final Offset cardCenter;
  final Size cardSize;
  final Color accentColor;
  final int badgeValue;
  final Color thumbnailColor;
  final String thumbnailLabel;
  final bool showPlusAction;
}

class _OverlaySummaryCardModel {
  const _OverlaySummaryCardModel({
    required this.label,
    required this.anchorPoint,
    required this.cardCenter,
    required this.cardSize,
    required this.accentColor,
  });

  final String label;
  final Offset anchorPoint;
  final Offset cardCenter;
  final Size cardSize;
  final Color accentColor;
}

class _OverlayRouteLabelModel {
  const _OverlayRouteLabelModel({
    required this.text,
    required this.position,
    required this.color,
  });

  final String text;
  final Offset position;
  final Color color;
}

class _RouteLabelCandidate {
  const _RouteLabelCandidate({
    required this.text,
    required this.position,
    required this.color,
    required this.weight,
  });

  final String text;
  final Offset position;
  final Color color;
  final double weight;
}

class _OverlayCountryCard extends StatelessWidget {
  const _OverlayCountryCard({
    required this.countryName,
    required this.badgeValue,
    required this.accentColor,
    required this.thumbnailColor,
    required this.thumbnailLabel,
    required this.showPlusAction,
    required this.isDark,
  });

  final String countryName;
  final int badgeValue;
  final Color accentColor;
  final Color thumbnailColor;
  final String thumbnailLabel;
  final bool showPlusAction;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final baseColor =
        isDark ? const Color(0xCC112944) : Colors.white.withValues(alpha: 0.9);
    final textColor = isDark ? Colors.white : const Color(0xFF1C2E42);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.16)
              : const Color(0xFFD8E8F7),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.24 : 0.1),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      countryName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$badgeValue',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: accentColor,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            if (showPlusAction)
              Container(
                width: 30,
                height: 30,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0x3329A8FF)
                      : const Color(0xFFEAF5FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.2)
                        : const Color(0xFFD4E8FA),
                  ),
                ),
                child: Icon(
                  Icons.add_rounded,
                  size: 18,
                  color: isDark ? Colors.white : const Color(0xFF3B6B94),
                ),
              ),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    thumbnailColor.withValues(alpha: 0.95),
                    Color.lerp(thumbnailColor, Colors.black, 0.26)!,
                  ],
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                _thumbnailSymbol(thumbnailLabel),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _thumbnailSymbol(String source) {
    final compact = source.trim();
    if (compact.isEmpty) {
      return '•';
    }
    return compact.substring(0, 1).toUpperCase();
  }
}

class _OverlayRouteLabel extends StatelessWidget {
  const _OverlayRouteLabel({
    required this.text,
    required this.color,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.88),
            Color.lerp(color, Colors.white, 0.2)!.withValues(alpha: 0.84),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.1,
              ),
        ),
      ),
    );
  }
}

class _OverlaySummaryCard extends StatelessWidget {
  const _OverlaySummaryCard({
    required this.label,
    required this.accentColor,
    required this.isDark,
  });

  final String label;
  final Color accentColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xC9142C44)
            : Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: accentColor.withValues(alpha: isDark ? 0.52 : 0.38),
          width: 1.2,
        ),
      ),
      child: Center(
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: isDark ? Colors.white : const Color(0xFF23425F),
                fontWeight: FontWeight.w800,
              ),
        ),
      ),
    );
  }
}

class _PointerBlocker extends StatelessWidget {
  const _PointerBlocker({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      child: child,
    );
  }
}

class _DottedConnectorPainter extends CustomPainter {
  const _DottedConnectorPainter({
    required this.from,
    required this.to,
    required this.color,
  });

  final Offset from;
  final Offset to;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(from.dx, from.dy)
      ..quadraticBezierTo(
        (from.dx + to.dx) * 0.5,
        (from.dy + to.dy) * 0.5 - 10,
        to.dx,
        to.dy,
      );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    for (final metric in path.computeMetrics()) {
      const dash = 4.0;
      const gap = 5.0;
      var distance = 0.0;
      while (distance < metric.length) {
        final next = (distance + dash).clamp(0.0, metric.length).toDouble();
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DottedConnectorPainter oldDelegate) {
    return oldDelegate.from != from ||
        oldDelegate.to != to ||
        oldDelegate.color != color;
  }
}

class _RayVec3 {
  const _RayVec3(this.x, this.y, this.z);

  const _RayVec3.zero()
      : x = 0,
        y = 0,
        z = 0;

  final double x;
  final double y;
  final double z;

  _RayVec3 operator +(_RayVec3 other) =>
      _RayVec3(x + other.x, y + other.y, z + other.z);

  _RayVec3 operator -(_RayVec3 other) =>
      _RayVec3(x - other.x, y - other.y, z - other.z);

  _RayVec3 operator *(double scalar) =>
      _RayVec3(x * scalar, y * scalar, z * scalar);

  double dot(_RayVec3 other) => (x * other.x) + (y * other.y) + (z * other.z);

  _RayVec3 cross(_RayVec3 other) {
    return _RayVec3(
      (y * other.z) - (z * other.y),
      (z * other.x) - (x * other.z),
      (x * other.y) - (y * other.x),
    );
  }

  double get length => math.sqrt((x * x) + (y * y) + (z * z));

  _RayVec3 normalized() {
    final len = length;
    if (len == 0) {
      return this;
    }
    return _RayVec3(x / len, y / len, z / len);
  }
}

class _CountryMarker extends StatelessWidget {
  const _CountryMarker({
    required this.country,
    required this.isSelected,
    required this.isFocused,
  });

  final RecordGlobeCountry country;
  final bool isSelected;
  final bool isFocused;

  @override
  Widget build(BuildContext context) {
    final strings = RecordStrings.of(context);
    final (coreColor, ringColor, haloColor) = _markerPalette(country.signal);
    final size = isSelected
        ? 34.0
        : (isFocused || country.hasUpcomingTrip)
            ? 24.0
            : 18.0;
    final showLabel = isSelected;
    final showLabelAbove = country.anchorLatitude < 24;
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
          strings.countryName(country.code, country.name),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
        ),
      ),
    );

    Widget animatedPin(Widget child) {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 320),
        switchInCurve: Curves.easeOutBack,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.16),
                end: Offset.zero,
              ).animate(animation),
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.82, end: 1.0).animate(animation),
                child: child,
              ),
            ),
          );
        },
        child: child,
      );
    }

    Widget buildPinStem() {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: 2,
        height: isSelected ? 14 : 10,
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: ringColor.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(999),
        ),
      );
    }

    return IgnorePointer(
      child: SizedBox(
        width: 140,
        height: 136,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            if (showLabelAbove)
              Positioned(
                bottom: 74 + (size / 2) + 2,
                left: 0,
                right: 0,
                child: animatedPin(
                  showLabel
                      ? Column(
                          key: ValueKey('pin-above-${country.code}'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            label,
                            buildPinStem(),
                          ],
                        )
                      : const SizedBox.shrink(key: ValueKey('pin-empty-above')),
                ),
              ),
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
            if (!showLabelAbove)
              Positioned(
                top: 74 + (size / 2) + 2,
                left: 0,
                right: 0,
                child: animatedPin(
                  showLabel
                      ? Column(
                          key: ValueKey('pin-below-${country.code}'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            buildPinStem(),
                            label,
                          ],
                        )
                      : const SizedBox.shrink(key: ValueKey('pin-empty-below')),
                ),
              ),
          ],
        ),
      ),
    );
  }

  (Color, Color, Color) _markerPalette(RecordGlobeCountrySignal signal) {
    return switch (signal) {
      RecordGlobeCountrySignal.planned => (
          const Color(0xFF68DDE8),
          const Color(0xFFD7FAFF),
          const Color(0xFF7AF2FF),
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
