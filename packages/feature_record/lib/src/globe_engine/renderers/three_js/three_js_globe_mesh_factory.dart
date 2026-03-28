import 'dart:math' as math;

import 'package:three_js/three_js.dart' as three;
import 'package:vector_math/vector_math_64.dart' as vm;

import '../../../globe/domain/entities/record_globe_country.dart';
import '../../../globe/domain/entities/record_globe_scene_spec.dart';

class ThreeJsGlobeMeshFactory {
  const ThreeJsGlobeMeshFactory._();

  static three.Mesh buildEarthMesh({
    required double radius,
    required int segments,
    required RecordGlobeStyle style,
    required three.Texture? baseTexture,
  }) {
    final material = three.MeshBasicMaterial.fromMap({
      'map': baseTexture,
      'color': style == RecordGlobeStyle.dark ? 0xe2e8f0 : 0xffffff,
    });
    return three.Mesh(
      three.SphereGeometry(radius, segments, segments),
      material,
    );
  }

  static three.Mesh buildBorderMesh({
    required double radius,
    required int segments,
    required RecordGlobeStyle style,
    required three.Texture? borderTexture,
  }) {
    final material = three.MeshBasicMaterial.fromMap({
      'map': borderTexture,
      'transparent': true,
      'opacity': style == RecordGlobeStyle.dark ? 0.52 : 0.34,
      'side': three.DoubleSide,
      'depthWrite': false,
    });
    return three.Mesh(
      three.SphereGeometry(radius * 1.002, segments, segments),
      material,
    );
  }

  static three.Mesh buildAtmosphereMesh({
    required double radius,
    required RecordGlobeStyle style,
  }) {
    final material = three.MeshBasicMaterial.fromMap({
      'color': style == RecordGlobeStyle.dark ? 0x60a5fa : 0x93c5fd,
      'transparent': true,
      'opacity': style == RecordGlobeStyle.dark ? 0.16 : 0.10,
      'side': three.DoubleSide,
      'depthWrite': false,
    });
    return three.Mesh(
      three.SphereGeometry(radius * 1.08, 48, 32),
      material,
    );
  }

  static three.Mesh buildMarkerMesh({
    required RecordGlobeCountry country,
    required RecordGlobeStyle style,
    required double altitude,
    required int segments,
  }) {
    final point = latLngToUnitVector(
      country.anchorLatitude,
      country.anchorLongitude,
    );
    final radius = (0.028 + country.activityLevel * 0.01).toDouble();
    final baseColor = switch (country.signal) {
      RecordGlobeCountrySignal.planned => 0xfbbf24,
      RecordGlobeCountrySignal.visited => 0x0f172a,
      RecordGlobeCountrySignal.neutral => 0x64748b,
    };
    final emissiveColor = switch (country.signal) {
      RecordGlobeCountrySignal.planned => 0xfde68a,
      RecordGlobeCountrySignal.visited =>
        country.hasRecentVisit ? 0x93c5fd : 0xffffff,
      RecordGlobeCountrySignal.neutral => 0xcbd5e1,
    };

    final material = three.MeshPhongMaterial.fromMap({
      'color': style == RecordGlobeStyle.dark ? 0xf8fafc : baseColor,
      'emissive': style == RecordGlobeStyle.dark ? 0x60a5fa : emissiveColor,
      'emissiveIntensity': style == RecordGlobeStyle.dark
          ? (country.hasRecentVisit ? 0.34 : 0.22)
          : (country.hasRecentVisit ? 0.18 : 0.08),
      'transparent': true,
      'opacity':
          country.signal == RecordGlobeCountrySignal.planned ? 0.82 : 0.96,
    });

    final mesh = three.Mesh(
      three.SphereGeometry(radius, segments, segments),
      material,
    );
    mesh.position.setValues(
      point.x * altitude,
      point.y * altitude,
      point.z * altitude,
    );
    mesh.userData['countryCode'] = country.code;
    return mesh;
  }

  static void applyMarkerSelection({
    required RecordGlobeCountry country,
    required three.Mesh mesh,
    required RecordGlobeStyle style,
    required bool isSelected,
  }) {
    final material = mesh.material as three.MeshPhongMaterial;
    final unselectedColor = switch (country.signal) {
      RecordGlobeCountrySignal.planned => 0xf59e0b,
      RecordGlobeCountrySignal.visited =>
        (style == RecordGlobeStyle.dark ? 0xf8fafc : 0x0f172a),
      RecordGlobeCountrySignal.neutral => 0x94a3b8,
    };
    final unselectedEmissive = switch (country.signal) {
      RecordGlobeCountrySignal.planned => 0xfcd34d,
      RecordGlobeCountrySignal.visited => (style == RecordGlobeStyle.dark
          ? 0x60a5fa
          : (country.hasRecentVisit ? 0x93c5fd : 0xffffff)),
      RecordGlobeCountrySignal.neutral => 0xe2e8f0,
    };

    material.color.setFrom(
      three.Color.fromHex32(
        isSelected
            ? (style == RecordGlobeStyle.dark ? 0xf59e0b : 0x2563eb)
            : unselectedColor,
      ),
    );
    material.emissive?.setFrom(
      three.Color.fromHex32(
        isSelected
            ? (style == RecordGlobeStyle.dark ? 0xfdba74 : 0xbfdbfe)
            : unselectedEmissive,
      ),
    );
    material.emissiveIntensity = isSelected
        ? (style == RecordGlobeStyle.dark ? 0.7 : 0.28)
        : (style == RecordGlobeStyle.dark
            ? (country.hasRecentVisit ? 0.34 : 0.22)
            : (country.hasRecentVisit ? 0.18 : 0.08));
    material.opacity =
        country.signal == RecordGlobeCountrySignal.planned ? 0.82 : 0.96;
    material.needsUpdate = true;

    final scale = isSelected ? 1.55 : 1.0;
    mesh.scale.setValues(scale, scale, scale);
  }

  static vm.Vector3 latLngToUnitVector(double latitude, double longitude) {
    final lat = vm.radians(latitude);
    final lng = vm.radians(longitude);
    return vm.Vector3(
      math.cos(lat) * math.sin(lng),
      math.sin(lat),
      math.cos(lat) * math.cos(lng),
    );
  }
}
