import 'package:feature_record/src/globe/domain/entities/record_globe_country.dart';
import 'package:feature_record/src/globe/domain/entities/record_globe_scene_spec.dart';
import 'package:feature_record/src/globe/presentation/widgets/record_globe_viewport.dart';
import 'package:feature_record/src/models/record_models.dart';
import 'package:feature_record/src/providers/record_provider.dart';
import 'package:feature_record/src/screens/record_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows fallback UI when 3D globe is forced off', (
    tester,
  ) async {
    var retried = false;
    final trip = _buildTrip();
    tester.view.physicalSize = const Size(1179, 2556);
    tester.view.devicePixelRatio = 3;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          recordUserProvider.overrideWith(
            (ref) => const RecordUserData(
              name: 'Sol',
              title: 'Atlas archivist',
              totalCities: 3,
              totalCountries: 1,
              totalTrips: 1,
            ),
          ),
          recordTripsProvider.overrideWith((ref) => [trip]),
          recordGlobeSceneSpecProvider(Brightness.dark).overrideWith(
            (ref) => RecordGlobeSceneSpec(
              style: RecordGlobeStyle.dark,
              countries: const [
                RecordGlobeCountry(
                  code: 'FR',
                  name: 'France',
                  anchorLatitude: 46.2276,
                  anchorLongitude: 2.2137,
                  continent: 'Europe',
                ),
              ],
            ),
          ),
        ],
        child: MaterialApp(
          theme: ThemeData.dark(),
          home: RecordHomeScreen(
            forceGlobeFallback: true,
            onRetryGlobe3D: () {
              retried = true;
            },
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(RecordGlobeViewport), findsNothing);
    expect(find.byKey(const Key('record-home-globe-fallback')), findsOneWidget);
    expect(find.text('France'), findsOneWidget);

    final retryButtonFinder = find.byKey(const Key('record-home-retry-3d'));
    expect(retryButtonFinder, findsOneWidget);
    final retryButton = tester.widget<Widget>(retryButtonFinder) as dynamic;
    retryButton.onPressed?.call();
    await tester.pump();

    expect(retried, isTrue);
    expect(tester.takeException(), isNull);
  });
}

RecordTrip _buildTrip() {
  return const RecordTrip(
    id: 'trip-france',
    title: 'France Notes',
    countries: [
      RecordCountry(
        name: 'France',
        code: 'FR',
        continent: 'Europe',
      ),
    ],
    startDate: '2026-01-10T09:00:00.000',
    endDate: '2026-01-15T18:00:00.000',
    description: 'A compact archive card for fallback testing.',
    coverImage: 'Paris lights',
    isUpcoming: false,
    locations: [
      RecordLocation(
        id: 'entry-paris',
        name: 'Paris',
        countryCode: 'FR',
        countryName: 'France',
        lat: 48.8566,
        lng: 2.3522,
        date: '2026-01-11T09:00:00.000',
        photos: ['Paris lights'],
      ),
    ],
    color: '#6E8BF4',
    companions: [],
  );
}
