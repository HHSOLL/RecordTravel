import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import 'record_wordmark.dart';

class RecordPageIntro extends StatelessWidget {
  const RecordPageIntro({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });

  final String eyebrow;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final palette = context.atlasPalette;
    final theme = Theme.of(context);

    return Column(
      children: [
        const Center(
          child: RecordWordmark(logoSize: 22, fontSize: 20, spacing: 10),
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(
              0xFFF59E0B,
            ).withValues(alpha: palette.isLight ? 0.18 : 0.22),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.24),
            ),
          ),
          child: Text(
            eyebrow,
            style: theme.textTheme.labelLarge?.copyWith(
              color: palette.isLight
                  ? const Color(0xFFB45309)
                  : const Color(0xFFF8D48B),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
