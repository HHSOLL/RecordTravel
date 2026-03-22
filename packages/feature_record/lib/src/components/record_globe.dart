import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'record_globe_scene.dart';

class RecordGlobe extends StatefulWidget {
  const RecordGlobe({
    super.key,
    required this.size,
    required this.scene,
    this.selectedCountryCode,
    this.onCountrySelected,
  });

  final double size;
  final RecordGlobeScene scene;
  final String? selectedCountryCode;
  final ValueChanged<String>? onCountrySelected;

  @override
  State<RecordGlobe> createState() => _RecordGlobeState();
}

class _RecordGlobeState extends State<RecordGlobe>
    with TickerProviderStateMixin {
  static Future<_GlobeAssets?>? _assetsFuture;

  late final AnimationController _spinCtrl;
  late final AnimationController _focusCtrl;

  double _yaw = 1.52;
  double _pitch = 0.18;
  bool _isDragging = false;

  double _focusStartYaw = 0;
  double _focusEndYaw = 0;
  double _focusStartPitch = 0;
  double _focusEndPitch = 0;

  Future<_GlobeAssets?> get _cachedAssetsFuture =>
      _assetsFuture ??= _loadGlobeAssets();

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
            _pitch = ui.lerpDouble(_focusStartPitch, _focusEndPitch, value)!;
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
    final projectedAnchors = _projectAnchors(
      scene.anchors,
      widget.size,
      yaw: _yaw,
      pitch: _pitch,
    )..sort((a, b) => a.depth.compareTo(b.depth));

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: FutureBuilder<_GlobeAssets?>(
        future: _cachedAssetsFuture,
        builder: (context, snapshot) {
          final assets = snapshot.data;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: (_) {
              _isDragging = true;
              if (_focusCtrl.isAnimating) {
                _focusCtrl.stop();
              }
            },
            onPanEnd: (_) => _isDragging = false,
            onPanCancel: () => _isDragging = false,
            onPanUpdate: (details) {
              setState(() {
                _yaw = _wrapAngle(_yaw - details.delta.dx * 0.0082);
                _pitch = (_pitch + details.delta.dy * 0.0048).clamp(
                  -0.58,
                  0.58,
                );
              });
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: palette.isLight
                              ? const Color(0xFF9AD0FF).withValues(alpha: 0.32)
                              : const Color(0xFF1BA8FF).withValues(alpha: 0.18),
                          blurRadius: palette.isLight ? 42 : 66,
                          spreadRadius: palette.isLight ? 2 : 4,
                        ),
                        if (!palette.isLight)
                          BoxShadow(
                            color: const Color(
                              0xFF8A5CF7,
                            ).withValues(alpha: 0.14),
                            blurRadius: 72,
                            spreadRadius: 5,
                          ),
                      ],
                    ),
                  ),
                ),
                Positioned.fill(
                  child: CustomPaint(
                    painter: _TexturedGlobePainter(
                      earthImage: assets?.earthImage,
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
                      selectedCountryCode: selectedCountryCode,
                      yaw: _yaw,
                      pitch: _pitch,
                      isLight: palette.isLight,
                    ),
                  ),
                ),
                ...projectedAnchors
                    .where((anchor) => anchor.opacity > 0.1)
                    .map(
                      (anchor) => _AnchorMarker(
                        projectedAnchor: anchor,
                        selected:
                            selectedCountryCode == anchor.anchor.countryCode,
                        onTap: () => widget.onCountrySelected?.call(
                          anchor.anchor.countryCode,
                        ),
                      ),
                    ),
              ],
            ),
          );
        },
      ),
    );
  }

  _OrbitTarget? _orbitTargetForCountry(String? countryCode) {
    if (countryCode == null) return null;
    final anchor = widget.scene.anchorForCountry(countryCode);
    if (anchor == null) return null;
    final longitude = anchor.longitude * math.pi / 180;
    final latitude = anchor.latitude * math.pi / 180;
    return _OrbitTarget(
      yaw: _wrapAngle(longitude),
      pitch: (-latitude).clamp(-0.62, 0.62),
    );
  }

  void _animateToCountry(String? countryCode) {
    final target = _orbitTargetForCountry(countryCode);
    if (target == null) return;
    _focusStartYaw = _yaw;
    _focusStartPitch = _pitch;
    _focusEndYaw = _shortestAngleDelta(_yaw, target.yaw);
    _focusEndPitch = target.pitch;
    _focusCtrl
      ..reset()
      ..forward();
  }

  static Future<_GlobeAssets?> _loadGlobeAssets() async {
    try {
      final earthImage = await _loadAssetImage(
        'assets/globe/earth_day_albedo_v1_4096.webp',
      );
      return _GlobeAssets(earthImage: earthImage);
    } catch (_) {
      return null;
    }
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
}

