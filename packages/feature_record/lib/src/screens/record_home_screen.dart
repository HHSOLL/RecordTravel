import 'dart:math' as math;

import 'package:core_data/core_data.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/record_globe.dart';
import '../components/record_globe_scene.dart';
import '../components/record_wordmark.dart';
import '../i18n/record_strings.dart';
import '../providers/record_provider.dart';

class RecordHomeScreen extends ConsumerStatefulWidget {
  const RecordHomeScreen({
    super.key,
    required this.isDarkMode,
    this.onOpenProfile,
  });

  final bool isDarkMode;
  final VoidCallback? onOpenProfile;

  @override
  ConsumerState<RecordHomeScreen> createState() => _RecordHomeScreenState();
}

class _RecordHomeScreenState extends ConsumerState<RecordHomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enterAnim;
  String? _selectedCountryCode;

  @override
  void initState() {
    super.initState();
    _enterAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _enterAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = RecordStrings.of(context);
    final user = ref.watch(recordUserProvider);
    final trips = ref.watch(recordTripsProvider);
    final theme = Theme.of(context);
    final globeScene = ref.watch(recordGlobeSceneProvider(theme.brightness));
    final palette = context.atlasPalette;
    final selectedCountryCode =
        _selectedCountryCode ?? globeScene.initialCountryCode;
    final upcomingCount = trips.where((trip) => trip.isUpcoming).length;
    final hasTrips = trips.isNotEmpty;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: AtlasBackground(
        child: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compactLayout = constraints.maxHeight < 780;
              final contentWidth = constraints.maxWidth - 40;
              final globeSize = hasTrips
                  ? math.min(
                      contentWidth * (compactLayout ? 0.72 : 0.8),
                      compactLayout ? 232.0 : 288.0,
                    )
                  : 0.0;

              return AnimatedBuilder(
                animation: _enterAnim,
                builder: (context, child) {
                  final value = Curves.easeOutCubic.transform(_enterAnim.value);
                  return Transform.translate(
                    offset: Offset(0, 18 * (1 - value)),
                    child: Opacity(
                      opacity: value.clamp(0.0, 1.0),
                      child: child,
                    ),
                  );
                },
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 48),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _HeaderButton(
                            icon: widget.isDarkMode
                                ? Icons.dark_mode_rounded
                                : Icons.light_mode_rounded,
                          ),
                          Expanded(
                            child: Center(
                              child: Transform.translate(
                                offset: const Offset(-4, 0),
                                child: const RecordWordmark(
                                  logoSize: 24,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                          _HeaderButton(
                            onPressed: widget.onOpenProfile,
                            child: _ProfileBadge(name: user.name),
                          ),
                        ],
                      ),
                      const SizedBox(height: 26),
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B).withValues(
                                alpha: palette.isLight ? 0.18 : 0.22,
                              ),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: const Color(0xFFF59E0B).withValues(
                                  alpha: 0.26,
                                ),
                              ),
                            ),
                            child: Text(
                              user.title,
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
                            strings.homeTitle(user.name),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.9,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            strings.cityCountryProgress(
                              user.totalCities,
                              user.totalCountries,
                            ),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _StatCapsule(
                            icon: Icons.map_rounded,
                            label: strings.text('nav.archive'),
                            value: '${user.totalTrips}',
                          ),
                          _StatCapsule(
                            icon: Icons.calendar_month_rounded,
                            label: strings.text('nav.planner'),
                            value: '$upcomingCount',
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (hasTrips)
                        Center(
                          child: SizedBox(
                            width: globeSize,
                            height: globeSize + 6,
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: RecordGlobe(
                                size: globeSize,
                                scene: globeScene,
                                selectedCountryCode: selectedCountryCode,
                                onCountrySelected: (countryCode) {
                                  setState(() {
                                    _selectedCountryCode = countryCode;
                                  });
                                },
                              ),
                            ),
                          ),
                        )
                      else
                        AtlasEmptyState(
                          title: strings.text('home.empty'),
                          message: strings.text('nav.create'),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    this.onPressed,
    this.icon,
    this.child,
  });

  final VoidCallback? onPressed;
  final IconData? icon;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final palette = context.atlasPalette;
    final content = child ??
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.onSurface,
        );

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(999),
      child: Ink(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: palette.surfaceGlass.withValues(
            alpha: palette.isLight ? 0.92 : 0.64,
          ),
          shape: BoxShape.circle,
          border: Border.all(
            color: palette.outline.withValues(alpha: 0.5),
          ),
        ),
        child: Center(child: content),
      ),
    );
  }
}

class _ProfileBadge extends StatelessWidget {
  const _ProfileBadge({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final trimmed = name.trim();
    final initials =
        trimmed.isEmpty ? 'R' : String.fromCharCode(trimmed.runes.first);
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _StatCapsule extends StatelessWidget {
  const _StatCapsule({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final palette = context.atlasPalette;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: palette.surfaceGlass.withValues(
          alpha: palette.isLight ? 0.88 : 0.55,
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: palette.outline.withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: palette.accent),
          const SizedBox(width: 8),
          Text(
            '$label · $value',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
