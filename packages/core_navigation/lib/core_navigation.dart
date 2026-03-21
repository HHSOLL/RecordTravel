import 'package:flutter/material.dart';

enum AppTab { home, planner, archive, profile }

extension AppTabMeta on AppTab {
  String get label => switch (this) {
        AppTab.home => 'Home',
        AppTab.planner => 'Planner',
        AppTab.archive => 'Archive',
        AppTab.profile => 'Profile',
      };

  IconData get icon => switch (this) {
        AppTab.home => Icons.language_rounded,
        AppTab.planner => Icons.calendar_month_rounded,
        AppTab.archive => Icons.auto_awesome_motion_rounded,
        AppTab.profile => Icons.person_rounded,
      };
}

class AppRoutes {
  static const shell = '/';
  static const journalHub = '/journal';
  static const tripDetail = '/trip-detail';
  static const countryDetail = '/country-detail';
  static const cityDetail = '/city-detail';
}
