import '../record_globe_engine_state.dart';

class RecordGlobeGestureController {
  const RecordGlobeGestureController();

  RecordGlobeCameraState drag(
    RecordGlobeCameraState camera, {
    required double deltaX,
    required double deltaY,
  }) {
    return camera.copyWith(
      yaw: camera.yaw - deltaX * 0.008,
      pitch: camera.pitch - deltaY * 0.008,
    );
  }

  RecordGlobeCameraState fling(
    RecordGlobeCameraState camera, {
    required double velocityX,
    required double velocityY,
  }) {
    return camera.copyWith(
      targetYaw: camera.yaw - velocityX * 0.0004,
      targetPitch: (camera.pitch - velocityY * 0.0004).clamp(-1.45, 1.45),
    );
  }
}
