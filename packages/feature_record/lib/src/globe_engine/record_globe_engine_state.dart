import 'package:flutter/foundation.dart';

const _unsetEngineValue = Object();

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
    Object? targetYaw = _unsetEngineValue,
    Object? targetPitch = _unsetEngineValue,
    Object? targetZoom = _unsetEngineValue,
  }) {
    return RecordGlobeCameraState(
      yaw: yaw ?? this.yaw,
      pitch: pitch ?? this.pitch,
      zoom: zoom ?? this.zoom,
      targetYaw: identical(targetYaw, _unsetEngineValue)
          ? this.targetYaw
          : targetYaw as double?,
      targetPitch: identical(targetPitch, _unsetEngineValue)
          ? this.targetPitch
          : targetPitch as double?,
      targetZoom: identical(targetZoom, _unsetEngineValue)
          ? this.targetZoom
          : targetZoom as double?,
    );
  }
}

@immutable
class RecordGlobeEngineState {
  const RecordGlobeEngineState({
    required this.isReady,
    required this.camera,
    this.selectedCountryCode,
    this.hoveredCountryCode,
    this.errorMessage,
  });

  final bool isReady;
  final RecordGlobeCameraState camera;
  final String? selectedCountryCode;
  final String? hoveredCountryCode;
  final String? errorMessage;

  factory RecordGlobeEngineState.initial() {
    return RecordGlobeEngineState(
      isReady: false,
      camera: RecordGlobeCameraState.idle(),
    );
  }

  RecordGlobeEngineState copyWith({
    bool? isReady,
    RecordGlobeCameraState? camera,
    Object? selectedCountryCode = _unsetEngineValue,
    Object? hoveredCountryCode = _unsetEngineValue,
    Object? errorMessage = _unsetEngineValue,
  }) {
    return RecordGlobeEngineState(
      isReady: isReady ?? this.isReady,
      camera: camera ?? this.camera,
      selectedCountryCode: identical(selectedCountryCode, _unsetEngineValue)
          ? this.selectedCountryCode
          : selectedCountryCode as String?,
      hoveredCountryCode: identical(hoveredCountryCode, _unsetEngineValue)
          ? this.hoveredCountryCode
          : hoveredCountryCode as String?,
      errorMessage: identical(errorMessage, _unsetEngineValue)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}
