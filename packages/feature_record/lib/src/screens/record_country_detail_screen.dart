import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../i18n/record_strings.dart';
import '../models/record_models.dart';
import '../providers/record_provider.dart';

class RecordCountryDetailScreen extends ConsumerWidget {
  const RecordCountryDetailScreen({super.key, required this.countryCode});

  final String countryCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final palette = context.atlasPalette;
    final strings = RecordStrings.of(context);
    final spotlight = ref.watch(recordCountrySpotlightProvider(countryCode));

    if (spotlight == null) {
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
      int.parse(spotlight.color.replaceAll('#', '0xFF')),
    );
    final locations = spotlight.locations;
    final trips = [...spotlight.trips]..sort(
        (a, b) => DateTime.parse(b.startDate).compareTo(
          DateTime.parse(a.startDate),
        ),
      );
    final firstVisit =
        locations.isEmpty ? null : DateTime.tryParse(locations.first.date);
    final latestVisit =
        locations.isEmpty ? null : DateTime.tryParse(locations.last.date);
    final upcomingTrips =
        spotlight.trips.where((trip) => trip.isUpcoming).length;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: AtlasBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _RoundIconButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                    const Spacer(),
                    AtlasStatusPill(
                      label: spotlight.continent,
                      color: accentColor,
                      icon: Icons.public_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  spotlight.name,
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.4,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  strings.isKorean
                      ? '국가 지도를 별도로 그리지 않고, 이 나라에서 남긴 기록과 여행 흐름을 한 화면에 정리했습니다.'
                      : 'A compact detail view of your trips, entries, and cities in this country.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.74),
                  ),
                ),
                const SizedBox(height: 18),
                _CountryOverviewCard(
                  spotlight: spotlight,
                  accentColor: accentColor,
                  isLight: palette.isLight,
                  firstVisitLabel: _formatDate(context, firstVisit),
                  latestVisitLabel: _formatDate(context, latestVisit),
                ),
                const SizedBox(height: 18),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final tileWidth = (constraints.maxWidth - 12) / 2;
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          width: tileWidth,
                          child: _MetricCard(
                            label: strings.profileTrips(spotlight.tripCount),
                            value: '${spotlight.tripCount}',
                            icon: Icons.luggage_rounded,
                            accentColor: accentColor,
                          ),
                        ),
                        SizedBox(
                          width: tileWidth,
                          child: _MetricCard(
                            label: strings.timelineEntries(locations.length),
                            value: '${locations.length}',
                            icon: Icons.route_rounded,
                            accentColor: accentColor,
                          ),
                        ),
                        SizedBox(
                          width: tileWidth,
                          child: _MetricCard(
                            label: strings.isKorean ? '기록된 도시' : 'Cities',
                            value: '${locations.length}',
                            icon: Icons.location_city_rounded,
                            accentColor: accentColor,
                          ),
                        ),
                        SizedBox(
                          width: tileWidth,
                          child: _MetricCard(
                            label: strings.isKorean ? '예정된 여정' : 'Upcoming',
                            value: '$upcomingTrips',
                            icon: Icons.flight_takeoff_rounded,
                            accentColor: accentColor,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 22),
                _SectionTitle(
                  title: strings.isKorean ? 'Trips' : 'Trips',
                  subtitle: strings.isKorean
                      ? '이 나라와 연결된 여정을 최근 순서로 정리했습니다.'
                      : 'Recent journeys connected to this country.',
                ),
                const SizedBox(height: 12),
                for (final trip in trips.take(4)) ...[
                  _TripCard(
                    trip: trip,
                    accentColor: accentColor,
                    dateRangeLabel: _formatTripRange(context, trip),
                  ),
                  const SizedBox(height: 12),
                ],
                const SizedBox(height: 8),
                _SectionTitle(
                  title:
                      strings.isKorean ? 'Recorded Cities' : 'Recorded Cities',
                  subtitle: strings.isKorean
                      ? '남긴 도시 기록을 빠르게 훑어볼 수 있습니다.'
                      : 'A quick scan of the cities you recorded here.',
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final location in locations.take(12))
                      _LocationChip(
                        name: location.name,
                        subtitle: _formatDate(
                          context,
                          DateTime.tryParse(location.date),
                        ),
                        accentColor: accentColor,
                      ),
                    if (locations.length > 12)
                      _LocationChip(
                        name: strings.isKorean
                            ? '+${locations.length - 12}개 더'
                            : '+${locations.length - 12} more',
                        subtitle: strings.isKorean ? '기록 보유' : 'Saved entries',
                        accentColor: accentColor,
                        emphasized: true,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime? date) {
    if (date == null) {
      return RecordStrings.of(context).isKorean ? '기록 없음' : 'No activity';
    }
    return MaterialLocalizations.of(context).formatMediumDate(date);
  }

  String _formatTripRange(BuildContext context, RecordTrip trip) {
    final start = DateTime.tryParse(trip.startDate);
    final end = DateTime.tryParse(trip.endDate);
    final formatter = MaterialLocalizations.of(context);
    if (start == null || end == null) {
      return trip.description;
    }
    final startLabel = formatter.formatShortMonthDay(start);
    final endLabel = formatter.formatShortMonthDay(end);
    return '$startLabel - $endLabel';
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.atlasPalette;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Ink(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: palette.surfaceGlass.withValues(
            alpha: palette.isLight ? 0.9 : 0.7,
          ),
          shape: BoxShape.circle,
          border: Border.all(color: palette.outline.withValues(alpha: 0.5)),
        ),
        child: Icon(icon),
      ),
    );
  }
}

