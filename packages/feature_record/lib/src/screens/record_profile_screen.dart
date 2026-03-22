import 'package:core_data/core_data.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/record_page_intro.dart';
import '../i18n/record_strings.dart';
import '../providers/record_provider.dart';

class RecordProfileScreen extends ConsumerWidget {
  const RecordProfileScreen({
    super.key,
    required this.isDarkMode,
    required this.languageCode,
    required this.onLanguageChanged,
    required this.onSignOut,
  });

  final bool isDarkMode;
  final String languageCode;
  final ValueChanged<String> onLanguageChanged;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = RecordStrings.of(context);
    final user = ref.watch(recordUserProvider);
    final session = ref.watch(sessionSnapshotProvider);
    final theme = Theme.of(context);
    final palette = context.atlasPalette;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: AtlasBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
            children: [
              RecordPageIntro(
                eyebrow: strings.text('nav.profile'),
                title: strings.text('profile.title'),
                subtitle: user.title,
              ),
              const SizedBox(height: 18),
              AtlasPanel(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 42,
                      backgroundColor: palette.accentSoft.withValues(
                        alpha: palette.isLight ? 0.18 : 0.2,
                      ),
                      child: Text(
                        user.name.isEmpty
                            ? 'U'
                            : user.name.substring(0, 1).toUpperCase(),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AtlasStatusPill(
                      label: user.title,
                      color: palette.accentSoft,
                      icon: Icons.auto_awesome_rounded,
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: [
                        AtlasMiniMetric(
                          label: strings.text('nav.archive'),
                          value: '${user.totalTrips}',
                          icon: Icons.auto_awesome_motion_rounded,
                        ),
                        AtlasMiniMetric(
                          label: 'Cities',
                          value: '${user.totalCities}',
                          icon: Icons.location_city_rounded,
                        ),
                        AtlasMiniMetric(
                          label: 'Countries',
                          value: '${user.totalCountries}',
                          icon: Icons.public_rounded,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _SectionCard(
                title: strings.text('profile.preferences'),
                child: Column(
                  children: [
                    _PreferenceRow(
                      icon: Icons.brightness_auto_rounded,
                      title: strings.text('profile.systemTheme'),
                      subtitle: strings.text('profile.systemThemeSubtitle'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: palette.surfaceMuted,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: palette.outline),
                        ),
                        child: Text(
                          isDarkMode
                              ? strings.text('profile.darkMode')
                              : strings.text('profile.lightMode'),
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        strings.text('profile.language'),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<String>(
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment(value: 'ko', label: Text('한국어')),
                        ButtonSegment(value: 'en', label: Text('English')),
                      ],
                      selected: {languageCode},
                      onSelectionChanged: (selection) {
                        onLanguageChanged(selection.first);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _SectionCard(
                title: strings.text('profile.account'),
                child: Column(
                  children: [
                    _PreferenceRow(
                      icon: Icons.verified_user_rounded,
                      title: strings.text('profile.previewAuth'),
                      subtitle: strings.text('profile.previewAuthSubtitle'),
                    ),
                    const SizedBox(height: 12),
                    _PreferenceRow(
                      icon: Icons.storage_rounded,
                      title: session.backendProfile.label,
                      subtitle: session.backendProfile.notes,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: onSignOut,
                        icon: const Icon(Icons.logout_rounded),
                        label: Text(strings.text('profile.logout')),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.atlasPalette;
    return AtlasPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: palette.accent,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _PreferenceRow extends StatelessWidget {
  const _PreferenceRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.atlasPalette;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: palette.surfaceMuted,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: palette.outline),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: palette.accentSoft),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(subtitle, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 12), trailing!],
      ],
    );
  }
}
