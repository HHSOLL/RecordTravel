import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'record_country_geometry.dart';
import 'record_globe_scene.dart';

class RecordGlobe extends StatefulWidget {
  const RecordGlobe({
    super.key,
    required this.size,
    required this.scene,
    this.selectedCountryCode,
    this.onCountrySelected,
    this.onCountryOpen,
  });

  final double size;
  final RecordGlobeScene scene;
  final String? selectedCountryCode;
  final ValueChanged<String>? onCountrySelected;
  final ValueChanged<String>? onCountryOpen;

  @override
  State<RecordGlobe> createState() => _RecordGlobeState();
}

class _RecordGlobeState extends State<RecordGlobe>
    with TickerProviderStateMixin {
  static Future<_GlobeBundle?>? _bundleFuture;
  static const _textureMaskInset = 1.25;

  late final AnimationController _spinCtrl;
  late final AnimationController _focusCtrl;

  double _yaw = 1.52;
  double _pitch = 0.18;
  bool _isDragging = false;

  double _focusStartYaw = 0;
  double _focusEndYaw = 0;
  double _focusStartPitch = 0;
  double _focusEndPitch = 0;
  double _dragDistance = 0;
  RecordCountryGeometryBundle? _geometry;

  Future<_GlobeBundle?> get _cachedBundleFuture =>
      _bundleFuture ??= _loadGlobeBundle();

  String? get _currentFocusCountry =>
      widget.selectedCountryCode ?? widget.scene.initialCountryCode;

  @override
  void initState() {
    super.initState();
    final initialTarget = _orbitTargetForCountry(_currentFocusCountry);
    if (initialTarget != null) {
      _yaw = initialTarget.yaw;
      _pitch = initialTarget.pitch;
    }

    _focusCtrl =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 720),
        )..addListener(() {
          final value = Curves.easeInOutCubic.transform(_focusCtrl.value);
          setState(() {
            _yaw = _wrapAngle(_focusStartYaw + (_focusEndYaw * value));
            _pitch = _wrapAngle(_focusStartPitch + (_focusEndPitch * value));
          });
        });

    _spinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 72),
    )..repeat();
    _spinCtrl.addListener(() {
      if (!_isDragging &&
          !_focusCtrl.isAnimating &&
          _currentFocusCountry == null &&
          mounted) {
        setState(() {
          _yaw = _wrapAngle(_yaw - 0.0018);
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant RecordGlobe oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldFocus =
        oldWidget.selectedCountryCode ?? oldWidget.scene.initialCountryCode;
    final nextFocus = _currentFocusCountry;
    if (oldFocus != nextFocus) {
      _animateToCountry(nextFocus);
    }
  }

  @override
  void dispose() {
    _spinCtrl.dispose();
    _focusCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.atlasPalette;
    final scene = widget.scene;
    final selectedCountryCode = widget.selectedCountryCode;
    final effectiveSelectedCountryCode =
        selectedCountryCode ?? scene.initialCountryCode;
    final visitCounts = {
      for (final anchor in scene.anchors)
        anchor.countryCode: anchor.markerCount,
    };
    final projectedAnchors = _projectAnchors(
      scene.anchors,
      widget.size,
      yaw: _yaw,
      pitch: _pitch,
    )..sort((a, b) => a.depth.compareTo(b.depth));

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: FutureBuilder<_GlobeBundle?>(
        future: _cachedBundleFuture,
        builder: (context, snapshot) {
          final bundle = snapshot.data;
          _geometry = bundle?.geometry;
          final assets = bundle?.assets;
          final projectedCountries = bundle == null
              ? const <_ProjectedCountry>[]
              : _projectCountries(
                  bundle.geometry.countries.where(
                    (country) =>
                        visitCounts.containsKey(country.code) ||
                        country.code == effectiveSelectedCountryCode,
                  ),
                  Size.square(widget.size),
                  yaw: _yaw,
                  pitch: _pitch,
                  visitCounts: visitCounts,
                  selectedCountryCode: effectiveSelectedCountryCode,
                  isLight: palette.isLight,
                );
          final selectedCountry = _resolveSelectedCountry(
            effectiveSelectedCountryCode,
            projectedCountries,
            bundle?.geometry,
            visitCounts,
            palette.isLight,
          );
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: (_) {
              _isDragging = true;
              _dragDistance = 0;
              if (_focusCtrl.isAnimating) {
                _focusCtrl.stop();
              }
            },
            onPanEnd: (_) => _isDragging = false,
            onPanCancel: () => _isDragging = false,
            onPanUpdate: (details) {
              _dragDistance += details.delta.distance;
              setState(() {
                _yaw = _wrapAngle(_yaw - details.delta.dx * 0.0082);
                _pitch = _wrapAngle(_pitch - details.delta.dy * 0.0082);
              });
            },
            onTapUp: (details) {
              if (_dragDistance > 8) {
                return;
              }
              final tappedCountry = _hitTestCountry(
                details.localPosition,
                bundle?.geometry,
                visitCounts,
                palette.isLight,
              );
              if (tappedCountry != null) {
                widget.onCountrySelected?.call(tappedCountry.country.code);
              }
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _TexturedGlobePainter(
                      assets: assets,
                      yaw: _yaw,
                      pitch: _pitch,
                      style: scene.style,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: CustomPaint(
                    painter: _GlobeStoryPainter(
                      scene: scene,
                      projectedAnchors: projectedAnchors,
                      selectedCountryCode: effectiveSelectedCountryCode,
                      yaw: _yaw,
                      pitch: _pitch,
                      isLight: palette.isLight,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _CountryOverlayPainter(
                        countries: projectedCountries,
                        isLight: palette.isLight,
                      ),
                    ),
                  ),
                ),
                if (selectedCountry != null)
                  _SelectedCountryPin(
                    projectedCountry: selectedCountry,
                    onTap: () => widget.onCountryOpen?.call(
                      selectedCountry.country.code,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  _ProjectedCountry? _hitTestCountry(
    Offset point,
    RecordCountryGeometryBundle? geometry,
    Map<String, int> visitCounts,
    bool isLight,
  ) {
    final geometryBundle = geometry;
    if (geometryBundle == null) {
      return null;
    }
    final projectedCountries = _projectCountries(
      geometryBundle.countries,
      Size.square(widget.size),
      yaw: _yaw,
      pitch: _pitch,
      visitCounts: visitCounts,
      selectedCountryCode: widget.selectedCountryCode,
      isLight: isLight,
      includeUnvisitedPaths: true,
    );
    for (final country in projectedCountries.reversed) {
      if (country.opacity <= 0.08) {
        continue;
      }
      for (final path in country.paths) {
        if (path.contains(point)) {
          return country;
        }
      }
    }
    return null;
  }

  _ProjectedCountry? _resolveSelectedCountry(
    String? selectedCountryCode,
    List<_ProjectedCountry> projectedCountries,
    RecordCountryGeometryBundle? geometry,
    Map<String, int> visitCounts,
    bool isLight,
  ) {
    if (selectedCountryCode == null) {
      return null;
    }
    for (final country in projectedCountries) {
      if (country.country.code == selectedCountryCode) {
        return country;
      }
    }
    final selectedGeometry = geometry?.byCode[selectedCountryCode];
    if (selectedGeometry == null) {
      return null;
    }
    final fallback = _projectCountries(
      [selectedGeometry],
      Size.square(widget.size),
      yaw: _yaw,
      pitch: _pitch,
      visitCounts: visitCounts,
      selectedCountryCode: selectedCountryCode,
      isLight: isLight,
      includeUnvisitedPaths: false,
    );
    return fallback.isEmpty ? null : fallback.first;
  }

  _ProjectedCountry? _hitTestProjectedCountry(
    Offset point,
    List<_ProjectedCountry> countries,
  ) {
    for (final country in countries.reversed) {
      if (country.opacity <= 0.08) {
        continue;
      }
      for (final path in country.paths) {
        if (path.contains(point)) {
          return country;
        }
      }
    }
    return null;
  }

  _OrbitTarget? _orbitTargetForCountry(String? countryCode) {
    if (countryCode == null) return null;
    final anchor = widget.scene.anchorForCountry(countryCode);
    final geometry = _geometry?.byCode[countryCode];
    final latitude = anchor?.latitude ?? geometry?.centroidLat;
    final longitude = anchor?.longitude ?? geometry?.centroidLng;
    if (latitude == null || longitude == null) return null;
    return _OrbitTarget(
      yaw: _wrapAngle(longitude * math.pi / 180),
      pitch: _wrapAngle(-(latitude * math.pi / 180)),
    );
  }

  void _animateToCountry(String? countryCode) {
    final target = _orbitTargetForCountry(countryCode);
    if (target == null) return;
    _focusStartYaw = _yaw;
    _focusStartPitch = _pitch;
    _focusEndYaw = _shortestAngleDelta(_yaw, target.yaw);
    _focusEndPitch = _shortestAngleDelta(_pitch, target.pitch);
    _focusCtrl
      ..reset()
      ..forward();
  }

  static Future<_GlobeBundle?> _loadGlobeBundle() async {
    final assets = await _loadGlobeAssets();
    final geometry = await RecordCountryGeometryBundle.load();
    if (assets == null) {
      return null;
    }
    return _GlobeBundle(assets: assets, geometry: geometry);
  }

  static Future<_GlobeAssets?> _loadGlobeAssets() async {
    final rawLightEarthImage =
        await _tryLoadAssetImage('assets/globe/earth_storybook_light.png') ??
        await _tryLoadAssetImage('assets/globe/earth-blue-marble.jpg');
    final rawDarkEarthImage =
        await _tryLoadAssetImage('assets/globe/earth_storybook_dark.png') ??
        await _tryLoadAssetImage('assets/globe/earth-night.jpg') ??
        await _tryLoadAssetImage('assets/globe/earth_day_albedo_v1_4096.webp');

    final lightEarthImage = rawLightEarthImage == null
        ? null
        : await _prepareEarthTexture(rawLightEarthImage);
    final darkEarthImage = rawDarkEarthImage == null
        ? null
        : await _prepareEarthTexture(rawDarkEarthImage);

    if (lightEarthImage == null && darkEarthImage == null) {
      return null;
    }

    return _GlobeAssets(
      lightEarthImage: lightEarthImage ?? darkEarthImage,
      darkEarthImage: darkEarthImage ?? lightEarthImage,
    );
  }

  static Future<ui.Image> _loadAssetImage(String assetKey) async {
    final data = await rootBundle.load(assetKey);
    final codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      allowUpscaling: false,
    );
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  static Future<ui.Image?> _tryLoadAssetImage(String assetKey) async {
    try {
      return await _loadAssetImage(assetKey);
    } catch (_) {
      return null;
    }
  }

  static Future<ui.Image> _prepareEarthTexture(ui.Image image) async {
    final width = image.width;
    final height = image.height;
    final trimmedSource =
        await _detectTextureContentRect(image) ??
        Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble());
    final inset = math.max(2, (trimmedSource.width * 0.006).round());
    final seamBlend = math.max(4, (width * 0.014).round());
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final fullRect = Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble());
    final sourceRect = Rect.fromLTWH(
      trimmedSource.left + inset,
      trimmedSource.top,
      math.max(1, trimmedSource.width - inset * 2),
      trimmedSource.height,
    );

    canvas.drawImageRect(
      image,
      sourceRect,
      fullRect,
      Paint()..filterQuality = FilterQuality.high,
    );

    final leftDst = Rect.fromLTWH(
      0,
      0,
      seamBlend.toDouble(),
      height.toDouble(),
    );
    final rightDst = Rect.fromLTWH(
      width - seamBlend.toDouble(),
      0,
      seamBlend.toDouble(),
      height.toDouble(),
    );
    final leftSrc = Rect.fromLTWH(
      sourceRect.right - seamBlend,
      sourceRect.top,
      seamBlend.toDouble(),
      sourceRect.height,
    );
    final rightSrc = Rect.fromLTWH(
      sourceRect.left,
      sourceRect.top,
      seamBlend.toDouble(),
      sourceRect.height,
    );

    canvas.saveLayer(leftDst, Paint());
    canvas.drawImageRect(
      image,
      leftSrc,
      leftDst,
      Paint()..filterQuality = FilterQuality.high,
    );
    canvas.drawRect(
      leftDst,
      Paint()
        ..blendMode = BlendMode.dstIn
        ..shader = const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Colors.white, Colors.transparent],
        ).createShader(leftDst),
    );
    canvas.restore();

    canvas.saveLayer(rightDst, Paint());
    canvas.drawImageRect(
      image,
      rightSrc,
      rightDst,
      Paint()..filterQuality = FilterQuality.high,
    );
    canvas.drawRect(
      rightDst,
      Paint()
        ..blendMode = BlendMode.dstIn
        ..shader = const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Colors.transparent, Colors.white],
        ).createShader(rightDst),
    );
    canvas.restore();

    final picture = recorder.endRecording();
    return picture.toImage(width, height);
  }

  static Future<Rect?> _detectTextureContentRect(ui.Image image) async {
    final bytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (bytes == null) {
      return null;
    }
    final width = image.width;
    final height = image.height;
    final data = bytes.buffer.asUint8List();

    bool isBackgroundPixel(int x, int y) {
      final offset = (y * width + x) * 4;
      final r = data[offset];
      final g = data[offset + 1];
      final b = data[offset + 2];
      final a = data[offset + 3];
      return a < 8 || (r > 238 && g > 238 && b > 238);
    }

    bool isBackgroundRow(int y) {
      var backgroundCount = 0;
      for (var x = 0; x < width; x++) {
        if (isBackgroundPixel(x, y)) {
          backgroundCount += 1;
        }
      }
      return backgroundCount / width > 0.94;
    }

    bool isBackgroundColumn(int x, int top, int bottom) {
      var backgroundCount = 0;
      final heightSpan = bottom - top + 1;
      for (var y = top; y <= bottom; y++) {
        if (isBackgroundPixel(x, y)) {
          backgroundCount += 1;
        }
      }
      return backgroundCount / heightSpan > 0.94;
    }

    var top = 0;
    while (top < height - 1 && isBackgroundRow(top)) {
      top += 1;
    }

    var bottom = height - 1;
    while (bottom > top && isBackgroundRow(bottom)) {
      bottom -= 1;
    }

    var left = 0;
    while (left < width - 1 && isBackgroundColumn(left, top, bottom)) {
      left += 1;
    }

    var right = width - 1;
    while (right > left && isBackgroundColumn(right, top, bottom)) {
      right -= 1;
    }

    if (left == 0 && top == 0 && right == width - 1 && bottom == height - 1) {
      return null;
    }

    return Rect.fromLTWH(
      left.toDouble(),
      top.toDouble(),
      (right - left + 1).toDouble(),
      (bottom - top + 1).toDouble(),
    );
  }
}

class _GlobeBundle {
  const _GlobeBundle({required this.assets, required this.geometry});

  final _GlobeAssets assets;
  final RecordCountryGeometryBundle geometry;
}

class _GlobeAssets {
  const _GlobeAssets({
    required this.lightEarthImage,
    required this.darkEarthImage,
  });

  final ui.Image? lightEarthImage;
  final ui.Image? darkEarthImage;
}

class _OrbitTarget {
  const _OrbitTarget({required this.yaw, required this.pitch});

  final double yaw;
  final double pitch;
}

class _ProjectedAnchor {
  const _ProjectedAnchor({
    required this.anchor,
    required this.position,
    required this.depth,
    required this.opacity,
    required this.scale,
  });

  final RecordGlobeAnchor anchor;
  final Offset position;
  final double depth;
  final double opacity;
  final double scale;

  bool get isFront => depth > 0;
}

class _ProjectedPoint {
  const _ProjectedPoint({required this.position, required this.depth});

  final Offset position;
  final double depth;
}

class _ProjectedCountry {
  const _ProjectedCountry({
    required this.country,
    required this.paths,
    required this.center,
    required this.depth,
    required this.opacity,
    required this.visitCount,
    required this.fillColor,
    required this.strokeColor,
    required this.isSelected,
  });

  final RecordCountryGeometry country;
  final List<Path> paths;
  final Offset center;
  final double depth;
  final double opacity;
  final int visitCount;
  final Color fillColor;
  final Color strokeColor;
  final bool isSelected;
}

class _SelectedCountryPin extends StatelessWidget {
  const _SelectedCountryPin({
    required this.projectedCountry,
    required this.onTap,
  });

  final _ProjectedCountry projectedCountry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.atlasPalette;
    final width = 132.0;
    return Positioned(
      left: projectedCountry.center.dx - (width / 2),
      top: projectedCountry.center.dy - 62,
      child: Opacity(
        opacity: projectedCountry.opacity,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.translucent,
          child: SizedBox(
            width: width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: palette.surfaceGlass.withValues(
                      alpha: palette.isLight ? 0.96 : 0.88,
                    ),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: projectedCountry.strokeColor.withValues(
                        alpha: 0.52,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: projectedCountry.fillColor.withValues(
                          alpha: 0.18,
                        ),
                        blurRadius: 18,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Text(
                    projectedCountry.country.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: projectedCountry.fillColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.8),
                      width: 2,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TexturedGlobePainter extends CustomPainter {
  const _TexturedGlobePainter({
    required this.assets,
    required this.yaw,
    required this.pitch,
    required this.style,
  });

  final _GlobeAssets? assets;
  final double yaw;
  final double pitch;
  final RecordGlobeStyle style;

  static final Float64List _identityMatrix = Float64List.fromList([
    1,
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    0,
    1,
  ]);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = size.width / 2;
    final isLight = style == RecordGlobeStyle.storybookLight;
    final spherePath = Path()
      ..addOval(
        Rect.fromCircle(
          center: center,
          radius: radius - _RecordGlobeState._textureMaskInset,
        ),
      );

    final outerGlow = Paint()
      ..color = (isLight ? const Color(0xFF9FD5FF) : const Color(0xFF2B8BFF))
          .withValues(alpha: isLight ? 0.12 : 0.10)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, isLight ? 18 : 22);
    canvas.drawCircle(center, radius + (isLight ? 2.5 : 3.0), outerGlow);

    if (!isLight) {
      final purpleGlow = Paint()
        ..color = const Color(0xFF7E5CF7).withValues(alpha: 0.05)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 26);
      canvas.drawCircle(center, radius + 4.0, purpleGlow);
    }

    canvas.save();
    canvas.clipPath(spherePath);

    final sphereBase = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.16, -0.28),
        radius: 0.98,
        colors: isLight
            ? const [
                Color(0xFFF1F8FF),
                Color(0xFFDCEEFF),
                Color(0xFFA9D1F1),
                Color(0xFF6F98C6),
              ]
            : const [
                Color(0xFF2E4268),
                Color(0xFF122443),
                Color(0xFF08111F),
                Color(0xFF03070F),
              ],
        stops: const [0, 0.34, 0.78, 1],
      ).createShader(rect);
    canvas.drawCircle(center, radius, sphereBase);

    final earth = switch (style) {
      RecordGlobeStyle.storybookLight => assets?.lightEarthImage,
      RecordGlobeStyle.orbitNight => assets?.darkEarthImage,
    };
    if (earth != null) {
      final mesh = _SphereMesh.build(
        size: size,
        textureWidth: earth.width.toDouble(),
        textureHeight: earth.height.toDouble(),
        yaw: yaw,
        pitch: pitch,
        style: style,
      );

      final earthPaint = Paint()
        ..isAntiAlias = true
        ..filterQuality = FilterQuality.low
        ..color = Colors.white.withValues(alpha: isLight ? 0.88 : 0.82)
        ..shader = ui.ImageShader(
          earth,
          ui.TileMode.repeated,
          ui.TileMode.clamp,
          _identityMatrix,
        );
      canvas.drawVertices(mesh, ui.BlendMode.srcOver, earthPaint);
    }

    final atmosphere = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.12, -0.18),
        radius: 1.02,
        colors: isLight
            ? const [Color(0x0CF7FBFF), Color(0x10E6F4FF), Color(0x124776A4)]
            : const [Color(0x04000000), Color(0x06004173), Color(0x18040C1D)],
        stops: const [0, 0.74, 1],
      ).createShader(rect);
    canvas.drawCircle(center, radius, atmosphere);

    final glaze = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.18, -0.20),
        radius: 1.0,
        colors: isLight
            ? [
                const Color(0x22FFFFFF),
                const Color(0x14F3F9FF),
                const Color(0x10CDE3D1),
                const Color(0x00FFFFFF),
              ]
            : [
                const Color(0x0E00B4FF),
                const Color(0x0C004C8F),
                const Color(0x0A8A5CF7),
                const Color(0x00000000),
              ],
      ).createShader(rect);
    canvas.drawRect(rect, glaze);

    final lighting = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.white.withValues(alpha: isLight ? 0.06 : 0.05),
          Colors.transparent,
          isLight ? const Color(0x0C165386) : const Color(0x50000915),
        ],
        stops: const [0, 0.38, 1],
      ).createShader(rect);
    canvas.drawRect(rect, lighting);

    final specular = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.34, -0.28),
        radius: 0.46,
        colors: [
          Colors.white.withValues(alpha: isLight ? 0.08 : 0.08),
          Colors.white.withValues(alpha: isLight ? 0.03 : 0.03),
          Colors.transparent,
        ],
      ).createShader(rect);
    canvas.drawCircle(center, radius, specular);

    final edgeFeather = Paint()
      ..shader = RadialGradient(
        radius: 1.0,
        colors: isLight
            ? const [
                Color(0x00000000),
                Color(0x00000000),
                Color(0x083E6B95),
                Color(0x144E81A8),
              ]
            : const [
                Color(0x00000000),
                Color(0x00000000),
                Color(0x10020812),
                Color(0x24010612),
              ],
        stops: const [0, 0.88, 0.96, 1],
      ).createShader(rect);
    canvas.drawCircle(center, radius, edgeFeather);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _TexturedGlobePainter oldDelegate) {
    return oldDelegate.assets != assets ||
        oldDelegate.yaw != yaw ||
        oldDelegate.pitch != pitch ||
        oldDelegate.style != style;
  }
}

