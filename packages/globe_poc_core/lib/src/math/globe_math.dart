import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vmath;

import '../models/globe_models.dart';

class GlobeMath {
  static const double earthRadius = 1.0;
  static const double _epsilon = 1e-6;

  static double degToRad(double degrees) => degrees * math.pi / 180;

  static vmath.Vector3 latLonToVector3({
    required double latitude,
    required double longitude,
    double radius = earthRadius,
  }) {
    final lat = degToRad(latitude);
    final lon = degToRad(normalizeLongitude(longitude));
    return vmath.Vector3(
      radius * math.cos(lat) * math.sin(lon),
      radius * math.sin(lat),
      radius * math.cos(lat) * math.cos(lon),
    );
  }

  static double normalizeLongitude(double longitude) {
    var normalized = longitude % 360;
    if (normalized < -180) {
      normalized += 360;
    }
    if (normalized >= 180) {
      normalized -= 360;
    }
    return normalized;
  }

  static ({double latitude, double longitude})? vector3ToLatLon(
    vmath.Vector3 point,
  ) {
    if (!_isFiniteVector3(point) || point.length2 < _epsilon) {
      return null;
    }
    final normalized = point.normalized();
    if (!_isFiniteVector3(normalized)) {
      return null;
    }
    final latitude = math.asin(normalized.y.clamp(-1.0, 1.0)) * 180 / math.pi;
    final longitude = normalizeLongitude(
      math.atan2(normalized.x, normalized.z) * 180 / math.pi,
    );
    if (!latitude.isFinite || !longitude.isFinite) {
      return null;
    }
    return (latitude: latitude, longitude: longitude);
  }

  static GlobeCameraPose clampPose(GlobeCameraPose pose) {
    final pitch = pose.pitch.isFinite ? pose.pitch : 0.0;
    final radius = pose.radius.isFinite ? pose.radius : 3.1;
    final yaw = pose.yaw.isFinite ? pose.yaw : 0.0;
    final fieldOfView = pose.fieldOfView.isFinite ? pose.fieldOfView : 38.0;
    return pose.copyWith(
      yaw: yaw,
      pitch: pitch.clamp(-math.pi / 2 + 0.1, math.pi / 2 - 0.1),
      radius: radius.clamp(1.55, 5.4),
      fieldOfView: fieldOfView.clamp(10.0, 120.0),
    );
  }

  static vmath.Vector3 cameraPosition(GlobeCameraPose pose) {
    final pitch = pose.pitch;
    final yaw = pose.yaw;
    return vmath.Vector3(
      pose.radius * math.cos(pitch) * math.sin(yaw),
      pose.radius * math.sin(pitch),
      pose.radius * math.cos(pitch) * math.cos(yaw),
    );
  }

  static vmath.Matrix4 viewMatrix(GlobeCameraPose pose) {
    final eye = cameraPosition(pose);
    return vmath.makeViewMatrix(
      eye,
      vmath.Vector3.zero(),
      vmath.Vector3(0, 1, 0),
    );
  }

  static vmath.Matrix4 projectionMatrix({
    required double aspect,
    required double fovDegrees,
    double near = 0.1,
    double far = 100.0,
  }) {
    return vmath.makePerspectiveMatrix(degToRad(fovDegrees), aspect, near, far);
  }

  static ({
    vmath.Matrix4 view,
    vmath.Matrix4 projection,
    vmath.Matrix4 viewProjection,
  })
  cameraMatrices({required GlobeCameraPose pose, required double aspect}) {
    final view = viewMatrix(pose);
    final projection = projectionMatrix(
      aspect: aspect,
      fovDegrees: pose.fieldOfView,
    );
    return (
      view: view,
      projection: projection,
      viewProjection: projection * view,
    );
  }

  static ({double u, double v}) latLonToUv({
    required double latitude,
    required double longitude,
  }) {
    final wrappedLongitude = normalizeLongitude(longitude);
    var u = (wrappedLongitude + 180) / 360;
    if (u >= 1) {
      u -= 1;
    }
    final v = ((90 - latitude) / 180).clamp(0.0, 1.0);
    return (u: u, v: v);
  }

