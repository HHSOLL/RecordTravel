import 'dart:ui' as ui;

import 'package:core_data/core_data.dart';
import 'package:core_navigation/core_navigation.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:feature_record/feature_record.dart';

import '../app/app_preferences.dart';

class MobileAppShell extends ConsumerStatefulWidget {
  const MobileAppShell({super.key});

  @override
  ConsumerState<MobileAppShell> createState() => _MobileAppShellState();
}

class _MobileAppShellState extends ConsumerState<MobileAppShell> {
  AppTab _currentTab = AppTab.home;

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(appPreferencesProvider);
    final palette = context.atlasPalette;

    return Scaffold(
      body: _buildCurrentPage(prefs),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.only(left: 24, right: 24, bottom: 18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                palette.isLight
                    ? const Color(0xFFF5F5F4)
                    : const Color(0xFF0A0A0A),
                (palette.isLight
                        ? const Color(0xFFF5F5F4)
                        : const Color(0xFF0A0A0A))
                    .withValues(alpha: 0),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 14, 0, 6),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  height: 68,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  decoration: BoxDecoration(
                    color: palette.isLight
                        ? Colors.white.withValues(alpha: 0.9)
                        : const Color(0xFF292524).withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: palette.isLight
                          ? const Color(0xFFE7E5E4)
                          : Colors.white.withValues(alpha: 0.10),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: palette.isLight ? 0.14 : 0.28,
                        ),
                        blurRadius: 26,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _NavButton(
                        icon: Icons.public_rounded,
                        isActive: _currentTab == AppTab.home,
                        onTap: () => setState(() => _currentTab = AppTab.home),
                      ),
                      _NavButton(
                        icon: Icons.map_rounded,
                        isActive: _currentTab == AppTab.archive,
                        onTap: () =>
                            setState(() => _currentTab = AppTab.archive),
                      ),
                      GestureDetector(
                        onTap: _openCreateTrip,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: palette.isLight
                                ? const Color(0xFFF59E0B)
                                : const Color(0xFFFBBF24),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color:
                                    (palette.isLight
                                            ? const Color(0xFFF59E0B)
                                            : const Color(0xFFFBBF24))
                                        .withValues(alpha: 0.40),
                                blurRadius: 20,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.add_rounded,
                            color: palette.isLight
                                ? Colors.white
                                : const Color(0xFF1C1917),
                            size: 28,
                          ),
                        ),
                      ),
                      _NavButton(
                        icon: Icons.calendar_month_rounded,
                        isActive: _currentTab == AppTab.planner,
                        onTap: () =>
                            setState(() => _currentTab = AppTab.planner),
                      ),
                      _NavButton(
                        icon: Icons.person_rounded,
                        isActive: _currentTab == AppTab.profile,
                        onTap: () =>
                            setState(() => _currentTab = AppTab.profile),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentPage(AppPreferencesController prefs) =>
      switch (_currentTab) {
        AppTab.home => RecordHomeScreen(
          isDarkMode: Theme.of(context).brightness == Brightness.dark,
          onOpenProfile: () {
            setState(() => _currentTab = AppTab.profile);
          },
        ),
        AppTab.planner => const RecordPlannerScreen(),
        AppTab.archive => const RecordArchiveScreen(),
        AppTab.profile => RecordProfileScreen(
          isDarkMode: Theme.of(context).brightness == Brightness.dark,
          languageCode: prefs.locale.languageCode,
          onLanguageChanged: (languageCode) {
            ref.read(appPreferencesProvider).setLanguageCode(languageCode);
          },
          onSignOut: () {
            ref.read(sessionRepositoryProvider).signOut();
          },
        ),
      };

  void _openCreateTrip() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RecordCreateTripScreen()),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.atlasPalette;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 40,
        height: 40,
        decoration: isActive
            ? BoxDecoration(
                color: palette.isLight
                    ? const Color(0xFFF5F5F4)
                    : Colors.white.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(999),
              )
            : null,
        child: Center(
          child: Icon(
            icon,
            size: 24,
            color: isActive
                ? Theme.of(context).colorScheme.onSurface
                : palette.isLight
                ? const Color(0xFFA8A29E)
                : Colors.white.withValues(alpha: 0.50),
          ),
        ),
      ),
    );
  }
}
