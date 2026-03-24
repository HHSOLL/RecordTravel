import '../record_globe_engine_state.dart';

class RecordGlobeCameraController {
  const RecordGlobeCameraController();

  static const double _minPitch = -1.45;
  static const double _maxPitch = 1.45;

  double _clampPitch(double pitch) {
    return pitch.clamp(_minPitch, _maxPitch).toDouble();
  }

  double _wrapAngle(double value) {
    while (value > 3.141592653589793) {
      value -= 6.283185307179586;
    }
    while (value < -3.141592653589793) {
      value += 6.283185307179586;
    }
    return value;
  }

  RecordGlobeCameraState rotateBy(
    RecordGlobeCameraState camera, {
    required double deltaYaw,
    required double deltaPitch,
  }) {
    return camera.copyWith(
      yaw: _wrapAngle(camera.yaw + deltaYaw),
      pitch: _clampPitch(camera.pitch + deltaPitch),
      targetYaw: camera.targetYaw,
      targetPitch: camera.targetPitch,
    );
  }

  RecordGlobeCameraState zoomBy(
    RecordGlobeCameraState camera, {
    required double deltaZoom,
    double minZoom = 0.7,
    double maxZoom = 2.2,
  }) {
    final nextZoom = (camera.zoom + deltaZoom).clamp(minZoom, maxZoom);
    return camera.copyWith(zoom: nextZoom.toDouble(), targetZoom: nextZoom.toDouble());
  }

  RecordGlobeCameraState focusOn(
    RecordGlobeCameraState camera, {
    required double yaw,
    required double pitch,
    double? zoom,
  }) {
    return camera.copyWith(
      targetYaw: _wrapAngle(yaw),
      targetPitch: _clampPitch(pitch),
      targetZoom: zoom ?? camera.zoom,
    );
  }
}
