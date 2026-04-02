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
import 'widgets/record_map_runtime.dart';

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
    final mapRuntimeConfig = ref.watch(recordMapRuntimeConfigProvider);

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
    final isMapUnavailable = mapRuntimeConfig.maybeWhen(
      data: (value) =>
          recordMapProviderForProjection(
            config: value,
            projection: projection,
          ) ==
          RecordMapProviderKind.unavailable,
      orElse: () => false,
    );

    if (isMapUnavailable && _tabController.index == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _tabController.index == 0) {
          _tabController.animateTo(1);
        }
      });
    }

    return Scaffold(
      key: Key('record-country-detail-${widget.countryCode}'),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 416,
              pinned: true,
              backgroundColor: theme.scaffoldBackgroundColor,
              surfaceTintColor: Colors.transparent,
              leadingWidth: 72,
              leading: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 0, 10),
                child: RecordCountryRoundHeroButton(
                  key: const Key('record-country-detail-back'),
                  icon: Icons.arrow_back_rounded,
                  onTap: () => Navigator.of(context).maybePop(),
                ),
              ),
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
            switch (mapRuntimeConfig) {
              AsyncData(:final value) => switch (recordMapProviderForProjection(
                  config: value,
                  projection: projection,
                )) {
                  RecordMapProviderKind.google ||
                  RecordMapProviderKind.naver =>
                    RecordCountryMapTab(
                      projection: projection,
                      accentColor: accentColor,
                    ),
                  RecordMapProviderKind.unavailable =>
                    _RecordCountryDetailMapFallback(
                      child: RecordMapUnavailableSurface(
                        accentColor: accentColor,
                        height: 320,
                      ),
                    ),
                },
              AsyncLoading() => const _RecordCountryDetailMapFallback(
                  child: RecordMapLoadingSurface(height: 320),
                ),
              _ => _RecordCountryDetailMapFallback(
                  child: RecordMapUnavailableSurface(
                    accentColor: accentColor,
                    height: 320,
                  ),
                ),
            },
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

class _RecordCountryDetailMapFallback extends StatelessWidget {
  const _RecordCountryDetailMapFallback({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final strings = RecordStrings.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        child,
        const SizedBox(height: 16),
        AtlasPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.isKorean ? '지도 미리보기 제한' : 'Map preview limited',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                strings.isKorean
                    ? '이 환경에서는 네이티브 지도를 띄우지 않고, 아래 타임라인과 앨범 투영을 같은 여행 그래프에서 유지합니다.'
                    : 'This environment keeps the same travel graph active while deferring the native map surface.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
