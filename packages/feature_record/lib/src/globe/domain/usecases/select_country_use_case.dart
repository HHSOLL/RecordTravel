import '../../presentation/globe_view_state.dart';

abstract class SelectCountryUseCase {
  RecordGlobeViewState call(
    RecordGlobeViewState current, {
    required String? selectedCountryCode,
  });
}

class DefaultSelectCountryUseCase implements SelectCountryUseCase {
  const DefaultSelectCountryUseCase();

  @override
  RecordGlobeViewState call(
    RecordGlobeViewState current, {
    required String? selectedCountryCode,
  }) {
    final scene = current.sceneSpec;
    return current.copyWith(
      selectedCountryCode: selectedCountryCode,
      focusedCountryCode: selectedCountryCode,
      sceneSpec: scene?.copyWith(
        selectedCountryCode: selectedCountryCode,
        focusedCountryCode: selectedCountryCode,
      ),
    );
  }
}
