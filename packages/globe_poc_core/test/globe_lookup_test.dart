import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:globe_poc_core/globe_poc_core.dart';

void main() {
  test('country texture lookup matches known geographic coordinates', () {
    final fixture = GlobeFixtureFactory.buildDefault();
    final samples = <({String code, double lat, double lon})>[
      (code: 'C01', lat: -60, lon: -150),
      (code: 'C04', lat: -60, lon: 30),
      (code: 'C08', lat: -20, lon: -90),
      (code: 'C12', lat: -20, lon: 150),
      (code: 'C15', lat: 20, lon: -30),
      (code: 'C24', lat: 60, lon: 150),
    ];

    for (final sample in samples) {
      final expected = fixture.countries.firstWhere(
        (country) => country.code == sample.code,
      );
      final index = GlobeMath.lookupCountryIndexFromLatLon(
        textureBundle: fixture.textureBundle,
        latitude: sample.lat,
        longitude: sample.lon,
      );
      expect(index, expected.index, reason: sample.code);
    }
  });

  test('visible country centers survive screen lookup round-trip', () {
    final fixture = GlobeFixtureFactory.buildDefault();
    const pose = GlobeCameraPose(
      yaw: 0.5,
      pitch: 0.45,
      radius: 3.1,
      fieldOfView: 38,
    );
    const viewport = Size(1440, 960);

    int total = 0;
    int correct = 0;
    for (final country in fixture.countries) {
      final world = GlobeMath.latLonToVector3(
        latitude: country.centerLat,
        longitude: country.centerLon,
      );
      if (!GlobeMath.isSurfacePointVisible(world: world, pose: pose)) {
        continue;
      }
      final screen = GlobeMath.projectToScreen(
        world: world,
        viewport: viewport,
        pose: pose,
      );
      expect(screen, isNotNull, reason: country.code);
      total += 1;
      final index = GlobeMath.lookupCountryIndexFromScreen(
        textureBundle: fixture.textureBundle,
        screenPoint: screen!,
        viewport: viewport,
        pose: pose,
      );
      if (index == country.index) {
        correct += 1;
      }
    }

    expect(total, greaterThan(0));
    expect(correct, total);
  });

  test('screen lookup returns null instead of producing NaN on invalid viewport', () {
    final fixture = GlobeFixtureFactory.buildDefault();
    const pose = GlobeCameraPose(
      yaw: 0.5,
      pitch: 0.45,
      radius: 3.1,
      fieldOfView: 38,
    );

    final index = GlobeMath.lookupCountryIndexFromScreen(
      textureBundle: fixture.textureBundle,
      screenPoint: const Offset(100, 100),
      viewport: Size.zero,
      pose: pose,
    );

    expect(index, isNull);
  });

  test('screen round-trip remains finite for visible countries', () {
    final fixture = GlobeFixtureFactory.buildDefault();
    const pose = GlobeCameraPose(
      yaw: 0.5,
      pitch: 0.45,
      radius: 3.1,
      fieldOfView: 38,
    );
    const viewport = Size(1080, 1920);

    for (final country in fixture.countries) {
      final world = GlobeMath.latLonToVector3(
        latitude: country.centerLat,
        longitude: country.centerLon,
      );
      if (!GlobeMath.isSurfacePointVisible(world: world, pose: pose)) {
        continue;
      }
      final screen = GlobeMath.projectToScreen(
        world: world,
        viewport: viewport,
        pose: pose,
      );
      if (screen == null) {
        continue;
      }
      expect(screen.dx.isFinite, isTrue, reason: country.code);
      expect(screen.dy.isFinite, isTrue, reason: country.code);
      final latLon = GlobeMath.screenToLatLon(
        screenPoint: screen,
        viewport: viewport,
        pose: pose,
      );
      expect(latLon, isNotNull, reason: country.code);
      expect(latLon!.latitude.isFinite, isTrue, reason: country.code);
      expect(latLon.longitude.isFinite, isTrue, reason: country.code);
    }
  });
}
