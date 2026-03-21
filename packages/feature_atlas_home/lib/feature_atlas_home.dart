import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:core_data/core_data.dart';
import 'package:core_domain/core_domain.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

class AtlasHomeScreen extends ConsumerStatefulWidget {
  const AtlasHomeScreen({
    super.key,
    required this.onOpenTrip,
    required this.onOpenCountry,
    required this.onOpenCity,
    required this.onOpenJournal,
    required this.onImportPhotos,
    required this.onOpenTimeline,
    required this.onOpenSearch,
    required this.onOpenProfile,
  });

  final ValueChanged<String> onOpenTrip;
  final ValueChanged<String> onOpenCountry;
  final ValueChanged<String> onOpenCity;
  final VoidCallback onOpenJournal;
  final Future<void> Function() onImportPhotos;
  final VoidCallback onOpenTimeline;
  final VoidCallback onOpenSearch;
  final VoidCallback onOpenProfile;

  @override
  ConsumerState<AtlasHomeScreen> createState() => _AtlasHomeScreenState();
}

class _AtlasHomeScreenState extends ConsumerState<AtlasHomeScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _enterAnim;

  @override
  void initState() {
    super.initState();
    _enterAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..forward();
  }

  @override
  void dispose() {
    _enterAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(atlasHomeSnapshotProvider);
    final session = ref.watch(sessionSnapshotProvider);

    return AtlasBackground(
      child: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: _enterAnim,
          builder: (context, child) {
            final curve = const Cubic(0.2, 0.8, 0.2, 1);
            final val = curve.transform(_enterAnim.value);
            return Transform.translate(
              offset: Offset(0, 30 * (1 - val)),
              child: Opacity(
                opacity: _enterAnim.value.clamp(0.0, 1.0),
                child: child,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
            child: Column(
              children: [
                _HomeTopBar(
                  title: '${_displayName(session.user.displayName)}의 지구본',
                  onOpenMenu: widget.onOpenSearch,
                  onOpenProfile: widget.onOpenProfile,
                ),
                const SizedBox(height: 18),
                AtlasStatusPill(
                  label: _travelerBadge(snapshot),
                  color: const Color(0xFF63DDFF),
                  icon: Icons.auto_awesome_rounded,
                ),
                const SizedBox(height: 18),
                Text(
                  '${snapshot.visitedCities}개 도시, ${snapshot.visitedCountries}개국 여행자',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    foreground: Paint()
                      ..shader = ui.Gradient.linear(
                        const Offset(0, 0),
                        const Offset(0, 30),
                        [Colors.white, const Color(0xFFBBE5FF)],
                      ),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: _AtlasGlobeStage(
                    snapshot: snapshot,
                    onOpenTrip: widget.onOpenTrip,
                    onOpenCountry: widget.onOpenCountry,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Text(
                    '다녀온 도시가 많아질수록 지구본이 더 선명해져요.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF9CAFC8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                _AtlasHomeActionBar(
                  onImportPhotos: widget.onImportPhotos,
                  onOpenTimeline: widget.onOpenTimeline,
                  onOpenJournal: widget.onOpenJournal,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeTopBar extends StatelessWidget {
  const _HomeTopBar({
    required this.title,
    required this.onOpenMenu,
    required this.onOpenProfile,
  });

  final String title;
  final VoidCallback onOpenMenu;
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(
      context,
    ).textTheme.titleLarge?.copyWith(fontSize: 18, fontWeight: FontWeight.w800);

    return Row(
      children: [
        _TopCircleButton(icon: Icons.menu_rounded, onTap: onOpenMenu),
        Expanded(
          child: Text(title, style: style, textAlign: TextAlign.center),
        ),
        _TopCircleButton(icon: Icons.person_2_outlined, onTap: onOpenProfile),
      ],
    );
  }
}

class _TopCircleButton extends StatelessWidget {
  const _TopCircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFF0C1628).withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFF1C3555)),
        ),
        child: Icon(icon, color: Colors.white, size: 26),
      ),
    );
  }
}

class _AtlasGlobeStage extends StatelessWidget {
  const _AtlasGlobeStage({
    required this.snapshot,
    required this.onOpenTrip,
    required this.onOpenCountry,
  });

  final AtlasHomeSnapshot snapshot;
  final ValueChanged<String> onOpenTrip;
  final ValueChanged<String> onOpenCountry;

  @override
  Widget build(BuildContext context) {
    final countries = snapshot.highlightCountries;
    final leftCountry = countries.isNotEmpty ? countries.first : null;
    final rightCountry = countries.length > 1 ? countries[1] : null;
    final remainingCount = math.max(0, countries.length - 2);
    final latestTripId = snapshot.recentTrips.isNotEmpty
        ? snapshot.recentTrips.first.id
        : null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final globeSize = math.min(constraints.maxWidth * 1.2, 620.0);
        final globeTop = math.max(48.0, constraints.maxHeight * 0.17);
        final globeLeft = (constraints.maxWidth - globeSize) / 2;
        
        // Calculate positions dynamically
        double leftX = 6;
        double leftY = globeTop + globeSize * 0.22;
        if (leftCountry != null) {
          final offset = _countryGlobeCoordinates[leftCountry.countryCode.toUpperCase()];
          if (offset != null) {
            leftX = globeLeft + (globeSize / 2) + (offset.dx * globeSize) - 80; // approximate width
            // clamp
            leftX = math.max(6.0, math.min(leftX, constraints.maxWidth - 160));
            leftY = globeTop + (globeSize / 2) - (offset.dy * globeSize) - 30; // approximate height
          }
        }

        double rightX = constraints.maxWidth - 180;
        double rightY = globeTop + globeSize * 0.36;
        if (rightCountry != null) {
           final offset = _countryGlobeCoordinates[rightCountry.countryCode.toUpperCase()];
           if (offset != null) {
              double tempX = globeLeft + (globeSize / 2) + (offset.dx * globeSize);
              rightX = math.min(constraints.maxWidth - 10, math.max(10.0, tempX));
              rightY = globeTop + (globeSize / 2) - (offset.dy * globeSize) - 30;
              // Ensure no overlap
              if ((leftY - rightY).abs() < 60 && (leftX - rightX).abs() < 160) {
                 rightY += 80; 
              }
           } else {
             rightX = constraints.maxWidth - 180;
             rightX = math.max(0.0, rightX);
           }
        }

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: globeLeft,
              top: globeTop,
              child: _AtlasPassportGlobe(size: globeSize, initialCountry: leftCountry?.countryCode),
            ),
            if (leftCountry != null)
              Positioned(
                left: leftX,
                top: leftY,
                child: _CountryHighlightChip(
                  summary: leftCountry,
                  alignRightAddon: true,
                  onTap: () => onOpenCountry(leftCountry.countryCode),
                  onAddonTap: latestTripId == null
                      ? null
                      : () => onOpenTrip(latestTripId),
                ),
              ),
            if (rightCountry != null)
              Positioned(
                left: rightX,
                top: rightY,
                child: _CountryHighlightChip(
                  summary: rightCountry,
                  onTap: () => onOpenCountry(rightCountry.countryCode),
                  onAddonTap: latestTripId == null
                      ? null
                      : () => onOpenTrip(latestTripId),
                ),
              ),
            Positioned(
              left: constraints.maxWidth * 0.56,
              top: globeTop + globeSize * 0.67,
              child: _ContinentSummaryChip(
                label: remainingCount > 0
                    ? '기록 +$remainingCount'
                    : snapshot.totalTrips > 0
                    ? '여행 ${snapshot.totalTrips}개'
                    : '첫 여정',
                onTap: latestTripId == null
                    ? null
                    : () => onOpenTrip(latestTripId),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AtlasPassportGlobe extends StatefulWidget {
  const _AtlasPassportGlobe({required this.size, this.initialCountry});

  final double size;
  final String? initialCountry;

  @override
  State<_AtlasPassportGlobe> createState() => _AtlasPassportGlobeState();
}


const Map<String, Offset> _countryGlobeCoordinates = {
  'KR': Offset(-0.35, 0.2), // South Korea
  'JP': Offset(-0.4, 0.2),  // Japan
  'US': Offset(0.3, 0.2),   // USA
  'FR': Offset(0.0, 0.3),   // France
  'IT': Offset(0.05, 0.25), // Italy
  'ES': Offset(-0.05, 0.2), // Spain
  'UK': Offset(-0.02, 0.35),// UK
  'AU': Offset(-0.4, -0.2), // Australia
  'BR': Offset(0.2, -0.1),  // Brazil
  'CA': Offset(0.25, 0.3),  // Canada
};

double _getCountryYaw(String code) {
  // Rough mapping to yaw/pitch. In reality this requires spherical projection mapping.
  // For the sake of UI we use predefined offsets.
  switch(code) {
    case 'KR': return 1.9;
    case 'JP': return 1.95;
    case 'US': return -1.5;
    case 'FR': return -0.1;
    case 'IT': return -0.2;
    case 'ES': return 0.0;
    case 'GB': return -0.1;
    case 'AU': return 2.2;
    default: return 1.5;
  }
}
double _getCountryPitch(String code) {
  switch(code) {
    case 'KR': return 0.3;
    case 'JP': return 0.3;
    case 'US': return 0.1;
    case 'FR': return 0.4;
    case 'IT': return 0.35;
    case 'ES': return 0.3;
    case 'GB': return 0.45;
    case 'AU': return -0.4;
    default: return 0.15;
  }
}

class _AtlasPassportGlobeState extends State<_AtlasPassportGlobe> with SingleTickerProviderStateMixin {
  static Future<_GlobeAssets?>? _assetsFuture;

  late final AnimationController _spinCtrl;
  double _yaw = 1.52;
  double _pitch = 0.18;
  bool _isDragging = false;

  Future<_GlobeAssets?> get _cachedAssetsFuture =>
      _assetsFuture ??= _loadGlobeAssets();

  @override
  void initState() {
    super.initState();
    if (widget.initialCountry != null) {
      _yaw = _getCountryYaw(widget.initialCountry!);
      _pitch = _getCountryPitch(widget.initialCountry!);
    }
    _spinCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 40))..repeat();
    _spinCtrl.addListener(() {
      if (!_isDragging && mounted) {
        setState(() {
          _yaw -= 0.003;
        });
      }
    });
  }

  @override
  void dispose() {
    _spinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;

    return SizedBox(
      width: size,
      height: size,
      child: FutureBuilder<_GlobeAssets?>(
        future: _cachedAssetsFuture,
        builder: (context, snapshot) {
          final assets = snapshot.data;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: (_) => _isDragging = true,
            onPanEnd: (_) => _isDragging = false,
            onPanCancel: () => _isDragging = false,
            onPanUpdate: (details) {
              setState(() {
                _yaw -= details.delta.dx * 0.0082;
                _pitch = (_pitch + details.delta.dy * 0.0048).clamp(-0.6, 0.6);
              });
            },
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF1BA8FF,
                          ).withValues(alpha: 0.24),
                          blurRadius: 80,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned.fill(
                  child: CustomPaint(
                    painter: _TexturedGlobePainter(
                      earthImage: assets?.earthImage,
                      bordersImage: assets?.bordersImage,
                      yaw: _yaw,
                      pitch: _pitch,
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

  static Future<_GlobeAssets?> _loadGlobeAssets() async {
    try {
      final earthImage = await _loadAssetImage(_earthTextureAsset);
      final bordersImage = await _loadAssetImage(_earthBordersAsset);
      return _GlobeAssets(earthImage: earthImage, bordersImage: bordersImage);
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
  const _GlobeAssets({required this.earthImage, required this.bordersImage});

  final ui.Image earthImage;
  final ui.Image bordersImage;
}

class _TexturedGlobePainter extends CustomPainter {
  const _TexturedGlobePainter({
    required this.earthImage,
    required this.bordersImage,
    required this.yaw,
    required this.pitch,
  });

  final ui.Image? earthImage;
  final ui.Image? bordersImage;
  final double yaw;
  final double pitch;

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

    final globePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.18, -0.30),
        radius: 0.98,
        colors: const [
          Color(0xFF4B78AA),
          Color(0xFF183C63),
          Color(0xFF071D36),
          Color(0xFF020D1E),
        ],
        stops: [0.0, 0.40, 0.78, 1.0],
      ).createShader(rect);
    canvas.drawCircle(center, radius, globePaint);

    canvas.save();
    canvas.clipPath(spherePath);

    final earth = earthImage;
    final borders = bordersImage;
    if (earth != null && borders != null) {
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
      canvas.drawVertices(mesh, ui.BlendMode.src, earthPaint);

      final bordersPaint = Paint()
        ..isAntiAlias = true
        ..filterQuality = FilterQuality.medium
        ..color = const Color(0xE9F1FAFF)
        ..shader = ui.ImageShader(
          borders,
          ui.TileMode.repeated,
          ui.TileMode.clamp,
          _identityMatrix,
        );
      canvas.drawVertices(mesh, ui.BlendMode.srcOver, bordersPaint);
    }

    final lighting = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.white.withValues(alpha: 0.12),
          Colors.transparent,
          const Color(0xD0000915),
        ],
        stops: const [0.0, 0.38, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, lighting);

    final specular = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.36, -0.28),
        radius: 0.44,
        colors: [
          Colors.white.withValues(alpha: 0.18),
          Colors.white.withValues(alpha: 0.06),
          Colors.transparent,
        ],
      ).createShader(rect);
    canvas.drawCircle(center, radius, specular);

    canvas.restore();

    final rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..color = const Color(0x88CFE8FF);
    canvas.drawCircle(center, radius - 1.1, rim);
  }

  @override
  bool shouldRepaint(covariant _TexturedGlobePainter oldDelegate) {
    return oldDelegate.earthImage != earthImage ||
        oldDelegate.bordersImage != bordersImage ||
        oldDelegate.yaw != yaw ||
        oldDelegate.pitch != pitch;
  }
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
  final pitched = _rotateX(point, -pitch);
  return _rotateY(pitched, -yaw);
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

class _CountryHighlightChip extends StatelessWidget {
  const _CountryHighlightChip({
    required this.summary,
    required this.onTap,
    this.onAddonTap,
    this.alignRightAddon = false,
  });

  final CountrySummary summary;
  final VoidCallback onTap;
  final VoidCallback? onAddonTap;
  final bool alignRightAddon;

  @override
  Widget build(BuildContext context) {
    final chip = ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: const Color(0xFF030D1D).withOpacity(0.6),
            border: Border.all(color: const Color(0xFF00F0FF).withOpacity(0.5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00F0FF).withOpacity(0.15),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _CountryFlag(countryCode: summary.countryCode),
              const SizedBox(width: 8),
              Text(
                summary.countryName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF00F0FF).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${summary.cityCount}',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: const Color(0xFF00F0FF),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final addon = InkWell(
      onTap: onAddonTap,
      borderRadius: BorderRadius.circular(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF030D1D).withOpacity(0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF00F0FF).withOpacity(0.4), width: 1.5),
            ),
            child: const Icon(Icons.add_rounded, color: Color(0xFF00F0FF)),
          ),
        ),
      ),
    );

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutCubic,
      builder: (context, val, child) {
        return Transform.scale(
          scale: 0.9 + 0.1 * val,
          child: Opacity(opacity: val, child: child),
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: alignRightAddon
            ? [
                InkWell(onTap: onTap, borderRadius: BorderRadius.circular(24), child: chip),
                const SizedBox(width: 8),
                addon,
              ]
            : [
                InkWell(onTap: onTap, borderRadius: BorderRadius.circular(24), child: chip),
                const SizedBox(width: 8),
                addon,
              ],
      ),
    );
  }
}

class _CountryFlag extends StatelessWidget {
  const _CountryFlag({required this.countryCode});

  final String countryCode;

  @override
  Widget build(BuildContext context) {
    final flag = _flagEmoji(countryCode);
    if (flag == null) {
      return Container(
        width: 26,
        height: 18,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF18324C),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0x338CCEFF)),
        ),
        child: Text(
          countryCode.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontSize: 9,
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }

    return SizedBox(
      width: 26,
      child: Text(
        flag,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
          height: 1,
          fontFamily: _emojiFontFamily(),
          fontFamilyFallback: const [
            'Apple Color Emoji',
            'Noto Color Emoji',
            'Segoe UI Emoji',
          ],
        ),
      ),
    );
  }
}

