import 'package:flutter/material.dart';

enum AppTab { home, timeline, search, profile }

extension AppTabMeta on AppTab {
  String get label => switch (this) {
        AppTab.home => 'Home',
        AppTab.timeline => 'Timeline',
        AppTab.search => 'Search',
        AppTab.profile => 'Profile',
      };

  IconData get icon => switch (this) {
        AppTab.home => Icons.home_rounded,
        AppTab.timeline => Icons.auto_stories_rounded,
        AppTab.search => Icons.travel_explore_rounded,
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
