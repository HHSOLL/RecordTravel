import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../../../domain/record_travel_graph.dart';
import '../../../i18n/record_strings.dart';

class RecordCountryBottomSheet extends StatelessWidget {
  const RecordCountryBottomSheet({
    super.key,
    required this.spotlight,
    required this.strings,
    required this.onOpen,
    required this.onClose,
  });

  final RecordCountryProjection spotlight;
  final RecordStrings strings;
  final VoidCallback onOpen;
  final VoidCallback onClose;

  Color get _accentColor {
    final normalized = spotlight.accentColor.replaceAll('#', '');
    return Color(int.parse('FF$normalized', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.atlasPalette;

    return AtlasPanel(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AtlasStatusPill(
                label: spotlight.continent,
                color: _accentColor,
                icon: Icons.public_rounded,
              ),
              const Spacer(),
              InkWell(
                onTap: onClose,
                borderRadius: BorderRadius.circular(999),
                child: Ink(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: palette.surfaceMuted,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: palette.outline.withValues(alpha: 0.32),
                    ),
                  ),
                  child: const Icon(Icons.close_rounded, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            spotlight.name,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            strings.isKorean
                ? '한 번 더 탭하거나 아래 버튼으로 국가 상세 projection으로 들어갑니다.'
                : 'Tap once more or use the button below to enter this country projection.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MetricPill(
                icon: Icons.route_rounded,
                label: strings.timelineEntries(spotlight.visitCount),
                color: _accentColor,
              ),
              _MetricPill(
                icon: Icons.luggage_rounded,
                label: strings.profileTrips(spotlight.tripCount),
                color: _accentColor,
              ),
              _MetricPill(
                icon: Icons.auto_graph_rounded,
                label: strings.isKorean
                    ? '활동 점수 ${spotlight.activityScore.toStringAsFixed(1)}'
                    : 'Activity ${spotlight.activityScore.toStringAsFixed(1)}',
                color: _accentColor,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onOpen,
              icon: const Icon(Icons.arrow_outward_rounded),
              label: Text(strings.text('home.countryOpen')),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({
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
        border: Border.all(color: palette.outline.withValues(alpha: 0.32)),
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
