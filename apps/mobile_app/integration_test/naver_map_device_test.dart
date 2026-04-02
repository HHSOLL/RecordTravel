import 'package:core_ui/core_ui.dart';
import 'package:feature_record/feature_record.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

const _runtimeChannel = MethodChannel('travel_atlas/runtime_capabilities');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final payload = await _runtimeChannel
        .invokeMapMethod<Object?, Object?>('getMapConfig')
        .timeout(const Duration(seconds: 2));
    final clientId = _normalizeRuntimeString(
      payload?['naverMapClientId'] as String?,
    );
    expect(clientId, isNotNull);
    await FlutterNaverMap().init(clientId: clientId!);
  });

  testWidgets('KR-only trip renders the Naver route map on device', (
    tester,
  ) async {
    await _pumpTripDetail(
      tester,
      trip: _buildTrip(
        id: 'trip-busan-jeju',
        title: 'Busan and Jeju reset',
        countries: const [
          RecordCountry(name: 'South Korea', code: 'KR', continent: 'Asia'),
        ],
        locations: const [
          RecordLocation(
            id: 'kr-stop-1',
            name: 'Busan',
            countryCode: 'KR',
            countryName: 'South Korea',
            lat: 35.1796,
            lng: 129.0756,
            date: '2026-02-14T09:00:00.000',
            photos: ['Busan harbor'],
          ),
          RecordLocation(
            id: 'kr-stop-2',
            name: 'Jeju',
            countryCode: 'KR',
            countryName: 'South Korea',
            lat: 33.4996,
            lng: 126.5312,
            date: '2026-02-16T09:00:00.000',
            photos: ['Jeju coast'],
          ),
        ],
      ),
    );

    await _openMapTab(tester);
    await _pumpUntilVisible(
      tester,
      find.byKey(const Key('record-trip-map-naver-trip-busan-jeju')),
    );
    expect(find.byType(NaverMap), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('mixed Korea + foreign trip stays on Google map branch', (
    tester,
  ) async {
    await _pumpTripDetail(
      tester,
      trip: _buildTrip(
        id: 'trip-seoul-kyoto',
        title: 'Seoul to Kyoto',
        countries: const [
          RecordCountry(name: 'South Korea', code: 'KR', continent: 'Asia'),
          RecordCountry(name: 'Japan', code: 'JP', continent: 'Asia'),
        ],
        locations: const [
          RecordLocation(
            id: 'mixed-stop-1',
            name: 'Seoul',
            countryCode: 'KR',
            countryName: 'South Korea',
            lat: 37.5665,
            lng: 126.9780,
            date: '2026-03-02T09:00:00.000',
            photos: ['Seoul morning'],
          ),
          RecordLocation(
            id: 'mixed-stop-2',
            name: 'Kyoto',
            countryCode: 'JP',
            countryName: 'Japan',
            lat: 35.0116,
            lng: 135.7681,
            date: '2026-03-05T09:00:00.000',
            photos: ['Kyoto alley'],
          ),
        ],
      ),
    );

    await _openMapTab(tester);
    await _pumpUntilVisible(
      tester,
      find.byKey(const Key('record-trip-map-google-trip-seoul-kyoto')),
    );
    expect(find.byType(NaverMap), findsNothing);
  });

  testWidgets('foreign-only trip stays on Google map branch', (tester) async {
    await _pumpTripDetail(
      tester,
      trip: _buildTrip(
        id: 'trip-bangkok-chiangmai',
        title: 'Bangkok to Chiang Mai',
        countries: const [
          RecordCountry(name: 'Thailand', code: 'TH', continent: 'Asia'),
        ],
        locations: const [
          RecordLocation(
            id: 'th-stop-1',
            name: 'Bangkok',
            countryCode: 'TH',
            countryName: 'Thailand',
            lat: 13.7563,
            lng: 100.5018,
            date: '2026-04-01T09:00:00.000',
            photos: ['Bangkok market'],
          ),
          RecordLocation(
            id: 'th-stop-2',
            name: 'Chiang Mai',
            countryCode: 'TH',
            countryName: 'Thailand',
            lat: 18.7883,
            lng: 98.9853,
            date: '2026-04-05T09:00:00.000',
            photos: ['Chiang Mai night'],
          ),
        ],
      ),
    );

    await _openMapTab(tester);
    await _pumpUntilVisible(
      tester,
      find.byKey(const Key('record-trip-map-google-trip-bangkok-chiangmai')),
    );
    expect(find.byType(NaverMap), findsNothing);
  });
}

Future<void> _pumpTripDetail(
  WidgetTester tester, {
  required RecordTrip trip,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        recordTripsProvider.overrideWith((ref) => [trip]),
      ],
      child: MaterialApp(
        locale: const Locale('ko'),
        theme: AtlasTheme.buildTheme(brightness: Brightness.dark),
        darkTheme: AtlasTheme.buildTheme(brightness: Brightness.dark),
        home: RecordTripDetailScreen(tripId: trip.id),
      ),
    ),
  );
  await tester.pumpAndSettle(const Duration(seconds: 2));
}

Future<void> _openMapTab(WidgetTester tester) async {
  Finder mapTab = find.text('지도');
  if (mapTab.evaluate().isEmpty) {
    mapTab = find.text('Map');
  }
  if (mapTab.evaluate().isEmpty) {
    mapTab = find.byIcon(Icons.map_rounded);
  }
  await tester.tap(mapTab.first);
  await tester.pumpAndSettle(const Duration(seconds: 2));
}

Future<void> _pumpUntilVisible(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 20),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 250));
    if (finder.evaluate().isNotEmpty) {
      await tester.pumpAndSettle(const Duration(seconds: 1));
      return;
    }
  }
  fail('Timed out waiting for $finder');
}

RecordTrip _buildTrip({
  required String id,
  required String title,
  required List<RecordCountry> countries,
  required List<RecordLocation> locations,
}) {
  return RecordTrip(
    id: id,
    title: title,
    countries: countries,
    startDate: locations.first.date,
    endDate: locations.last.date,
    description: 'Verification trip for map-provider selection.',
    coverImage: locations.first.photos.firstOrNull ?? 'cover',
    isUpcoming: false,
    locations: locations,
    color: '#6E8BF4',
    companions: const [],
  );
}

String? _normalizeRuntimeString(String? value) {
  if (value == null) {
    return null;
  }
  final trimmed = value.trim();
  if (trimmed.isEmpty || trimmed.startsWith(r'$(')) {
    return null;
  }
  return trimmed;
}