class _GlobeAssets {
  const _GlobeAssets({required this.earthImage});

  final ui.Image earthImage;
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

class _AnchorMarker extends StatelessWidget {
  const _AnchorMarker({
    required this.projectedAnchor,
    required this.selected,
    required this.onTap,
  });

  final _ProjectedAnchor projectedAnchor;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.atlasPalette;
    final anchor = projectedAnchor.anchor;
    final markerSize = selected ? 26.0 : 16.0;
    final label = selected ? anchor.countryName : null;
    final markerWidth = selected ? 112.0 : 64.0;

    return Positioned(
      left: projectedAnchor.position.dx - (markerWidth / 2),
      top: projectedAnchor.position.dy - (selected ? 54 : 20),
      child: IgnorePointer(
        ignoring: projectedAnchor.opacity < 0.1,
        child: Opacity(
          opacity: projectedAnchor.opacity,
          child: Transform.scale(
            scale: projectedAnchor.scale,
            child: GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.translucent,
              child: SizedBox(
                width: markerWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (label != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: palette.surfaceGlass.withValues(
                            alpha: palette.isLight ? 0.96 : 0.84,
                          ),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: anchor.color.withValues(alpha: 0.45),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: anchor.color.withValues(alpha: 0.18),
                              blurRadius: 16,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    Container(
                      width: markerSize,
                      height: markerSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: anchor.color,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.72),
                          width: selected ? 2.2 : 1.4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: anchor.color.withValues(
                              alpha: selected ? 0.42 : 0.24,
                            ),
                            blurRadius: selected ? 18 : 10,
                            spreadRadius: selected ? 3 : 1,
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Container(
                        width: selected ? 6 : 4,
                        height: selected ? 6 : 4,
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
        ),
      ),
    );
  }
}

class _TexturedGlobePainter extends CustomPainter {
  const _TexturedGlobePainter({
    required this.earthImage,
    required this.yaw,
    required this.pitch,
    required this.style,
  });

  final ui.Image? earthImage;
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
    final spherePath = Path()..addOval(rect);
    final isLight = style == RecordGlobeStyle.storybookLight;

    final sphereBase = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.16, -0.28),
        radius: 0.98,
        colors: isLight
            ? const [
                Color(0xFFE8F4FF),
                Color(0xFFD4E8FF),
                Color(0xFFA6CCF2),
                Color(0xFF6F98C6),
              ]
            : const [
                Color(0xFF2E4C75),
                Color(0xFF0E223B),
                Color(0xFF08111F),
                Color(0xFF03070F),
              ],
        stops: const [0, 0.38, 0.78, 1],
      ).createShader(rect);
    canvas.drawCircle(center, radius, sphereBase);

    canvas.save();
    canvas.clipPath(spherePath);

    final earth = earthImage;
    if (earth != null) {
      final mesh = _SphereMesh.build(
        size: size,
        textureWidth: earth.width.toDouble(),
        textureHeight: earth.height.toDouble(),
        yaw: yaw,
        pitch: pitch,
      );

      final earthPaint = Paint()
        ..isAntiAlias = true
        ..filterQuality = FilterQuality.high
        ..shader = ui.ImageShader(
          earth,
          ui.TileMode.repeated,
          ui.TileMode.clamp,
          _identityMatrix,
        );
      if (!isLight) {
        earthPaint.colorFilter = const ColorFilter.mode(
          Color(0xFFB7D4FF),
          BlendMode.modulate,
        );
      }
      canvas.drawVertices(mesh, ui.BlendMode.srcOver, earthPaint);
    }

    final glaze = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.18, -0.20),
        radius: 1.0,
        colors: isLight
            ? [
                const Color(0x44FFFFFF),
                const Color(0x1FE2F0FF),
                const Color(0x14D3E9C6),
                const Color(0x00FFFFFF),
              ]
            : [
                const Color(0x1800D1FF),
                const Color(0x10004C8F),
                const Color(0x128A5CF7),
                const Color(0x00000000),
              ],
      ).createShader(rect);
    canvas.drawRect(rect, glaze);

