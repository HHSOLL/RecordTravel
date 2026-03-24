import '../record_globe_camera_state.dart';
import 'camera_controller.dart';

class RecordGlobeGestureController {
  const RecordGlobeGestureController({
    RecordGlobeCameraController cameraController =
        const RecordGlobeCameraController(),
  }) : _cameraController = cameraController;

  final RecordGlobeCameraController _cameraController;

  RecordGlobeCameraState drag(
    RecordGlobeCameraState camera, {
    required double deltaX,
    required double deltaY,
  }) {
    return _cameraController.rotateBy(
      camera,
      deltaYaw: -deltaX * 0.008,
      deltaPitch: -deltaY * 0.008,
    );
  }

  RecordGlobeCameraState fling(
    RecordGlobeCameraState camera, {
    required double velocityX,
    required double velocityY,
  }) {
    return _cameraController.focusOn(
      camera,
      yaw: camera.yaw - velocityX * 0.0004,
      pitch: camera.pitch - velocityY * 0.0004,
      zoom: camera.zoom,
    );
  }
}
