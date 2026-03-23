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
    required this.themeMode,
    required this.languageCode,
    required this.onThemeModeChanged,
    required this.onLanguageChanged,
    required this.onSignOut,
    required this.onImportGallery,
    required this.onRequestSync,
  });

  final bool isDarkMode;
  final ThemeMode themeMode;
  final String languageCode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ValueChanged<String> onLanguageChanged;
  final VoidCallback onSignOut;
  final VoidCallback onImportGallery;
  final VoidCallback onRequestSync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = RecordStrings.of(context);
    final user = ref.watch(recordUserProvider);
    final session = ref.watch(sessionSnapshotProvider);
    final sync = ref.watch(syncSnapshotProvider);
    final photos = ref.watch(photosProvider);
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
              AtlasHeroPanel(
                eyebrow: strings.text('profile.workspaceTitle'),
                title: user.name,
                message: strings.text('profile.workspaceSubtitle'),
                trailing: CircleAvatar(
                  radius: 28,
                  backgroundColor: palette.accentSoft.withValues(
                    alpha: palette.isLight ? 0.18 : 0.2,
                  ),
                  child: Text(
                    user.name.isEmpty
                        ? 'U'
                        : user.name.substring(0, 1).toUpperCase(),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                metrics: [
                  AtlasMiniMetric(
                    label: strings.text('nav.archive'),
                    value: '${user.totalTrips}',
                    icon: Icons.auto_awesome_motion_rounded,
                  ),
                  AtlasMiniMetric(
                    label: strings.text('profile.photos'),
                    value: '${photos.length}',
                    icon: Icons.photo_library_rounded,
                  ),
                  AtlasMiniMetric(
                    label: strings.text('profile.pendingUploads'),
                    value: '${sync.pendingUploads}',
                    icon: Icons.cloud_upload_rounded,
                  ),
                ],
                actions: [
                  FilledButton.icon(
                    onPressed: onImportGallery,
                    icon: const Icon(Icons.photo_library_rounded),
                    label: Text(strings.text('profile.importLibrary')),
                  ),
                  OutlinedButton.icon(
                    onPressed: onRequestSync,
                    icon: const Icon(Icons.sync_rounded),
                    label: Text(strings.text('profile.syncNow')),
                  ),
                ],
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
                      trailing: SegmentedButton<ThemeMode>(
                        showSelectedIcon: false,
                        segments: [
                          ButtonSegment(
                            value: ThemeMode.system,
                            label: Text(strings.text('profile.systemShort')),
                          ),
                          ButtonSegment(
                            value: ThemeMode.light,
                            label: Text(strings.text('profile.lightShort')),
                          ),
                          ButtonSegment(
                            value: ThemeMode.dark,
                            label: Text(strings.text('profile.darkShort')),
                          ),
                        ],
                        selected: {themeMode},
                        onSelectionChanged: (selection) {
                          onThemeModeChanged(selection.first);
                        },
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
