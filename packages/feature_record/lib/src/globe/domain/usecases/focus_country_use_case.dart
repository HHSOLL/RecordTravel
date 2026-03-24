import '../../presentation/globe_view_state.dart';

abstract class FocusCountryUseCase {
  RecordGlobeViewState call(
    RecordGlobeViewState current, {
    required String? focusedCountryCode,
  });
}

class DefaultFocusCountryUseCase implements FocusCountryUseCase {
  const DefaultFocusCountryUseCase();

  @override
  RecordGlobeViewState call(
    RecordGlobeViewState current, {
    required String? focusedCountryCode,
  }) {
    final scene = current.sceneSpec;
    return current.copyWith(
      focusedCountryCode: focusedCountryCode,
      sceneSpec: scene?.copyWith(focusedCountryCode: focusedCountryCode),
    );
  }
}
