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
      requested: _state.selectedCountryCode,
      fallback: sceneSpec.initialCountryCode,
      sceneSpec: sceneSpec,
    );
    final focusedCountryCode = _resolveCountryCode(
      requested: _state.focusedCountryCode,
      fallback: selectedCountryCode,
      sceneSpec: sceneSpec,
    );
    final isInitialSync = _state.sceneSpec == null;

    _state = _state.copyWith(
      sceneSpec: sceneSpec.copyWith(
        selectedCountryCode: selectedCountryCode,
        focusedCountryCode: focusedCountryCode,
      ),
      selectedCountryCode: selectedCountryCode,
      focusedCountryCode: focusedCountryCode,
      isSheetOpen:
          selectedCountryCode != null && (isInitialSync || _state.isSheetOpen),
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

  void activateCountry(String countryCode) {
    final selectedState = _selectCountryUseCase(
      _state,
      selectedCountryCode: countryCode,
    );
    _state = _focusCountryUseCase(
      selectedState,
      focusedCountryCode: countryCode,
    ).copyWith(isSheetOpen: true);
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
    ).copyWith(isSheetOpen: false);
    notifyListeners();
  }
}
