import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../../domain/record_travel_graph.dart';
import '../../i18n/record_strings.dart';
import 'record_country_detail_shared.dart';

class RecordCountryHero extends StatelessWidget {
  const RecordCountryHero({
    super.key,
    required this.projection,
    required this.accentColor,
  });

  final RecordCountryProjection projection;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = RecordStrings.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withValues(alpha: 0.96),
            accentColor.withValues(alpha: 0.48),
            theme.scaffoldBackgroundColor,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxHeight < 228;
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                isCompact ? 28 : 56,
              ),
              child: Stack(
                children: [
                  RecordCountryRoundHeroButton(
                    key: const Key('record-country-detail-back'),
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  Positioned.fill(
                    top: isCompact ? 52 : 66,
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              AtlasStatusPill(
                                label: projection.continent,
                                color: Colors.white,
                                icon: Icons.public_rounded,
                              ),
                              AtlasStatusPill(
                                label: _signalLabel(strings, projection.signal),
                                color: Colors.white.withValues(alpha: 0.24),
                                icon: projection.hasUpcomingTrip
                                    ? Icons.flight_takeoff_rounded
                                    : Icons.auto_graph_rounded,
                              ),
                            ],
                          ),
                          SizedBox(height: isCompact ? 12 : 18),
                          Text(
                            projection.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: (isCompact
                                    ? theme.textTheme.headlineSmall
                                    : theme.textTheme.headlineMedium)
                                ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          if (!isCompact) ...[
                            const SizedBox(height: 8),
                            Text(
                              strings.isKorean
                                  ? '하나의 여행 그래프를 지도, 타임라인, 앨범 세 가지 투영으로 정리했습니다.'
                                  : 'One travel graph, rendered as map, timeline, and album projections.',
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                RecordCountryHeroMetric(
                                  label: strings.profileTrips(
                                    projection.tripCount,
                                  ),
                                  value: '${projection.tripCount}',
                                ),
                                RecordCountryHeroMetric(
                                  label: strings.timelineEntries(
                                    projection.visitCount,
                                  ),
                                  value: '${projection.visitCount}',
                                ),
                                RecordCountryHeroMetric(
                                  label: strings.isKorean ? '도시' : 'Cities',
                                  value: '${projection.cityCount}',
                                ),
                              ],
                            ),
                          ] else ...[
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _RecordCountryHeroStatPill(
                                  label: strings.profileTrips(
                                    projection.tripCount,
                                  ),
                                  value: '${projection.tripCount}',
                                ),
                                _RecordCountryHeroStatPill(
                                  label: strings.timelineEntries(
                                    projection.visitCount,
                                  ),
                                  value: '${projection.visitCount}',
                                ),
                                _RecordCountryHeroStatPill(
                                  label: strings.isKorean ? '도시' : 'Cities',
                                  value: '${projection.cityCount}',
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class RecordCountryOverviewStrip extends StatelessWidget {
  const RecordCountryOverviewStrip({
    super.key,
    required this.projection,
    required this.accentColor,
  });

  final RecordCountryProjection projection;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final strings = RecordStrings.of(context);

    return AtlasPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.isKorean ? '국가 레벨 요약' : 'Country summary',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            strings.isKorean
                ? '방문 강도, 예정 여행, 최근 활동 신호를 같은 모델에서 계산합니다.'
                : 'Visit intensity, planned travel, and recency are derived from the same graph.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              RecordCountryOverviewMetricCard(
                label: strings.isKorean ? '활동 점수' : 'Activity',
                value: projection.activityScore.toStringAsFixed(1),
                icon: Icons.auto_graph_rounded,
                accentColor: accentColor,
              ),
              RecordCountryOverviewMetricCard(
                label: strings.isKorean ? '기록 일수' : 'Days',
                value: '${projection.totalDays}',
                icon: Icons.calendar_month_rounded,
                accentColor: accentColor,
              ),
              RecordCountryOverviewMetricCard(
                label: strings.isKorean ? '사진' : 'Photos',
                value: '${projection.photoCount}',
                icon: Icons.photo_library_rounded,
                accentColor: accentColor,
              ),
              RecordCountryOverviewMetricCard(
                label: strings.isKorean ? '예정 정차' : 'Planned stops',
                value: '${projection.plannedStopCount}',
                icon: Icons.flight_takeoff_rounded,
                accentColor: accentColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RecordCountryHeroMetric extends StatelessWidget {
  const RecordCountryHeroMetric({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.82),
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
          ),
        ],
      ),
    );
  }
}

class _RecordCountryHeroStatPill extends StatelessWidget {
  const _RecordCountryHeroStatPill({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.82),
              ),
          children: [
            TextSpan(
              text: '$value ',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            TextSpan(text: label),
          ],
        ),
      ),
    );
  }
}

class RecordCountryRoundHeroButton extends StatelessWidget {
  const RecordCountryRoundHeroButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Ink(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.16),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}

String _signalLabel(RecordStrings strings, RecordCountrySignal signal) {
  return switch (signal) {
    RecordCountrySignal.neutral => strings.isKorean ? '준비 중' : 'Warm',
    RecordCountrySignal.planned => strings.isKorean ? '예정 여행' : 'Planned',
    RecordCountrySignal.visited => strings.isKorean ? '방문 기록' : 'Visited',
  };
}