class _GlobeStoryPainter extends CustomPainter {
  const _GlobeStoryPainter({
    required this.scene,
    required this.projectedAnchors,
    required this.selectedCountryCode,
    required this.yaw,
    required this.pitch,
    required this.isLight,
  });

  final RecordGlobeScene scene;
  final List<_ProjectedAnchor> projectedAnchors;
  final String? selectedCountryCode;
  final double yaw;
  final double pitch;
  final bool isLight;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final spherePath = Path()..addOval(rect);
    final projectedByCountry = {
      for (final projected in projectedAnchors)
        projected.anchor.countryCode: projected,
    };

    canvas.save();
    canvas.clipPath(spherePath);

    final selected = selectedCountryCode == null
        ? null
        : projectedByCountry[selectedCountryCode];
    if (selected != null && selected.depth > -0.05) {
      final halo = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = selected.anchor.color.withValues(
          alpha: selected.isFront ? 0.65 : 0.18,
        );
      canvas.drawCircle(
        selected.position,
        14 + (selected.isFront ? 10 : 4),
        halo,
      );

      final glow = Paint()
        ..color = selected.anchor.color.withValues(alpha: 0.12);
      canvas.drawCircle(
        selected.position,
        20 + (selected.isFront ? 16 : 6),
        glow,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _GlobeStoryPainter oldDelegate) {
    return oldDelegate.scene != scene ||
        oldDelegate.selectedCountryCode != selectedCountryCode ||
        oldDelegate.yaw != yaw ||
        oldDelegate.pitch != pitch ||
        oldDelegate.isLight != isLight ||
        oldDelegate.projectedAnchors != projectedAnchors;
  }
}

class _CountryOverlayPainter extends CustomPainter {
  const _CountryOverlayPainter({
    required this.countries,
    required this.isLight,
  });

