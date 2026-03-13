import 'package:flutter_test/flutter_test.dart';
import 'package:globe_poc_core/globe_poc_core.dart';

void main() {
  test('fixture builds', () {
    final fixture = GlobeFixtureFactory.buildDefault();
    expect(fixture.cities.length, 1000);
    expect(fixture.routes.length, 50);
  });
}
