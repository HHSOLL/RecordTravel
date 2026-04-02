import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../../domain/record_travel_graph.dart';
import '../../i18n/record_strings.dart';

class RecordCountryAlbumTab extends StatelessWidget {
  const RecordCountryAlbumTab({
    super.key,
    required this.projection,
    required this.accentColor,
  });

  final RecordCountryProjection projection;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final strings = RecordStrings.of(context);

    if (projection.albumMoments.isEmpty) {
      return Center(
        child: Text(
          strings.isKorean
              ? '아직 연결된 사진이 없습니다.'
              : 'No photo-backed moments yet.',
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      itemBuilder: (context, index) {
        final moment = projection.albumMoments[index];
        return RecordAlbumMomentCard(
          moment: moment,
          accentColor: accentColor,
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemCount: projection.albumMoments.length,
    );
  }
}

class RecordAlbumMomentCard extends StatelessWidget {
  const RecordAlbumMomentCard({
    super.key,
    required this.moment,
    required this.accentColor,
  });

  final RecordAlbumMoment moment;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final strings = RecordStrings.of(context);
    final dateFormat = strings.dateFormat('MMM d, yyyy');

    return AtlasPanel(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 168,
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(26),
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accentColor.withValues(alpha: 0.96),
                  accentColor.withValues(alpha: 0.58),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AtlasStatusPill(
                  label: moment.isSynthetic
                      ? (strings.isKorean ? '예정 커버' : 'Planned cover')
                      : (moment.isPlanned
                          ? (strings.isKorean ? '예정 여행' : 'Planned trip')
                          : (strings.isKorean ? '기록된 순간' : 'Recorded moment')),
                  color: Colors.white.withValues(alpha: 0.2),
                  icon: Icons.photo_rounded,
                ),
                const Spacer(),
                Text(
                  moment.primaryPhotoLabel,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${strings.tripTitle(moment.tripId, moment.tripTitle)} • ${moment.locationName}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    AtlasStatusPill(
                      label: strings.isKorean
                          ? '사진 ${moment.photoCount}장'
                          : '${moment.photoCount} photos',
                      color: accentColor,
                      icon: Icons.collections_rounded,
                    ),
                    AtlasStatusPill(
                      label: dateFormat.format(moment.happenedAt),
                      color: accentColor.withValues(alpha: 0.2),
                      icon: Icons.schedule_rounded,
                    ),
                  ],
                ),
                if (moment.summary.trim().isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(
                    moment.summary,
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