  final List<_ProjectedCountry> countries;
  final bool isLight;

  @override
  void paint(Canvas canvas, Size size) {
    final clipPath = Path()
      ..addOval((Offset.zero & size).deflate(isLight ? 3.5 : 5.0));
    canvas.save();
    canvas.clipPath(clipPath);

    for (final country in countries) {
      if (country.opacity <= 0.05 || country.visitCount == 0) {
        continue;
      }
      final fill = Paint()
        ..style = PaintingStyle.fill
        ..color = country.fillColor.withValues(
          alpha:
              country.opacity *
              (country.isSelected
                  ? (isLight ? 0.66 : 0.58)
                  : (isLight ? 0.46 : 0.38)),
        );
      final glow = Paint()
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10)
        ..color = country.fillColor.withValues(
          alpha: country.isSelected
              ? (isLight ? 0.20 : 0.18)
              : (isLight ? 0.10 : 0.08),
        );

      for (final path in country.paths) {
        final bounds = path.getBounds();
        if (bounds.width > size.width * 0.42 ||
            bounds.height > size.width * 0.42) {
          continue;
        }
        canvas.drawPath(path, glow);
        canvas.drawPath(path, fill);
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CountryOverlayPainter oldDelegate) {
    return oldDelegate.countries != countries || oldDelegate.isLight != isLight;
  }
}

List<_ProjectedCountry> _projectCountries(
  Iterable<RecordCountryGeometry> countries,
  Size size, {
  required double yaw,
  required double pitch,
  required Map<String, int> visitCounts,
  required String? selectedCountryCode,
  required bool isLight,
  bool includeUnvisitedPaths = false,
}) {
  final maxVisits = visitCounts.values.isEmpty
      ? 1
      : visitCounts.values.reduce(math.max);
  final projected = <_ProjectedCountry>[];
  for (final country in countries) {
    final visitCount = visitCounts[country.code] ?? 0;
    if (!includeUnvisitedPaths &&
        visitCount == 0 &&
        selectedCountryCode != country.code) {
      continue;
    }
    final centerPoint = _projectLatLng(
      country.centroidLat,
      country.centroidLng,
      size,
      yaw: yaw,
      pitch: pitch,
    );
    if (centerPoint.depth <= -0.3) {
      continue;
    }

    final paths = <Path>[];
    for (final polygon in country.polygons) {
      final projectedPoints = <_ProjectedPoint>[];
      for (final point in polygon) {
        projectedPoints.add(
          _projectLatLng(
            point.latitude,
            point.longitude,
            size,
            yaw: yaw,
            pitch: pitch,
          ),
        );
      }
      final visiblePoints = projectedPoints
          .where((point) => point.depth > -0.22)
          .length;
      if (visiblePoints < math.max(3, projectedPoints.length ~/ 3)) {
        continue;
      }
      paths.addAll(
        _buildCountryPaths(
          polygon,
          projectedPoints,
          size,
          skipAntiMeridianPolygons: !includeUnvisitedPaths,
        ),
      );
    }

    if (paths.isEmpty) {
      continue;
    }

    final visitT = visitCount <= 0
        ? 0.0
        : (visitCount / maxVisits).clamp(0.18, 1.0);
    final fillColor = isLight
        ? Color.lerp(const Color(0xFFDDEBFF), const Color(0xFF4C84FF), visitT)!
        : Color.lerp(const Color(0xFF24365E), const Color(0xFF87B6FF), visitT)!;
    final strokeColor = isLight
        ? const Color(0xFFADC4E4)
        : const Color(0xFF5F7191);
    final opacity = centerPoint.depth <= -0.1
        ? 0.18 + (centerPoint.depth + 0.1) * 0.3
        : 0.4 + centerPoint.depth * 0.6;

    projected.add(
      _ProjectedCountry(
        country: country,
        paths: paths,
        center: centerPoint.position,
        depth: centerPoint.depth,
        opacity: opacity.clamp(0.0, 1.0),
        visitCount: visitCount,
        fillColor: fillColor,
        strokeColor: strokeColor,
        isSelected: selectedCountryCode == country.code,
      ),
    );
  }
  projected.sort((a, b) => a.depth.compareTo(b.depth));
  return projected;
}

List<Path> _buildCountryPaths(
  List<RecordGeoPoint> polygon,
  List<_ProjectedPoint> projectedPoints,
  Size size, {
  required bool skipAntiMeridianPolygons,
}) {
  if (skipAntiMeridianPolygons &&
      (_polygonCrossesAntiMeridian(polygon) ||
          _projectedPolygonHasLargeJump(projectedPoints, size))) {
    return const [];
  }

  final paths = <Path>[];
  Path? currentPath;
  var subpathCount = 0;
  _ProjectedPoint? previousProjected;
  RecordGeoPoint? previousGeo;

  void closeCurrentPath() {
    if (currentPath != null && subpathCount >= 3) {
      currentPath!.close();
      paths.add(currentPath!);
    }
    currentPath = null;
    subpathCount = 0;
  }

  for (var index = 0; index < polygon.length; index++) {
    final geo = polygon[index];
    final projected = projectedPoints[index];
    final shouldSplit =
        previousProjected != null &&
        previousGeo != null &&
        (_crossesAntiMeridian(previousGeo.longitude, geo.longitude) ||
            (projected.position - previousProjected.position).distance >
                size.width * 0.24);

    if (shouldSplit) {
      closeCurrentPath();
    }

    if (currentPath == null) {
      currentPath = Path()
        ..moveTo(projected.position.dx, projected.position.dy);
      subpathCount = 1;
    } else {
      currentPath!.lineTo(projected.position.dx, projected.position.dy);
      subpathCount += 1;
    }

    previousProjected = projected;
    previousGeo = geo;
  }

  closeCurrentPath();
  return paths;
}

bool _crossesAntiMeridian(double a, double b) {
  return (a - b).abs() > 180;
}

bool _polygonCrossesAntiMeridian(List<RecordGeoPoint> polygon) {
  if (polygon.isEmpty) {
    return false;
  }
  for (var index = 1; index < polygon.length; index++) {
    if (_crossesAntiMeridian(
      polygon[index - 1].longitude,
      polygon[index].longitude,
    )) {
      return true;
    }
  }
  return _crossesAntiMeridian(polygon.last.longitude, polygon.first.longitude);
}

bool _projectedPolygonHasLargeJump(
  List<_ProjectedPoint> projectedPoints,
  Size size,
) {
  if (projectedPoints.length < 2) {
    return false;
  }
  final threshold = size.width * 0.24;
  for (var index = 1; index < projectedPoints.length; index++) {
    if ((projectedPoints[index].position - projectedPoints[index - 1].position)
            .distance >
        threshold) {
      return true;
    }
  }
  return (projectedPoints.first.position - projectedPoints.last.position)
          .distance >
      threshold;
}

List<_ProjectedAnchor> _projectAnchors(
  List<RecordGlobeAnchor> anchors,
  double size, {
  required double yaw,
  required double pitch,
}) {
  return [
    for (final anchor in anchors)
      _projectAnchor(anchor, size, yaw: yaw, pitch: pitch),
  ];
}

_ProjectedAnchor _projectAnchor(
  RecordGlobeAnchor anchor,
  double size, {
  required double yaw,
  required double pitch,
}) {
  final projected = _projectLatLng(
    anchor.latitude,
    anchor.longitude,
    Size.square(size),
    yaw: yaw,
    pitch: pitch,
  );
  final opacity = projected.depth <= -0.18
      ? 0.0
      : projected.depth <= 0
      ? 0.08 + (projected.depth + 0.18) * 0.25
      : 0.38 + projected.depth * 0.58;
  final scale = 0.72 + (((projected.depth + 1) / 2).clamp(0.0, 1.0) * 0.45);
  return _ProjectedAnchor(
    anchor: anchor,
    position: projected.position,
    depth: projected.depth,
    opacity: opacity.clamp(0.0, 1.0),
    scale: scale,
  );
}

_ProjectedPoint _projectLatLng(
  double latitude,
  double longitude,
  Size size, {
  required double yaw,
  required double pitch,
}) {
  final radius = size.width / 2;
  final center = size.center(Offset.zero);
  final point = _latLngToVector(latitude, longitude);
  final rotated = _rotateX(_rotateY(point, -yaw), -pitch);
  return _ProjectedPoint(
    position: Offset(
      center.dx + rotated.x * radius,
      center.dy - rotated.y * radius,
    ),
    depth: rotated.z.clamp(-1.0, 1.0),
  );
}

_Vec3 _latLngToVector(double latitude, double longitude) {
  final lat = latitude * math.pi / 180;
  final lng = longitude * math.pi / 180;
  return _Vec3(
    x: math.cos(lat) * math.sin(lng),
    y: math.sin(lat),
    z: math.cos(lat) * math.cos(lng),
  );
}

double _shortestAngleDelta(double current, double target) {
  return _wrapAngle(target - current);
}

class _SphereMesh {
  static ui.Vertices build({
    required Size size,
    required double textureWidth,
    required double textureHeight,
    required double yaw,
    required double pitch,
    required RecordGlobeStyle style,
  }) {
    final segments = math.max(
      style == RecordGlobeStyle.storybookLight ? 104 : 100,
      (size.width * 0.28).round(),
    );
    final rows = segments;
    final columns = segments;
    final radius = size.width / 2;
    final center = size.center(Offset.zero);
    final positions = <Offset>[];
    final textureCoordinates = <Offset>[];
    final grid = List.generate(
      rows + 1,
      (_) => List<_MeshVertex?>.filled(columns + 1, null),
    );

    for (var row = 0; row <= rows; row++) {
      final ny = row / rows * 2 - 1;
      for (var column = 0; column <= columns; column++) {
        final nx = column / columns * 2 - 1;
        final squared = nx * nx + ny * ny;
        if (squared > 1) {
          continue;
        }

        final rotated = _inverseRotate(
          _Vec3(x: nx, y: -ny, z: math.sqrt(math.max(0, 1 - squared))),
          yaw: yaw,
          pitch: pitch,
        );
        final latitude = math.asin(rotated.y.clamp(-1.0, 1.0));
        final longitude = math.atan2(rotated.x, rotated.z);
        final unwrappedLongitude = yaw + _wrapAngle(longitude - yaw);
        final sourceX =
            ((unwrappedLongitude / (2 * math.pi)) + 0.5) * textureWidth;
        final sourceY = (0.5 - latitude / math.pi) * textureHeight;

        grid[row][column] = _MeshVertex(
          position: Offset(center.dx + nx * radius, center.dy + ny * radius),
          textureCoordinate: Offset(sourceX, sourceY),
        );
      }
    }

    for (var row = 0; row < rows; row++) {
      for (var column = 0; column < columns; column++) {
        final topLeft = grid[row][column];
        final topRight = grid[row][column + 1];
        final bottomLeft = grid[row + 1][column];
        final bottomRight = grid[row + 1][column + 1];

        if (topLeft != null && topRight != null && bottomLeft != null) {
          _appendTriangle(
            positions,
            textureCoordinates,
            textureWidth,
            topLeft,
            topRight,
            bottomLeft,
          );
        }
        if (topRight != null && bottomRight != null && bottomLeft != null) {
          _appendTriangle(
            positions,
            textureCoordinates,
            textureWidth,
            topRight,
            bottomRight,
            bottomLeft,
          );
        }
      }
    }

    return ui.Vertices(
      ui.VertexMode.triangles,
      positions,
      textureCoordinates: textureCoordinates,
    );
  }

