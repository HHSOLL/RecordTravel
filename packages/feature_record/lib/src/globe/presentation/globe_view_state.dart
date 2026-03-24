import 'package:flutter/foundation.dart';

import '../domain/entities/record_globe_scene_spec.dart';

const _unsetRecordGlobeValue = Object();

enum RecordGlobeInteractionPhase {
  idle,
  countryFocused,
  countryPinned,
  countryEntered,
}

enum RecordGlobeTapAction {
  previewCountry,
  enterCountry,
  clearSelection,
}

@immutable
class RecordGlobeViewState {
  const RecordGlobeViewState({
    this.sceneSpec,
    this.selectedCountryCode,
    this.focusedCountryCode,
    this.isSheetOpen = false,
    this.phase = RecordGlobeInteractionPhase.idle,
  });

  final RecordGlobeSceneSpec? sceneSpec;
  final String? selectedCountryCode;
  final String? focusedCountryCode;
  final bool isSheetOpen;
  final RecordGlobeInteractionPhase phase;

  factory RecordGlobeViewState.initial() {
    return const RecordGlobeViewState();
  }

  RecordGlobeViewState copyWith({
    Object? sceneSpec = _unsetRecordGlobeValue,
    Object? selectedCountryCode = _unsetRecordGlobeValue,
    Object? focusedCountryCode = _unsetRecordGlobeValue,
    bool? isSheetOpen,
    RecordGlobeInteractionPhase? phase,
  }) {
    return RecordGlobeViewState(
      sceneSpec: identical(sceneSpec, _unsetRecordGlobeValue)
          ? this.sceneSpec
          : sceneSpec as RecordGlobeSceneSpec?,
      selectedCountryCode: identical(
        selectedCountryCode,
        _unsetRecordGlobeValue,
      )
          ? this.selectedCountryCode
          : selectedCountryCode as String?,
      focusedCountryCode: identical(
        focusedCountryCode,
        _unsetRecordGlobeValue,
      )
          ? this.focusedCountryCode
          : focusedCountryCode as String?,
      isSheetOpen: isSheetOpen ?? this.isSheetOpen,
      phase: phase ?? this.phase,
    );
  }
}
