import 'package:feature_record/src/models/record_models.dart';
import 'package:feature_record/src/screens/widgets/record_map_runtime.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('recordMapProviderForTrip', () {
    const configWithBoth = RecordMapRuntimeConfig(
      hasGoogleMapsKey: true,
      hasNaverMapClientId: true,
      naverMapClientId: 'naver-client-id',
    );

    const configGoogleOnly = RecordMapRuntimeConfig(
      hasGoogleMapsKey: true,
      hasNaverMapClientId: false,
      naverMapClientId: null,
    );

    const configWithoutMaps = RecordMapRuntimeConfig(
      hasGoogleMapsKey: false,
      hasNaverMapClientId: false,
      naverMapClientId: null,
    );

    test('uses Naver for Korea-only trips when client ID is present', () {
      expect(
        recordMapProviderForTrip(
          config: configWithBoth,
          trip: _tripWithCodes(const ['KR']),
        ),
        RecordMapProviderKind.naver,
      );
    });

    test('keeps Google for mixed Korea and foreign trips', () {
      expect(
        recordMapProviderForTrip(
          config: configWithBoth,
          trip: _tripWithCodes(const ['KR', 'JP']),
        ),
        RecordMapProviderKind.google,
      );
    });

    test('keeps Google for foreign-only trips', () {
      expect(
        recordMapProviderForTrip(
          config: configWithBoth,
          trip: _tripWithCodes(const ['JP']),
        ),
        RecordMapProviderKind.google,
      );
    });

    test('falls back to Google for Korea-only trips without Naver credentials', () {
      expect(
        recordMapProviderForTrip(
          config: configGoogleOnly,
          trip: _tripWithCodes(const ['KR']),
        ),
        RecordMapProviderKind.google,
      );
    });

    test('returns unavailable for mixed trips without Google credentials', () {
      expect(
        recordMapProviderForTrip(
          config: configWithoutMaps,
          trip: _tripWithCodes(const ['KR', 'JP']),
        ),
        RecordMapProviderKind.unavailable,
      );
    });
  });
}

RecordTrip _tripWithCodes(List<String> countryCodes) {
  final countries = [
    for (final code in countryCodes)
      RecordCountry(
        name: code,
        code: code,
        continent: 'Test',
      ),
  ];

  final locations = [
    for (var index = 0; index < countryCodes.length; index += 1)
      RecordLocation(
        id: 'location-$index',
        name: 'Location $index',
        countryCode: countryCodes[index],
        countryName: countryCodes[index],
        lat: 37.0 + index,
        lng: 127.0 + index,
        date: DateTime(2026, 1, index + 1).toIso8601String(),
        photos: const [],
      ),
  ];

  return RecordTrip(
    id: 'trip-${countryCodes.join('-')}',
    title: 'Mock Trip',
    countries: countries,
    startDate: DateTime(2026, 1, 1).toIso8601String(),
    endDate: DateTime(2026, 1, 5).toIso8601String(),
    description: 'Mock',
    coverImage: 'Mock',
    isUpcoming: false,
    locations: locations,
    color: '#000000',
    companions: const [],
  );
}