    final lighting = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.white.withValues(alpha: isLight ? 0.14 : 0.08),
          Colors.transparent,
          isLight ? const Color(0x201A4F87) : const Color(0x88000915),
        ],
        stops: const [0, 0.38, 1],
      ).createShader(rect);
    canvas.drawRect(rect, lighting);

    final specular = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.34, -0.28),
        radius: 0.46,
        colors: [
          Colors.white.withValues(alpha: isLight ? 0.18 : 0.10),
          Colors.white.withValues(alpha: isLight ? 0.08 : 0.04),
          Colors.transparent,
        ],
      ).createShader(rect);
    canvas.drawCircle(center, radius, specular);

    canvas.restore();

    final rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..color = isLight ? const Color(0xAAD6EDFF) : const Color(0x66CFE8FF);
    canvas.drawCircle(center, radius - 1.1, rim);
  }

  @override
  bool shouldRepaint(covariant _TexturedGlobePainter oldDelegate) {
    return oldDelegate.earthImage != earthImage ||
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
    final center = rect.center;
    final radius = size.width / 2;
    final spherePath = Path()..addOval(rect);
    final projectedByCountry = {
      for (final projected in projectedAnchors)
        projected.anchor.countryCode: projected,
    };

    canvas.save();
    canvas.clipPath(spherePath);

    if (!isLight) {
      for (var index = 0; index < projectedAnchors.length; index++) {
        final projected = projectedAnchors[index];
        if (projected.depth <= 0.12) continue;
        final twinkle = 0.08 + ((index % 4) * 0.03);
        final glowPaint = Paint()
          ..color = projected.anchor.color.withValues(
            alpha: twinkle + projected.depth * 0.16,
          );
        canvas.drawCircle(
          projected.position,
          4.5 + projected.depth * 3.5,
          glowPaint,
        );
      }
    }

    for (final arc in scene.arcs) {
      final from = _projectLatLng(
        arc.fromLatitude,
        arc.fromLongitude,
        size,
        yaw: yaw,
        pitch: pitch,
      );
      final to = _projectLatLng(
        arc.toLatitude,
        arc.toLongitude,
        size,
        yaw: yaw,
        pitch: pitch,
      );

      final visibility = ((from.depth + to.depth) / 2).clamp(-1.0, 1.0);
      final opacity = visibility <= -0.2
          ? 0.0
          : visibility <= 0
          ? 0.05
          : 0.12 + visibility * (isLight ? 0.14 : 0.26);
      if (opacity <= 0) continue;

      final midpoint = Offset.lerp(from.position, to.position, 0.5)!;
      final direction = midpoint - center;
      final normalized = direction.distance < 1
          ? const Offset(0, -1)
          : direction / direction.distance;
      final arcHeight =
          (from.position - to.position).distance * (isLight ? 0.16 : 0.22) +
          radius * 0.06;
      final control = midpoint + normalized * arcHeight;

      final path = Path()
        ..moveTo(from.position.dx, from.position.dy)
        ..quadraticBezierTo(
          control.dx,
          control.dy,
          to.position.dx,
          to.position.dy,
        );

      final isSelected =
          selectedCountryCode != null &&
          (arc.fromCountryCode == selectedCountryCode ||
              arc.toCountryCode == selectedCountryCode);

      if (!isLight) {
        final glow = Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = isSelected ? 4.8 : 3.2
          ..color = arc.color.withValues(alpha: opacity * 0.42);
        canvas.drawPath(path, glow);
      }

      final stroke = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = isSelected ? 2.6 : 1.6
        ..shader = LinearGradient(
          colors: [
            arc.color.withValues(alpha: opacity * (isSelected ? 1.0 : 0.72)),
            Colors.white.withValues(alpha: opacity * 0.55),
          ],
        ).createShader(rect);
      canvas.drawPath(path, stroke);
    }

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
  }) {
    const rows = 48;
    const columns = 48;
    final radius = size.width / 2;
    final center = size.center(Offset.zero);
    final positions = <Offset>[];
    final textureCoordinates = <Offset>[];
    final indices = <int>[];
    final grid = List.generate(
      rows + 1,
      (_) => List<int?>.filled(columns + 1, null),
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

        final index = positions.length;
        grid[row][column] = index;
        positions.add(Offset(center.dx + nx * radius, center.dy + ny * radius));
        textureCoordinates.add(Offset(sourceX, sourceY));
      }
    }

    for (var row = 0; row < rows; row++) {
      for (var column = 0; column < columns; column++) {
        final topLeft = grid[row][column];
        final topRight = grid[row][column + 1];
        final bottomLeft = grid[row + 1][column];
        final bottomRight = grid[row + 1][column + 1];

        if (topLeft != null && topRight != null && bottomLeft != null) {
          indices.addAll([topLeft, topRight, bottomLeft]);
        }
        if (topRight != null && bottomRight != null && bottomLeft != null) {
          indices.addAll([topRight, bottomRight, bottomLeft]);
        }
      }
    }

    return ui.Vertices(
      ui.VertexMode.triangles,
      positions,
      textureCoordinates: textureCoordinates,
      indices: indices,
    );
  }
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
