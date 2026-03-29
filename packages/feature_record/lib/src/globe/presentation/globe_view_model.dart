import 'package:flutter/foundation.dart';

import '../domain/entities/record_globe_scene_spec.dart';
import '../domain/usecases/focus_country_use_case.dart';
import '../domain/usecases/select_country_use_case.dart';
import 'globe_view_state.dart';

class RecordGlobeViewModel extends ChangeNotifier {
  RecordGlobeViewModel({
    SelectCountryUseCase selectCountryUseCase =
        const DefaultSelectCountryUseCase(),
    FocusCountryUseCase focusCountryUseCase =
        const DefaultFocusCountryUseCase(),
  })  : _selectCountryUseCase = selectCountryUseCase,
        _focusCountryUseCase = focusCountryUseCase;

  final SelectCountryUseCase _selectCountryUseCase;
  final FocusCountryUseCase _focusCountryUseCase;

  RecordGlobeViewState _state = RecordGlobeViewState.initial();

  RecordGlobeViewState get state => _state;

  void syncScene(RecordGlobeSceneSpec sceneSpec) {
    final selectedCountryCode = _resolveCountryCode(
      requested: _state.selectedCountryCode ?? sceneSpec.selectedCountryCode,
      fallback: null,
      sceneSpec: sceneSpec,
    );
    final focusedCountryCode = _resolveCountryCode(
      requested: _state.focusedCountryCode ?? sceneSpec.focusedCountryCode,
      fallback: selectedCountryCode ?? sceneSpec.initialCountryCode,
      sceneSpec: sceneSpec,
    );

    _state = _state.copyWith(
      sceneSpec: sceneSpec.copyWith(
        selectedCountryCode: selectedCountryCode,
        focusedCountryCode: focusedCountryCode,
      ),
      selectedCountryCode: selectedCountryCode,
      focusedCountryCode: focusedCountryCode,
      isSheetOpen: selectedCountryCode != null && _state.isSheetOpen,
      phase: selectedCountryCode == null
          ? RecordGlobeInteractionPhase.idle
          : (_state.isSheetOpen
              ? RecordGlobeInteractionPhase.countryPinned
              : RecordGlobeInteractionPhase.countryFocused),
    );
    notifyListeners();
  }

  String? _resolveCountryCode({
    required String? requested,
    required String? fallback,
    required RecordGlobeSceneSpec sceneSpec,
  }) {
    if (requested == null) {
      return fallback;
    }
    for (final country in sceneSpec.countries) {
      if (country.code == requested) {
        return requested;
      }
    }
    return fallback;
  }

  RecordGlobeTapAction tapCountry(String countryCode) {
    if (_state.selectedCountryCode == countryCode &&
        _state.phase != RecordGlobeInteractionPhase.idle) {
      _state = _state.copyWith(
        isSheetOpen: false,
        phase: RecordGlobeInteractionPhase.countryEntered,
      );
      notifyListeners();
      return RecordGlobeTapAction.enterCountry;
    }

    final selectedState = _selectCountryUseCase(
      _state,
      selectedCountryCode: countryCode,
    );
    _state = _focusCountryUseCase(
      selectedState,
      focusedCountryCode: countryCode,
    ).copyWith(
      isSheetOpen: false,
      phase: RecordGlobeInteractionPhase.countryFocused,
    );
    notifyListeners();
    return RecordGlobeTapAction.previewCountry;
  }

  void pinFocusedCountry() {
    if (_state.selectedCountryCode == null) {
      return;
    }
    _state = _state.copyWith(
      isSheetOpen: true,
      phase: RecordGlobeInteractionPhase.countryPinned,
    );
    notifyListeners();
  }

  void markCountryEntered(String countryCode) {
    if (_state.selectedCountryCode != countryCode) {
      final selectedState = _selectCountryUseCase(
        _state,
        selectedCountryCode: countryCode,
      );
      _state = _focusCountryUseCase(
        selectedState,
        focusedCountryCode: countryCode,
      ).copyWith(
        isSheetOpen: false,
        phase: RecordGlobeInteractionPhase.countryEntered,
      );
      notifyListeners();
      return;
    }

    _state = _state.copyWith(phase: RecordGlobeInteractionPhase.countryEntered);
    notifyListeners();
  }

  void clearSelection() {
    final clearedSelection = _selectCountryUseCase(
      _state,
      selectedCountryCode: null,
    );
    _state = _focusCountryUseCase(
      clearedSelection,
      focusedCountryCode: null,
    ).copyWith(
      isSheetOpen: false,
      phase: RecordGlobeInteractionPhase.idle,
    );
    notifyListeners();
  }
}
