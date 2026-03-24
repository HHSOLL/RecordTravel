import 'package:flutter/foundation.dart';

import 'record_globe_engine_state.dart';

class RecordGlobeEngineController extends ChangeNotifier {
  RecordGlobeEngineController({
    RecordGlobeEngineState? initialState,
  }) : _state = initialState ?? RecordGlobeEngineState.initial();

  RecordGlobeEngineState _state;

  RecordGlobeEngineState get state => _state;

  void setReady(bool isReady) {
    _state = _state.copyWith(isReady: isReady);
    notifyListeners();
  }

  void setCamera(RecordGlobeCameraState camera) {
    _state = _state.copyWith(camera: camera);
    notifyListeners();
  }

  void selectCountry(String? countryCode) {
    _state = _state.copyWith(selectedCountryCode: countryCode);
    notifyListeners();
  }

  void hoverCountry(String? countryCode) {
    _state = _state.copyWith(hoveredCountryCode: countryCode);
    notifyListeners();
  }

  void setError(String? message) {
    _state = _state.copyWith(errorMessage: message);
    notifyListeners();
  }
}
