import 'package:core_data/core_data.dart';
import 'package:core_domain/core_domain.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({
    super.key,
    required this.onOpenTrip,
    required this.onOpenCountry,
    required this.onOpenCity,
  });

  final ValueChanged<String> onOpenTrip;
  final ValueChanged<String> onOpenCountry;
  final ValueChanged<String> onOpenCity;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  SearchResultType? _filter;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allResults = ref.watch(searchResultsProvider(_controller.text));
    final results = _filter == null
        ? allResults
        : allResults.where((item) => item.type == _filter).toList();
    final grouped = _groupResults(results);
    return AtlasBackground(
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          children: [
            AtlasHeroPanel(
              eyebrow: 'Search',
              title: 'Places, trips, and memories should feel like one index.',
              message:
                  'Search stays useful only if it helps you jump into the right layer fast: trip, place, or memory.',
              trailing: const AtlasOrbitalGraphic(size: 92),
              metrics: [
                AtlasMiniMetric(
                  label: 'Trips',
                  value:
                      '${allResults.where((item) => item.type == SearchResultType.trip).length}',
                  icon: Icons.luggage_rounded,
                ),
                AtlasMiniMetric(
                  label: 'Places',
                  value:
                      '${allResults.where((item) => item.type == SearchResultType.country || item.type == SearchResultType.city).length}',
                  icon: Icons.public_rounded,
                ),
                AtlasMiniMetric(
                  label: 'Entries',
                  value:
                      '${allResults.where((item) => item.type == SearchResultType.entry).length}',
                  icon: Icons.menu_book_rounded,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search_rounded, color: Colors.white70),
                    hintText: 'Search places, trips, or memories',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.08),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _SearchFilterChip(
                  label: 'All',
                  selected: _filter == null,
                  onTap: () => setState(() => _filter = null),
                ),
                _SearchFilterChip(
                  label: 'Trips',
                  selected: _filter == SearchResultType.trip,
                  onTap: () => setState(() => _filter = SearchResultType.trip),
                ),
                _SearchFilterChip(
                  label: 'Memories',
                  selected: _filter == SearchResultType.entry,
                  onTap: () => setState(() => _filter = SearchResultType.entry),
                ),
                _SearchFilterChip(
                  label: 'Countries',
                  selected: _filter == SearchResultType.country,
                  onTap: () =>
                      setState(() => _filter = SearchResultType.country),
                ),
                _SearchFilterChip(
                  label: 'Cities',
                  selected: _filter == SearchResultType.city,
                  onTap: () => setState(() => _filter = SearchResultType.city),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_controller.text.trim().isEmpty)
              const AtlasEmptyState(
                title: 'Search feels best once your atlas starts to grow',
                message:
                    'Try a city like Kyoto, a country like Portugal, or a memory phrase you wrote down.',
              )
            else if (results.isEmpty)
              AtlasEmptyState(
                title: 'No matches yet',
                message: _filter == null
                    ? 'Try a broader place name, trip title, or memory phrase.'
                    : 'No matches in this category. Switch the filter or broaden the query.',
              )
            else
              ...grouped.entries.expand(
                (group) => [
                  AtlasSectionHeader(title: _titleForGroup(group.key)),
                  const SizedBox(height: 12),
                  ...group.value.map(
                    (result) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AtlasPanel(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(_iconForType(result.type)),
                          title: Text(result.title),
                          subtitle: Text(result.subtitle),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => _handleTap(result),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _handleTap(SearchResultItem result) {
    switch (result.type) {
      case SearchResultType.trip:
        widget.onOpenTrip(result.id);
        return;
      case SearchResultType.country:
        widget.onOpenCountry(result.id);
        return;
      case SearchResultType.city:
      case SearchResultType.entry:
        final place = result.place;
        if (place != null) {
          widget.onOpenCity(place.cityKey);
        } else {
          widget.onOpenCity(result.id);
        }
        return;
    }
  }
}

Map<SearchResultType, List<SearchResultItem>> _groupResults(
  List<SearchResultItem> results,
) {
  final grouped = <SearchResultType, List<SearchResultItem>>{};
  for (final result in results) {
    grouped.putIfAbsent(result.type, () => []).add(result);
  }
  return grouped;
}

String _titleForGroup(SearchResultType type) => switch (type) {
  SearchResultType.trip => 'Trips',
  SearchResultType.entry => 'Memories',
  SearchResultType.country => 'Countries',
  SearchResultType.city => 'Cities',
};

class _SearchFilterChip extends StatelessWidget {
  const _SearchFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}

IconData _iconForType(SearchResultType type) => switch (type) {
  SearchResultType.trip => Icons.luggage_rounded,
  SearchResultType.entry => Icons.menu_book_rounded,
  SearchResultType.country => Icons.public_rounded,
  SearchResultType.city => Icons.location_city_rounded,
};
