import 'package:flutter/foundation.dart';

const _unsetCameraValue = Object();

@immutable
class RecordGlobeCameraState {
  const RecordGlobeCameraState({
    required this.yaw,
    required this.pitch,
    required this.zoom,
    this.targetYaw,
    this.targetPitch,
    this.targetZoom,
  });

  final double yaw;
  final double pitch;
  final double zoom;
  final double? targetYaw;
  final double? targetPitch;
  final double? targetZoom;

  factory RecordGlobeCameraState.idle({
    double yaw = 0,
    double pitch = 0,
    double zoom = 1,
  }) {
    return RecordGlobeCameraState(yaw: yaw, pitch: pitch, zoom: zoom);
  }

  RecordGlobeCameraState copyWith({
    double? yaw,
    double? pitch,
    double? zoom,
    Object? targetYaw = _unsetCameraValue,
    Object? targetPitch = _unsetCameraValue,
    Object? targetZoom = _unsetCameraValue,
  }) {
    return RecordGlobeCameraState(
      yaw: yaw ?? this.yaw,
      pitch: pitch ?? this.pitch,
      zoom: zoom ?? this.zoom,
      targetYaw: identical(targetYaw, _unsetCameraValue)
          ? this.targetYaw
          : targetYaw as double?,
      targetPitch: identical(targetPitch, _unsetCameraValue)
          ? this.targetPitch
          : targetPitch as double?,
      targetZoom: identical(targetZoom, _unsetCameraValue)
          ? this.targetZoom
          : targetZoom as double?,
    );
  }
}
