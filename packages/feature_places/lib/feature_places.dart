import 'package:core_data/core_data.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CountryDetailScreen extends ConsumerWidget {
  const CountryDetailScreen({super.key, required this.countryCode, required this.onOpenCity});

  final String countryCode;
  final ValueChanged<String> onOpenCity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(countryDetailProvider(countryCode));
    if (detail == null) {
      return const Scaffold(body: Center(child: Text('Country not found')));
    }
    return Scaffold(
      appBar: AppBar(title: Text(detail.summary.countryName)),
      body: AtlasBackground(
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
            children: [
              AtlasPanel(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    AtlasMetricChip(label: 'Memories', value: '${detail.summary.visitCount}'),
                    AtlasMetricChip(label: 'Cities', value: '${detail.summary.cityCount}'),
                    AtlasMetricChip(label: 'Latest', value: formatShortDate(detail.summary.lastVisitedAt)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const AtlasSectionHeader(title: 'Cities'),
              const SizedBox(height: 12),
              ...detail.cities.map(
                (city) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AtlasPanel(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(city.cityName),
                      subtitle: Text('${city.visitCount} memories • Last ${formatShortDate(city.lastVisitedAt)}'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => onOpenCity(city.key),
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
    return Scaffold(
      appBar: AppBar(title: Text(detail.summary.cityName)),
      body: AtlasBackground(
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
            children: [
              AtlasPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(detail.summary.countryName, style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        AtlasMetricChip(label: 'Memories', value: '${detail.summary.visitCount}'),
                        AtlasMetricChip(label: 'Trips', value: '${detail.trips.length}'),
                        AtlasMetricChip(label: 'Latest', value: formatShortDate(detail.summary.lastVisitedAt)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const AtlasSectionHeader(title: 'Recent entries'),
              const SizedBox(height: 12),
              ...detail.entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AtlasPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(entry.title, style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 6),
                        Text(entry.body, style: Theme.of(context).textTheme.bodyMedium),
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
