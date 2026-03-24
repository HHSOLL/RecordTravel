import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../i18n/record_strings.dart';
import '../providers/record_provider.dart';
import 'widgets/record_country_detail_album_tab.dart';
import 'widgets/record_country_detail_header.dart';
import 'widgets/record_country_detail_map_tab.dart';
import 'widgets/record_country_detail_tabs.dart';
import 'widgets/record_country_detail_timeline_tab.dart';

class RecordCountryDetailScreen extends ConsumerStatefulWidget {
  const RecordCountryDetailScreen({super.key, required this.countryCode});

  final String countryCode;

  @override
  ConsumerState<RecordCountryDetailScreen> createState() =>
      _RecordCountryDetailScreenState();
}

class _RecordCountryDetailScreenState
    extends ConsumerState<RecordCountryDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = RecordStrings.of(context);
    final projection =
        ref.watch(recordCountryProjectionProvider(widget.countryCode));

    if (projection == null) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: AtlasEmptyState(
            title: strings.text('trip.noMap'),
            message: strings.text('home.empty'),
          ),
        ),
      );
    }

    final accentColor = _colorFromHex(projection.accentColor);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 288,
              pinned: true,
              backgroundColor: theme.scaffoldBackgroundColor,
              surfaceTintColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                background: RecordCountryHero(
                  projection: projection,
                  accentColor: accentColor,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                child: RecordCountryOverviewStrip(
                  projection: projection,
                  accentColor: accentColor,
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: RecordCountryTabHeader(
                TabBar(
                  controller: _tabController,
                  indicatorColor: accentColor,
                  tabs: [
                    Tab(
                      icon: const Icon(Icons.map_rounded),
                      text: strings.text('trip.map'),
                    ),
                    Tab(
                      icon: const Icon(Icons.timeline_rounded),
                      text: strings.text('trip.timeline'),
                    ),
                    Tab(
                      icon: const Icon(Icons.photo_library_rounded),
                      text: strings.isKorean ? '앨범' : 'Album',
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            RecordCountryMapTab(
              projection: projection,
              accentColor: accentColor,
            ),
            RecordCountryTimelineTab(
              projection: projection,
              accentColor: accentColor,
            ),
            RecordCountryAlbumTab(
              projection: projection,
              accentColor: accentColor,
            ),
          ],
        ),
      ),
    );
  }
}

Color _colorFromHex(String color) {
  final normalized = color.replaceAll('#', '');
  return Color(int.parse('FF$normalized', radix: 16));
}