  static int? lookupCountryIndexFromLatLon({
    required GlobeTextureBundle textureBundle,
    required double latitude,
    required double longitude,
  }) {
    if (!latitude.isFinite || !longitude.isFinite) {
      return null;
    }
    final uv = latLonToUv(latitude: latitude, longitude: longitude);
    if (!uv.u.isFinite || !uv.v.isFinite) {
      return null;
    }
    final x = (uv.u * (textureBundle.width - 1)).round().clamp(
      0,
      textureBundle.width - 1,
    );
    final y = (uv.v * (textureBundle.height - 1)).round().clamp(
      0,
      textureBundle.height - 1,
    );
    final index = (y * textureBundle.width + x) * 4;
    final countryIndex =
        textureBundle.countryIdRgba[index] +
        (textureBundle.countryIdRgba[index + 1] << 8) +
        (textureBundle.countryIdRgba[index + 2] << 16);
    return countryIndex == 0 ? null : countryIndex;
  }

  static int? lookupCountryIndexFromScreen({
    required GlobeTextureBundle textureBundle,
    required Offset screenPoint,
    required Size viewport,
    required GlobeCameraPose pose,
  }) {
    final hit = screenToLatLon(
      screenPoint: screenPoint,
      viewport: viewport,
      pose: pose,
    );
    if (hit == null) {
      return null;
    }
    return lookupCountryIndexFromLatLon(
      textureBundle: textureBundle,
      latitude: hit.latitude,
      longitude: hit.longitude,
    );
  }

  static bool isSurfacePointVisible({
    required vmath.Vector3 world,
    required GlobeCameraPose pose,
    double epsilon = 1e-6,
  }) {
    final toCamera = cameraPosition(pose) - world;
    return world.dot(toCamera) > epsilon;
  }

  static ({double latitude, double longitude})? screenToLatLon({
    required Offset screenPoint,
    required Size viewport,
    required GlobeCameraPose pose,
  }) {
    if (!_isFiniteSize(viewport) ||
        viewport.width <= _epsilon ||
        viewport.height <= _epsilon ||
        !screenPoint.dx.isFinite ||
        !screenPoint.dy.isFinite) {
      return null;
    }
    final ndcX = (2 * screenPoint.dx / viewport.width) - 1;
    final ndcY = 1 - (2 * screenPoint.dy / viewport.height);
    if (!ndcX.isFinite || !ndcY.isFinite) {
      return null;
    }
    final aspect = viewport.width / viewport.height;
    if (!aspect.isFinite || aspect <= _epsilon) {
      return null;
    }
    final matrices = cameraMatrices(pose: pose, aspect: aspect);
    final inverse = vmath.Matrix4.copy(matrices.viewProjection);
    final determinant = inverse.invert();
    if (!determinant.isFinite || determinant.abs() <= _epsilon) {
      return null;
    }
    final near = _unproject(inverse, vmath.Vector4(ndcX, ndcY, -1, 1));
    final far = _unproject(inverse, vmath.Vector4(ndcX, ndcY, 1, 1));
    if (near == null || far == null) {
      return null;
    }
    final origin = cameraPosition(pose);
    if (!_isFiniteVector3(origin)) {
      return null;
    }
    final direction = far - origin;
    if (!_isFiniteVector3(direction) || direction.length2 <= _epsilon) {
      return null;
    }
    direction.normalize();
    final hit = _intersectSphere(
      origin: origin,
      direction: direction,
      radius: earthRadius,
    );
    if (hit == null) return null;
    return vector3ToLatLon(hit);
  }

  static vmath.Vector3? _unproject(
    vmath.Matrix4 inverse,
    vmath.Vector4 clipSpace,
  ) {
    final world = inverse.transform(clipSpace);
    if (!world.w.isFinite || world.w.abs() <= _epsilon) {
      return null;
    }
    final reciprocalW = 1.0 / world.w;
    final result = vmath.Vector3(
      world.x * reciprocalW,
      world.y * reciprocalW,
      world.z * reciprocalW,
    );
    return _isFiniteVector3(result) ? result : null;
  }