class _ContinentSummaryChip extends StatelessWidget {
  const _ContinentSummaryChip({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (context, val, child) {
        return Transform.scale(
          scale: 0.9 + 0.1 * val,
          child: Opacity(opacity: val, child: child),
        );
      },
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF030D1D).withOpacity(0.6),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: const Color(0xFF00F0FF).withOpacity(0.4)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00F0FF).withOpacity(0.15),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AtlasHomeActionBar extends StatelessWidget {
  const _AtlasHomeActionBar({
    required this.onImportPhotos,
    required this.onOpenTimeline,
    required this.onOpenJournal,
  });

  final Future<void> Function() onImportPhotos;
  final VoidCallback onOpenTimeline;
  final VoidCallback onOpenJournal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _BottomCircleAction(
            icon: Icons.ios_share_rounded,
            onTap: () => onImportPhotos(),
          ),
          const SizedBox(width: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Container(
                height: 74,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF030D1D).withOpacity(0.6),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFF00F0FF).withOpacity(0.4), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00F0FF).withOpacity(0.2),
                      blurRadius: 15,
                      spreadRadius: 1,
                    )
                  ],
                ),
                child: Row(
                  children: [
                    _BottomCapsuleIcon(
                      icon: Icons.format_list_bulleted_rounded,
                      onTap: onOpenTimeline,
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF00F0FF),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00F0FF).withOpacity(0.5),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: const Icon(
                        Icons.public_rounded,
                        color: Color(0xFF030D1D),
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 18),
          _BottomCircleAction(
            icon: Icons.add_rounded,
            backgroundColor: const Color(0xFF00F0FF),
            foregroundColor: const Color(0xFF030D1D),
            onTap: onOpenJournal,
          ),
        ],
      ),
    );
  }
}

