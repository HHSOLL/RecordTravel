import 'dart:math' as math;

import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/record_country_geometry.dart';
import '../i18n/record_strings.dart';
import '../models/record_models.dart';
import '../providers/record_provider.dart';

class RecordCountryMapScreen extends ConsumerWidget {
  const RecordCountryMapScreen({super.key, required this.countryCode});

  final String countryCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final palette = context.atlasPalette;
    final strings = RecordStrings.of(context);
    final spotlight = ref.watch(recordCountrySpotlightProvider(countryCode));

    return FutureBuilder<RecordCountryGeometryBundle>(
      future: RecordCountryGeometryBundle.load(),
      builder: (context, snapshot) {
        final bundle = snapshot.data;
        final geometry = bundle?.byCode[countryCode];
        if (geometry == null) {
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

        final accentColor = Color(
          int.parse((spotlight?.color ?? '#7C9BCF').replaceAll('#', '0xFF')),
        );

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: AtlasBackground(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: () => Navigator.of(context).maybePop(),
                          borderRadius: BorderRadius.circular(999),
                          child: Ink(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: palette.surfaceGlass.withValues(
                                alpha: palette.isLight ? 0.9 : 0.7,
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: palette.outline.withValues(alpha: 0.5),
                              ),
                            ),
                            child: const Icon(Icons.arrow_back_rounded),
                          ),
                        ),
                        const Spacer(),
                        AtlasStatusPill(
                          label: spotlight?.continent ?? geometry.code,
                          color: accentColor,
                          icon: Icons.public_rounded,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      geometry.name,
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      strings.isKorean
                          ? '선택한 나라의 2D 지도를 보고 기록된 도시를 바로 확인합니다.'
                          : 'A 2D map for the selected country with your recorded cities overlaid.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.74),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Expanded(
                      child: AtlasPanel(
                        padding: const EdgeInsets.all(18),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(24),
                                    child: CustomPaint(
                                      painter: _CountryMapPainter(
                                        geometry: geometry,
                                        locations: spotlight?.locations ?? const [],
                                        accentColor: accentColor,
                                        isLight: palette.isLight,
                                      ),
                                      child: const SizedBox.expand(),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    _MapMetricPill(
                                      icon: Icons.route_rounded,
                                      label: strings.timelineEntries(
                                        spotlight?.locations.length ?? 0,
                                      ),
                                      color: accentColor,
                                    ),
                                    _MapMetricPill(
                                      icon: Icons.luggage_rounded,
                                      label: strings.profileTrips(
                                        spotlight?.tripCount ?? 0,
                                      ),
                                      color: accentColor,
                                    ),
                                  ],
                                ),
                                if ((spotlight?.locations.isNotEmpty ?? false)) ...[
                                  const SizedBox(height: 16),
                                  Text(
                                    strings.isKorean ? '기록된 도시' : 'Recorded cities',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      for (final location in spotlight!.locations.take(8))
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 9,
                                          ),
                                          decoration: BoxDecoration(
                                            color: palette.surfaceMuted,
                                            borderRadius: BorderRadius.circular(14),
                                            border: Border.all(
                                              color: palette.outline.withValues(alpha: 0.38),
                                            ),
                                          ),
                                          child: Text(
                                            location.name,
                                            style: theme.textTheme.labelLarge?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MapMetricPill extends StatelessWidget {
  const _MapMetricPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final palette = context.atlasPalette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: palette.surfaceMuted,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: palette.outline.withValues(alpha: 0.36)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CountryMapPainter extends CustomPainter {
  const _CountryMapPainter({
    required this.geometry,
    required this.locations,
    required this.accentColor,
    required this.isLight,
  });

  final RecordCountryGeometry geometry;
  final List<RecordLocation> locations;
  final Color accentColor;
  final bool isLight;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isLight
              ? [
                  const Color(0xFFF7FBFF),
                  const Color(0xFFE8F3FF),
                  const Color(0xFFF5F0FF),
                ]
              : [
                  const Color(0xFF091526),
                  const Color(0xFF12233D),
                  const Color(0xFF170E2B),
                ],
        ).createShader(rect),
    );

    final padding = 28.0;
    final width = math.max(0.01, geometry.maxLng - geometry.minLng);
    final height = math.max(0.01, geometry.maxLat - geometry.minLat);
    final scale = math.min(
      (size.width - padding * 2) / width,
      (size.height - padding * 2) / height,
    );
    final dx =
        (size.width - (width * scale)) / 2 - (geometry.minLng * scale);
    final dy =
        (size.height - (height * scale)) / 2 + (geometry.maxLat * scale);

    final fill = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isLight
            ? [
                Color.lerp(Colors.white, accentColor, 0.14)!,
                Color.lerp(const Color(0xFFDCF1FF), accentColor, 0.20)!,
              ]
            : [
                Color.lerp(const Color(0xFF162848), accentColor, 0.22)!,
                Color.lerp(const Color(0xFF0D1830), accentColor, 0.34)!,
              ],
      ).createShader(rect);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = isLight
          ? accentColor.withValues(alpha: 0.55)
          : accentColor.withValues(alpha: 0.72);

    for (final polygon in geometry.polygons) {
      if (polygon.length < 3) {
        continue;
      }
      final path = Path()
        ..moveTo(
          dx + (polygon.first.longitude * scale),
          dy - (polygon.first.latitude * scale),
        );
      for (final point in polygon.skip(1)) {
        path.lineTo(
          dx + (point.longitude * scale),
          dy - (point.latitude * scale),
        );
      }
      path.close();
      canvas.drawPath(path, fill);
      canvas.drawPath(path, stroke);
    }

    if (locations.length > 1) {
      final route = Path()
        ..moveTo(
          dx + (locations.first.lng * scale),
          dy - (locations.first.lat * scale),
        );
      for (final location in locations.skip(1)) {
        route.lineTo(
          dx + (location.lng * scale),
          dy - (location.lat * scale),
        );
      }
      canvas.drawPath(
        route,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round
          ..color = accentColor.withValues(alpha: isLight ? 0.82 : 0.9),
      );
    }

    for (final location in locations) {
      final point = Offset(
        dx + (location.lng * scale),
        dy - (location.lat * scale),
      );
      canvas.drawCircle(
        point,
        9,
        Paint()..color = accentColor.withValues(alpha: 0.22),
      );
      canvas.drawCircle(
        point,
        4.8,
        Paint()
          ..color = accentColor
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        point,
        4.8,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.78)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CountryMapPainter oldDelegate) {
    return oldDelegate.geometry != geometry ||
        oldDelegate.locations != locations ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.isLight != isLight;
  }
}
