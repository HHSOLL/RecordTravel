import 'package:flutter/material.dart';
import 'package:flutter_globe_3d/flutter_globe_3d.dart';

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

class RecordGlobeViewport extends StatefulWidget {
  const RecordGlobeViewport({
    super.key,
    required this.state,
    this.size,
    this.onCountrySelected,
    this.loadingBuilder,
  });

  static RouteObserver<ModalRoute<dynamic>> get navigatorObserver =>
      Earth3D.routeObserver;

  final RecordGlobeViewState state;
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
    if (!_sameViewportState(oldWidget.state, widget.state)) {
      _syncController();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  bool _sameViewportState(
    RecordGlobeViewState previous,
    RecordGlobeViewState next,
  ) {
    final previousSpec = previous.sceneSpec;
    final nextSpec = next.sceneSpec;
    if (previousSpec == null || nextSpec == null) {
      return previousSpec == nextSpec;
    }

    return previous.selectedCountryCode == next.selectedCountryCode &&
        previous.focusedCountryCode == next.focusedCountryCode &&
        previousSpec.style == nextSpec.style &&
        previousSpec.countries.length == nextSpec.countries.length &&
        _countrySignature(previousSpec.countries) ==
            _countrySignature(nextSpec.countries);
  }

  void _syncController() {
    final sceneSpec = widget.state.sceneSpec;
    final signature = sceneSpec == null
        ? null
        : [
            sceneSpec.style.name,
            widget.state.focusedCountryCode ?? '',
            widget.state.selectedCountryCode ?? '',
            _countrySignature(sceneSpec.countries),
          ].join('|');

    if (signature == _signature) {
      return;
    }

    final nextController = sceneSpec == null
        ? null
        : _buildController(sceneSpec.countries, widget.state);

    _controller?.dispose();
    _controller = nextController;
    _signature = signature;
  }

  EarthController _buildController(
    List<RecordGlobeCountry> countries,
    RecordGlobeViewState state,
  ) {
    final controller = EarthController()
      ..enableAutoRotate = state.selectedCountryCode == null
      ..rotateSpeed = 0.18
      ..minZoom = 1.16
      ..maxZoom = 2.4
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
        state.selectedCountryCode == null ? 1.5 : 1.68,
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
      child: Earth3D(
        key: ValueKey(_signature),
        shaderAsset: _recordGlobeShaderAsset,
        controller: controller,
        texture: _textureForStyle(sceneSpec.style),
        nightTexture: null,
        initialScale: _resolveInitialScale(sceneSpec.style),
      ),
    );
  }

  ImageProvider _textureForStyle(RecordGlobeStyle style) {
    return style == RecordGlobeStyle.dark
        ? _defaultNightTexture
        : _defaultDayTexture;
  }

  double _resolveInitialScale(RecordGlobeStyle style) {
    final size = widget.size ?? 0;
    if (size >= 420) {
      return style == RecordGlobeStyle.dark ? 1.76 : 1.68;
    }
    if (size >= 360) {
      return style == RecordGlobeStyle.dark ? 1.9 : 1.82;
    }
    if (size >= 300) {
      return style == RecordGlobeStyle.dark ? 2.08 : 2.0;
    }
    return style == RecordGlobeStyle.dark ? 2.22 : 2.14;
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
        ? 30.0
        : (isFocused || country.hasUpcomingTrip)
            ? 24.0
            : 18.0;
    final showLabel = isSelected || (isFocused && country.activityLevel > 0);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
          if (showLabel) ...[
            const SizedBox(height: 4),
            DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xCC020617),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: ringColor.withValues(alpha: 0.28)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  country.name,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ),
          ],
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
