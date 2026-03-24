import 'package:flutter/foundation.dart';

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

  void setScene(RecordGlobeViewState nextState) {
    _state = nextState;
    notifyListeners();
  }

  void markReady({bool isReady = true}) {
    _state = _state.copyWith(isReady: isReady, isLoading: !isReady);
    notifyListeners();
  }

  void selectCountry(String? countryCode) {
    _state = _selectCountryUseCase(
      _state,
      selectedCountryCode: countryCode,
    );
    notifyListeners();
  }

  void focusCountry(String? countryCode) {
    _state = _focusCountryUseCase(
      _state,
      focusedCountryCode: countryCode,
    );
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    _state = _state.copyWith(searchQuery: query);
    notifyListeners();
  }

  void openSheet() {
    _state = _state.copyWith(isSheetOpen: true);
    notifyListeners();
  }

  void closeSheet() {
    _state = _state.copyWith(isSheetOpen: false);
    notifyListeners();
  }

  void setError(String? message) {
    _state = _state.copyWith(errorMessage: message, isLoading: false);
    notifyListeners();
  }
}