  static void _appendTriangle(
    List<Offset> positions,
    List<Offset> textureCoordinates,
    double textureWidth,
    _MeshVertex a,
    _MeshVertex b,
    _MeshVertex c,
  ) {
    final uValues = [
      a.textureCoordinate.dx,
      b.textureCoordinate.dx,
      c.textureCoordinate.dx,
    ];
    final minU = uValues.reduce(math.min);
    final maxU = uValues.reduce(math.max);
    final wraps = maxU - minU > textureWidth / 2;

    for (final vertex in [a, b, c]) {
      var u = vertex.textureCoordinate.dx;
      if (wraps && u < textureWidth / 2) {
        u += textureWidth;
      }
      positions.add(vertex.position);
      textureCoordinates.add(Offset(u, vertex.textureCoordinate.dy));
    }
  }
}

class _MeshVertex {
  const _MeshVertex({required this.position, required this.textureCoordinate});

  final Offset position;
  final Offset textureCoordinate;
}

class _Vec3 {
  const _Vec3({required this.x, required this.y, required this.z});

  final double x;
  final double y;
  final double z;
}

_Vec3 _inverseRotate(
  _Vec3 point, {
  required double yaw,
  required double pitch,
}) {
  final pitched = _rotateX(point, pitch);
  return _rotateY(pitched, yaw);
}

_Vec3 _rotateX(_Vec3 point, double angle) {
  final cosAngle = math.cos(angle);
  final sinAngle = math.sin(angle);
  return _Vec3(
    x: point.x,
    y: point.y * cosAngle - point.z * sinAngle,
    z: point.y * sinAngle + point.z * cosAngle,
  );
}

_Vec3 _rotateY(_Vec3 point, double angle) {
  final cosAngle = math.cos(angle);
  final sinAngle = math.sin(angle);
  return _Vec3(
    x: point.x * cosAngle + point.z * sinAngle,
    y: point.y,
    z: -point.x * sinAngle + point.z * cosAngle,
  );
}

double _wrapAngle(double value) {
  var wrapped = value;
  while (wrapped <= -math.pi) {
    wrapped += 2 * math.pi;
  }
  while (wrapped > math.pi) {
    wrapped -= 2 * math.pi;
  }
  return wrapped;
}