  static vmath.Vector3? _intersectSphere({
    required vmath.Vector3 origin,
    required vmath.Vector3 direction,
    required double radius,
  }) {
    if (!_isFiniteVector3(origin) ||
        !_isFiniteVector3(direction) ||
        !radius.isFinite ||
        radius <= _epsilon) {
      return null;
    }
    final a = direction.dot(direction);
    if (!a.isFinite || a <= _epsilon) {
      return null;
    }
    final b = 2.0 * origin.dot(direction);
    final c = origin.dot(origin) - radius * radius;
    var discriminant = b * b - (4.0 * a * c);
    if (!discriminant.isFinite) {
      return null;
    }
    if (discriminant < 0 && discriminant.abs() <= _epsilon) {
      discriminant = 0;
    }
    if (discriminant < 0) {
      return null;
    }
    final sqrtDiscriminant = math.sqrt(discriminant);
    final denominator = 2.0 * a;
    final t0 = (-b - sqrtDiscriminant) / denominator;
    final t1 = (-b + sqrtDiscriminant) / denominator;
    final t = t0 > _epsilon ? t0 : (t1 > _epsilon ? t1 : double.nan);
    if (!t.isFinite) {
      return null;
    }
    return origin + direction.scaled(t);
  }

  static Offset? projectToScreen({
    required vmath.Vector3 world,
    required Size viewport,
    required GlobeCameraPose pose,
  }) {
    if (!_isFiniteVector3(world) ||
        !_isFiniteSize(viewport) ||
        viewport.width <= _epsilon ||
        viewport.height <= _epsilon) {
      return null;
    }
    final aspect = viewport.width / viewport.height;
    if (!aspect.isFinite || aspect <= _epsilon) {
      return null;
    }
    final matrix = cameraMatrices(pose: pose, aspect: aspect).viewProjection;
    final vector4 = matrix.transform(
      vmath.Vector4(world.x, world.y, world.z, 1),
    );
    if (!vector4.w.isFinite || vector4.w <= _epsilon) {
      return null;
    }
    final ndcX = vector4.x / vector4.w;
    final ndcY = vector4.y / vector4.w;
    if (!ndcX.isFinite || !ndcY.isFinite) {
      return null;
    }
    return Offset(
      (ndcX + 1) * 0.5 * viewport.width,
      (1 - ndcY) * 0.5 * viewport.height,
    );
  }

  static List<vmath.Vector3> buildGreatCircleArc({
    required double originLat,
    required double originLon,
    required double destinationLat,
    required double destinationLon,
    int segments = 48,
  }) {
    final v0 = latLonToVector3(latitude: originLat, longitude: originLon);
    final v1 = latLonToVector3(
      latitude: destinationLat,
      longitude: destinationLon,
    );
    final dot = v0.dot(v1).clamp(-1.0, 1.0);
    final omega = math.acos(dot);
    if (omega.abs() < 0.0001) {
      return [v0, v1];
    }
    final sinOmega = math.sin(omega);
    final altitude = 0.04 + 0.10 * math.min(1.0, omega / 1.2);
    return List<vmath.Vector3>.generate(segments + 1, (index) {
      final t = index / segments;
      final scale0 = math.sin((1 - t) * omega) / sinOmega;
      final scale1 = math.sin(t * omega) / sinOmega;
      final base = (v0.scaled(scale0) + v1.scaled(scale1))..normalize();
      final height = math.sin(math.pi * t) * altitude;
      return base.scaled(earthRadius + height);
    });
  }

  static bool _isFiniteVector3(vmath.Vector3 vector) =>
      vector.x.isFinite && vector.y.isFinite && vector.z.isFinite;

  static bool _isFiniteSize(Size size) =>
      size.width.isFinite && size.height.isFinite;
}