class _BottomCircleAction extends StatelessWidget {
  const _BottomCircleAction({
    required this.icon,
    required this.onTap,
    this.backgroundColor = const Color(0xCC181A2A),
    this.foregroundColor = Colors.white,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    final isDefault = backgroundColor == const Color(0xCC181A2A);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(36),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDefault ? const Color(0xFF030D1D).withOpacity(0.6) : backgroundColor,
              border: Border.all(
                color: isDefault ? const Color(0xFF00F0FF).withOpacity(0.4) : backgroundColor,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDefault ? const Color(0xFF00F0FF).withOpacity(0.15) : backgroundColor.withOpacity(0.4),
                  blurRadius: 18,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(icon, color: foregroundColor, size: 34),
          ),
        ),
      ),
    );
  }
}

class _BottomCapsuleIcon extends StatelessWidget {
  const _BottomCapsuleIcon({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF00F0FF).withOpacity(0.15),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Icon(icon, color: const Color(0xFF00F0FF), size: 30),
      ),
    );
  }
}

String _displayName(String name) => name.trim().isEmpty ? '나' : name.trim();

String _travelerBadge(AtlasHomeSnapshot snapshot) {
  if (snapshot.visitedCountries >= 8) return '지도를 수집하는 기록가';
  if (snapshot.visitedCountries >= 5) return '호기심 많은 세계 기록가';
  if (snapshot.totalTrips >= 3) return '기억을 모으는 여행가';
  return '첫 여정을 모으는 중';
}

String? _flagEmoji(String countryCode) {
  final code = countryCode.toUpperCase();
  if (code.length != 2) return null;
  final chars = code.codeUnits
      .map((unit) => String.fromCharCode(unit + 127397))
      .join();
  return chars;
}

String? _emojiFontFamily() {
  switch (defaultTargetPlatform) {
    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
      return 'Apple Color Emoji';
    case TargetPlatform.android:
      return 'Noto Color Emoji';
    default:
      return null;
  }
}

const String _earthTextureAsset = 'assets/globe/earth_day_albedo_v1_4096.webp';
const String _earthBordersAsset =
    'assets/globe/earth_borders_overlay_v1_4096.png';
