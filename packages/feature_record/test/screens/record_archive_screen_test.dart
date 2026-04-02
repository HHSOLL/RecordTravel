import 'package:feature_record/src/models/record_models.dart';
import 'package:feature_record/src/providers/record_provider.dart';
import 'package:feature_record/src/components/record_wordmark.dart';
import 'package:feature_record/src/screens/record_archive_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ko');
    await initializeDateFormatting('en');
  });

  testWidgets('archive header and cards adapt on a narrow phone viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1179, 2556);
    tester.view.devicePixelRatio = 3;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          recordTripsProvider.overrideWith((ref) => [
                _buildTrip(
                  id: 'trip-1',
                  color: '#6E8BF4',
                ),
                _buildTrip(
                  id: 'trip-2',
                  color: '#49B884',
                ),
              ]),
        ],
        child: MaterialApp(
          locale: const Locale('ko'),
          theme: ThemeData.dark(),
          home: const RecordArchiveScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(RecordArchiveScreen), findsOneWidget);
    expect(find.byType(RecordWordmark), findsOneWidget);
    expect(find.byIcon(Icons.search_rounded), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'trip-zzz');
    await tester.pumpAndSettle();
    expect(
        find.textContaining('A very long reflective trip title'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

RecordTrip _buildTrip({
  required String id,
  required String color,
}) {
  return RecordTrip(
    id: id,
    title: 'A very long reflective trip title that should still fit cleanly',
    countries: const [
      RecordCountry(
        name: 'France',
        code: 'FR',
        continent: 'Europe',
      ),
    ],
    startDate: '2026-01-10T09:00:00.000',
    endDate: '2026-01-15T18:00:00.000',
    description:
        'This description is intentionally verbose so the archive card has to clamp its copy without overflowing the grid cell on smaller phone widths.',
    coverImage: 'Evening river',
    isUpcoming: false,
    locations: const [
      RecordLocation(
        id: 'stop-1',
        name: 'Paris',
        countryCode: 'FR',
        countryName: 'France',
        lat: 48.8566,
        lng: 2.3522,
        date: '2026-01-10T09:00:00.000',
        photos: ['Evening river'],
      ),
      RecordLocation(
        id: 'stop-2',
        name: 'Lyon',
        countryCode: 'FR',
        countryName: 'France',
        lat: 45.7640,
        lng: 4.8357,
        date: '2026-01-12T09:00:00.000',
        photos: [],
      ),
    ],
    color: color,
    companions: const [],
  );
}
