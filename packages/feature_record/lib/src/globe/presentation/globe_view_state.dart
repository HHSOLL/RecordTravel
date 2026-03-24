import 'package:flutter/foundation.dart';

import '../domain/entities/record_globe_scene_spec.dart';

const _unsetRecordGlobeValue = Object();

@immutable
class RecordGlobeViewState {
  const RecordGlobeViewState({
    required this.isLoading,
    this.sceneSpec,
    this.selectedCountryCode,
    this.focusedCountryCode,
    this.searchQuery = '',
    this.isSheetOpen = false,
    this.isReady = false,
    this.errorMessage,
  });

  final bool isLoading;
  final RecordGlobeSceneSpec? sceneSpec;
  final String? selectedCountryCode;
  final String? focusedCountryCode;
  final String searchQuery;
  final bool isSheetOpen;
  final bool isReady;
  final String? errorMessage;

  factory RecordGlobeViewState.initial() {
    return const RecordGlobeViewState(isLoading: true);
  }

  RecordGlobeViewState copyWith({
    bool? isLoading,
    RecordGlobeSceneSpec? sceneSpec,
    Object? selectedCountryCode = _unsetRecordGlobeValue,
    Object? focusedCountryCode = _unsetRecordGlobeValue,
    String? searchQuery,
    bool? isSheetOpen,
    bool? isReady,
    Object? errorMessage = _unsetRecordGlobeValue,
  }) {
    return RecordGlobeViewState(
      isLoading: isLoading ?? this.isLoading,
      sceneSpec: sceneSpec ?? this.sceneSpec,
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
      searchQuery: searchQuery ?? this.searchQuery,
      isSheetOpen: isSheetOpen ?? this.isSheetOpen,
      isReady: isReady ?? this.isReady,
      errorMessage: identical(errorMessage, _unsetRecordGlobeValue)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}