class _CountryOverviewCard extends StatelessWidget {
  const _CountryOverviewCard({
    required this.spotlight,
    required this.accentColor,
    required this.isLight,
    required this.firstVisitLabel,
    required this.latestVisitLabel,
  });

  final RecordCountrySpotlight spotlight;
  final Color accentColor;
  final bool isLight;
  final String firstVisitLabel;
  final String latestVisitLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isLight
              ? [
                  Color.lerp(Colors.white, accentColor, 0.10)!,
                  Color.lerp(const Color(0xFFE8F3FF), accentColor, 0.18)!,
                ]
              : [
                  Color.lerp(const Color(0xFF101C32), accentColor, 0.20)!,
                  Color.lerp(const Color(0xFF091526), accentColor, 0.34)!,
                ],
        ),
        border: Border.all(color: accentColor.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: isLight ? 0.16 : 0.24),
            blurRadius: 32,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            spotlight.code,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            '${spotlight.tripCount} trips · ${spotlight.locations.length} entries',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            RecordStrings.of(context).isKorean
                ? '첫 기록 $firstVisitLabel부터 최근 활동 $latestVisitLabel까지 이 나라의 여정을 추적합니다.'
                : 'Track activity in this country from $firstVisitLabel to $latestVisitLabel.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.78),
                  height: 1.45,
                ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
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
    return AtlasPanel(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 18, color: accentColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.68),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
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
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7),
              ),
        ),
      ],
    );
  }
}

class _TripCard extends StatelessWidget {
  const _TripCard({
    required this.trip,
    required this.accentColor,
    required this.dateRangeLabel,
  });

  final RecordTrip trip;
  final Color accentColor;
  final String dateRangeLabel;

  @override
  Widget build(BuildContext context) {
    return AtlasPanel(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 7),
            decoration: BoxDecoration(
              color: accentColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  dateRangeLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.68),
                      ),
                ),
                if (trip.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    trip.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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

class _LocationChip extends StatelessWidget {
  const _LocationChip({
    required this.name,
    required this.subtitle,
    required this.accentColor,
    this.emphasized = false,
  });

  final String name;
  final String subtitle;
  final Color accentColor;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final palette = context.atlasPalette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: emphasized
            ? accentColor.withValues(alpha: 0.12)
            : palette.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: emphasized
              ? accentColor.withValues(alpha: 0.28)
              : palette.outline.withValues(alpha: 0.32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
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
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.68),
                ),
          ),
        ],
      ),
    );
  }
}
