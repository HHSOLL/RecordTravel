import 'package:core_domain/core_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('PlaceRef builds stable city key', () {
    const place = PlaceRef(countryCode: 'KR', countryName: 'South Korea', cityName: 'Seoul');
    expect(place.cityKey, 'KR:Seoul');
  });
}
