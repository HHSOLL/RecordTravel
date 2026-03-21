import 'package:core_data/core_data.dart';
import 'package:core_domain/core_domain.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CountryDetailScreen extends ConsumerWidget {
  const CountryDetailScreen({
    super.key,
    required this.countryCode,
    required this.onOpenCity,
  });

  final String countryCode;
  final ValueChanged<String> onOpenCity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(countryDetailProvider(countryCode));
    if (detail == null) {
      return const Scaffold(body: Center(child: Text('Country not found')));
    }
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(detail.summary.countryName)),
      body: AtlasBackground(
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
            children: [
              AtlasHeroPanel(
                eyebrow: detail.summary.countryCode,
                title:
                    '${detail.summary.countryName} should feel like a chapter, not a pin.',
                message:
                    'Browse the cities, linked trips, and recent memories from one place-centric surface.',
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AtlasStatusPill(
                      label: '${detail.summary.cityCount} cities',
                      color: const Color(0xFF8DEBFF),
                      icon: Icons.public_rounded,
                    ),
                    const SizedBox(height: 16),
                    const AtlasOrbitalGraphic(size: 94),
                  ],
                ),
                metrics: [
                  AtlasMiniMetric(
                    label: 'Memories',
                    value: '${detail.summary.visitCount}',
                    icon: Icons.menu_book_rounded,
                  ),
                  AtlasMiniMetric(
                    label: 'Cities',
                    value: '${detail.summary.cityCount}',
                    icon: Icons.location_city_rounded,
                  ),
                  AtlasMiniMetric(
                    label: 'Latest',
                    value: formatShortDate(detail.summary.lastVisitedAt),
                    icon: Icons.schedule_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              AtlasSectionHeader(
                title: 'Cities',
                subtitle:
                    'Jump back into the parts of this country you actually recorded.',
              ),
              const SizedBox(height: 12),
              ...detail.cities.map(
                (city) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AtlasActionTile(
                    icon: Icons.location_city_rounded,
                    title: city.cityName,
                    subtitle:
                        '${city.visitCount} memories • Last ${formatShortDate(city.lastVisitedAt)}',
                    onTap: () => onOpenCity(city.key),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AtlasSectionHeader(
                title: 'Linked trips',
                subtitle:
                    'Country context should still lead back to the trip that created it.',
              ),
              const SizedBox(height: 12),
              if (detail.trips.isEmpty)
                const AtlasEmptyState(
                  title: 'No linked trips yet',
                  message:
                      'Trips touching this country will show up here once they are connected to memories.',
                )
              else
                SizedBox(
                  height: 156,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: detail.trips.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final trip = detail.trips[index];
                      return SizedBox(
                        width: 240,
                        child: AtlasPanel(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                trip.title,
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                trip.subtitle,
                                style: theme.textTheme.bodyMedium,
                              ),
                              const Spacer(),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  AtlasMetricChip(
                                    label: 'Memories',
                                    value: '${trip.memoryCount}',
                                  ),
                                  AtlasMetricChip(
                                    label: 'Photos',
                                    value: '${trip.photoCount}',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
              AtlasSectionHeader(
                title: 'Recent memories',
                subtitle:
                    'The country view should still help you re-read what happened there.',
              ),
              const SizedBox(height: 12),
              ...detail.entries
                  .take(4)
                  .map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AtlasPanel(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    entry.title,
                                    style: theme.textTheme.titleMedium,
                                  ),
                                ),
                                AtlasStatusPill(
                                  label: entry.type == MemoryType.photo
                                      ? 'Photo'
                                      : 'Note',
                                  color: entry.type == MemoryType.photo
                                      ? const Color(0xFF8DEBFF)
                                      : const Color(0xFF67E2B7),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(entry.body, style: theme.textTheme.bodyMedium),
                            const SizedBox(height: 8),
                            Text(
                              '${entry.place.cityName} • ${formatLongDate(entry.recordedAt)}',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class CityDetailScreen extends ConsumerWidget {
  const CityDetailScreen({super.key, required this.cityKey});

  final String cityKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(cityDetailProvider(cityKey));
    if (detail == null) {
      return const Scaffold(body: Center(child: Text('City not found')));
    }
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(detail.summary.cityName)),
      body: AtlasBackground(
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
            children: [
              AtlasHeroPanel(
                eyebrow: detail.summary.countryName,
                title:
                    '${detail.summary.cityName} should feel immediately recognizable.',
                message:
                    'This screen ties place, trips, and memories together without forcing the user back through search.',
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AtlasStatusPill(
                      label: '${detail.summary.visitCount} memories',
                      color: const Color(0xFF67E2B7),
                      icon: Icons.location_city_rounded,
                    ),
                    const SizedBox(height: 16),
                    const AtlasOrbitalGraphic(
                      size: 94,
                      glowColor: Color(0xFF67E2B7),
                    ),
                  ],
                ),
                metrics: [
                  AtlasMiniMetric(
                    label: 'Memories',
                    value: '${detail.summary.visitCount}',
                    icon: Icons.menu_book_rounded,
                  ),
                  AtlasMiniMetric(
                    label: 'Trips',
                    value: '${detail.trips.length}',
                    icon: Icons.luggage_rounded,
                  ),
                  AtlasMiniMetric(
                    label: 'Latest',
                    value: formatShortDate(detail.summary.lastVisitedAt),
                    icon: Icons.schedule_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              AtlasSectionHeader(
                title: 'Linked trips',
                subtitle:
                    'A city should quickly lead back to the trip context around it.',
              ),
              const SizedBox(height: 12),
              if (detail.trips.isEmpty)
                const AtlasEmptyState(
                  title: 'No linked trips yet',
                  message:
                      'Trips attached to this city will show up here as your atlas grows.',
                )
              else
                SizedBox(
                  height: 156,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: detail.trips.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final trip = detail.trips[index];
                      return SizedBox(
                        width: 240,
                        child: AtlasPanel(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                trip.title,
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                trip.dateRangeLabel,
                                style: theme.textTheme.bodyMedium,
                              ),
                              const Spacer(),
                              AtlasStatusPill(
                                label: trip.heroPlace.shortLabel,
                                color: const Color(0xFF8DEBFF),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
              AtlasSectionHeader(
                title: 'Recent entries',
                subtitle: 'Memories should stay readable in place context too.',
              ),
              const SizedBox(height: 12),
              ...detail.entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AtlasPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                entry.title,
                                style: theme.textTheme.titleMedium,
                              ),
                            ),
                            AtlasStatusPill(
                              label: entry.type == MemoryType.photo
                                  ? 'Photo'
                                  : 'Note',
                              color: entry.type == MemoryType.photo
                                  ? const Color(0xFF8DEBFF)
                                  : const Color(0xFF67E2B7),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(entry.body, style: theme.textTheme.bodyMedium),
                        const SizedBox(height: 8),
                        Text(
                          formatLongDate(entry.recordedAt),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
