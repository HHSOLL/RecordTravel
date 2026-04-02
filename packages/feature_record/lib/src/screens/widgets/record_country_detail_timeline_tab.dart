import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../../domain/record_travel_graph.dart';
import '../../i18n/record_strings.dart';
import 'record_country_detail_shared.dart';

class RecordCountryTimelineTab extends StatelessWidget {
  const RecordCountryTimelineTab({
    super.key,
    required this.projection,
    required this.accentColor,
  });

  final RecordCountryProjection projection;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final strings = RecordStrings.of(context);

    if (projection.timelineDays.isEmpty) {
      return Center(child: Text(strings.text('trip.noEntries')));
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        RecordCountrySectionHeader(
          title: strings.isKorean ? '날짜 / 세그먼트 / 순간' : 'Day / Segment / Moment',
          subtitle: strings.isKorean
              ? '날짜별로 여행 흐름을 묶고, 순간 단위의 기록과 사진을 아래로 이어 보여줍니다.'
              : 'Grouped by day, then rendered as moments with notes, locations, and photos.',
        ),
        const SizedBox(height: 14),
        for (final day in projection.timelineDays) ...[
          RecordTimelineDaySection(day: day, accentColor: accentColor),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class RecordTimelineDaySection extends StatelessWidget {
  const RecordTimelineDaySection({
    super.key,
    required this.day,
    required this.accentColor,
  });

  final RecordTimelineDay day;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final strings = RecordStrings.of(context);
    final formatter = strings.dateFormat('EEE, MMM d');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          formatter.format(day.date),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 10),
        for (var index = 0; index < day.moments.length; index++) ...[
          RecordTimelineMomentCard(
            moment: day.moments[index],
            accentColor: accentColor,
            isLast: index == day.moments.length - 1,
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class RecordTimelineMomentCard extends StatelessWidget {
  const RecordTimelineMomentCard({
    super.key,
    required this.moment,
    required this.accentColor,
    required this.isLast,
  });

  final RecordTimelineMoment moment;
  final Color accentColor;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final strings = RecordStrings.of(context);
    final dateTimeFormat = strings.dateFormat('MMM d, yyyy • HH:mm');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: accentColor,
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 96,
                color: accentColor.withValues(alpha: 0.26),
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: AtlasPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        moment.title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                    ),
                    if (moment.isPlanned)
                      AtlasStatusPill(
                        label: moment.isSynthetic
                            ? (strings.isKorean ? '예정 세그먼트' : 'Planned segment')
                            : (strings.isKorean ? '예정' : 'Planned'),
                        color: accentColor,
                        icon: Icons.schedule_rounded,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${strings.tripTitle(moment.tripId, moment.tripTitle)} • ${moment.locationName}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  dateTimeFormat.format(moment.happenedAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (moment.summary.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    moment.summary,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                if (moment.photoLabels.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final label in moment.photoLabels)
                        RecordCountryPhotoTag(
                          label: label,
                          accentColor: accentColor,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class RecordCountryPhotoTag extends StatelessWidget {
  const RecordCountryPhotoTag({
    super.key,
    required this.label,
    required this.accentColor,
  });

  final String label;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelLarge),
    );
  }
}
