import 'package:feature_record/src/globe/domain/entities/record_globe_country.dart';
import 'package:feature_record/src/globe/domain/entities/record_globe_scene_spec.dart';
import 'package:feature_record/src/globe/presentation/globe_view_model.dart';
import 'package:feature_record/src/globe/presentation/globe_view_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RecordGlobeViewModel', () {
    test('transitions from preview to pinned to entered', () {
      final viewModel = RecordGlobeViewModel();

      viewModel.syncScene(
        RecordGlobeSceneSpec(
          style: RecordGlobeStyle.light,
          countries: const [
            RecordGlobeCountry(
              code: 'FR',
              name: 'France',
              anchorLatitude: 46.2276,
              anchorLongitude: 2.2137,
              continent: 'Europe',
            ),
            RecordGlobeCountry(
              code: 'AU',
              name: 'Australia',
              anchorLatitude: -25.2744,
              anchorLongitude: 133.7751,
              continent: 'Oceania',
            ),
          ],
        ),
      );

      expect(viewModel.state.phase, RecordGlobeInteractionPhase.idle);
      expect(viewModel.state.selectedCountryCode, isNull);

      final previewAction = viewModel.tapCountry('FR');
      expect(previewAction, RecordGlobeTapAction.previewCountry);
      expect(viewModel.state.selectedCountryCode, 'FR');
      expect(viewModel.state.focusedCountryCode, 'FR');
      expect(viewModel.state.isSheetOpen, isFalse);
      expect(
        viewModel.state.phase,
        RecordGlobeInteractionPhase.countryFocused,
      );

      viewModel.pinFocusedCountry();
      expect(viewModel.state.isSheetOpen, isTrue);
      expect(
        viewModel.state.phase,
        RecordGlobeInteractionPhase.countryPinned,
      );

      final enterAction = viewModel.tapCountry('FR');
      expect(enterAction, RecordGlobeTapAction.enterCountry);
      expect(
        viewModel.state.phase,
        RecordGlobeInteractionPhase.countryEntered,
      );
    });

    test('can switch focus and clear selection', () {
      final viewModel = RecordGlobeViewModel();

      viewModel.syncScene(
        RecordGlobeSceneSpec(
          style: RecordGlobeStyle.dark,
          countries: const [
            RecordGlobeCountry(
              code: 'FR',
              name: 'France',
              anchorLatitude: 46.2276,
              anchorLongitude: 2.2137,
              continent: 'Europe',
            ),
            RecordGlobeCountry(
              code: 'AU',
              name: 'Australia',
              anchorLatitude: -25.2744,
              anchorLongitude: 133.7751,
              continent: 'Oceania',
            ),
          ],
          initialCountryCode: 'FR',
        ),
      );

      expect(viewModel.state.selectedCountryCode, isNull);
      expect(viewModel.state.focusedCountryCode, 'FR');
      expect(viewModel.state.isSheetOpen, isFalse);

      final previewAction = viewModel.tapCountry('AU');
      expect(previewAction, RecordGlobeTapAction.previewCountry);
      expect(viewModel.state.selectedCountryCode, 'AU');
      expect(viewModel.state.focusedCountryCode, 'AU');
      expect(viewModel.state.isSheetOpen, isFalse);

      viewModel.clearSelection();
      expect(viewModel.state.selectedCountryCode, isNull);
      expect(viewModel.state.focusedCountryCode, isNull);
      expect(viewModel.state.isSheetOpen, isFalse);
      expect(viewModel.state.phase, RecordGlobeInteractionPhase.idle);
    });
  });
}
