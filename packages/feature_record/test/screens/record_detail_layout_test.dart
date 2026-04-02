import 'package:feature_record/src/domain/record_travel_graph.dart';
import 'package:feature_record/src/models/record_models.dart';
import 'package:feature_record/src/providers/record_provider.dart';
import 'package:feature_record/src/screens/record_country_detail_screen.dart';
import 'package:feature_record/src/screens/record_trip_detail_screen.dart';
import 'package:feature_record/src/screens/widgets/record_map_runtime.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await initializeDateFormatting('ko');
    await initializeDateFormatting('en');
  });

  testWidgets('country detail adapts on a narrow phone without overflow', (
    tester,
  ) async {
    final graph = _buildGraph();
    _setNarrowPhoneViewport(tester);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          recordTravelGraphProvider.overrideWith((ref) => graph),
          recordMapRuntimeConfigProvider.overrideWith(
            (ref) async => const RecordMapRuntimeConfig(
              hasGoogleMapsKey: false,
              hasNaverMapClientId: false,
              naverMapClientId: null,
            ),
          ),
        ],
        child: MaterialApp(
          locale: const Locale('ko'),
          theme: ThemeData.dark(),
          home: const RecordCountryDetailScreen(countryCode: 'JP'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('record-country-detail-JP')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('trip detail adapts on a narrow phone without overflow', (
    tester,
  ) async {
    final graph = _buildGraph();
    _setNarrowPhoneViewport(tester);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          recordTravelGraphProvider.overrideWith((ref) => graph),
          recordMapRuntimeConfigProvider.overrideWith(
            (ref) async => const RecordMapRuntimeConfig(
              hasGoogleMapsKey: false,
              hasNaverMapClientId: false,
              naverMapClientId: null,
            ),
          ),
        ],
        child: MaterialApp(
          locale: const Locale('ko'),
          theme: ThemeData.dark(),
          home: const RecordTripDetailScreen(
            tripId: 'trip-japan',
            initialTabIndex: 1,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(RecordTripDetailScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

void _setNarrowPhoneViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1125, 2436);
  tester.view.devicePixelRatio = 3;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

RecordTravelGraph _buildGraph() {
  final trip = RecordTrip(
    id: 'trip-japan',
    title: 'Spring between Seoul and Kyoto',
    countries: const [
      RecordCountry(
        name: 'Japan',
        code: 'JP',
        continent: 'Asia',
      ),
    ],
    startDate: '2026-04-14T09:00:00.000',
    endDate: '2026-04-22T18:00:00.000',
    description:
        'A deliberately verbose trip description that should still clamp and wrap without overflowing on narrow mobile screens.',
    coverImage: 'Kyoto alley light',
    isUpcoming: false,
    locations: const [
      RecordLocation(
        id: 'stop-osaka',
        name: 'Osaka',
        countryCode: 'JP',
        countryName: 'Japan',
        lat: 34.6937,
        lng: 135.5023,
        date: '2026-04-14T09:00:00.000',
        photos: ['Dotonbori neon'],
      ),
      RecordLocation(
        id: 'stop-kyoto',
        name: 'Kyoto',
        countryCode: 'JP',
        countryName: 'Japan',
        lat: 35.0116,
        lng: 135.7681,
        date: '2026-04-16T11:30:00.000',
        photos: ['Temple moss'],
      ),
      RecordLocation(
        id: 'stop-nara',
        name: 'Nara',
        countryCode: 'JP',
        countryName: 'Japan',
        lat: 34.6851,
        lng: 135.8048,
        date: '2026-04-18T13:45:00.000',
        photos: [],
      ),
    ],
    color: '#6E8BF4',
    companions: const ['Sol'],
  );

  return RecordTravelGraph(
    trips: [trip],
    countries: [
      RecordCountryProjection(
        code: 'JP',
        name: 'Japan',
        continent: 'Asia',
        accentColor: '#6E8BF4',
        signal: RecordCountrySignal.visited,
        trips: [trip],
        locations: trip.locations,
        timelineDays: [
          RecordTimelineDay(
            date: DateTime.parse('2026-04-16T00:00:00.000'),
            moments: [
              RecordTimelineMoment(
                id: 'moment-kyoto',
                tripId: 'trip-japan',
                tripTitle: 'Spring between Seoul and Kyoto',
                locationName: 'Kyoto',
                happenedAt: DateTime.utc(2026, 4, 16, 11, 30),
                title: 'Temple district walk',
                summary:
                    'Notebook entry with a long localized summary intended to wrap across multiple lines without causing layout overflow in the detail timeline card.',
                photoLabels: ['Temple moss', 'Lantern alley'],
                isPlanned: false,
                isSynthetic: false,
              ),
            ],
          ),
        ],
        albumMoments: [
          RecordAlbumMoment(
            id: 'album-kyoto',
            tripId: 'trip-japan',
            tripTitle: 'Spring between Seoul and Kyoto',
            locationName: 'Kyoto',
            happenedAt: DateTime.utc(2026, 4, 16, 11, 30),
            primaryPhotoLabel: 'Temple moss',
            photoCount: 2,
            summary:
                'Representative photo summary used to validate the album panel on compact devices.',
            isPlanned: false,
            isSynthetic: false,
          ),
        ],
        centerLat: 35.2,
        centerLng: 135.8,
        minLat: 34.6,
        maxLat: 35.2,
        minLng: 135.4,
        maxLng: 135.9,
        tripCount: 1,
        cityCount: 3,
        visitCount: 3,
        plannedStopCount: 0,
        photoCount: 2,
        noteCount: 1,
        totalDays: 8,
        activityScore: 4.4,
        activityLevel: 4,
        hasUpcomingTrip: false,
        hasRecentVisit: true,
      ),
    ],
  );
}
