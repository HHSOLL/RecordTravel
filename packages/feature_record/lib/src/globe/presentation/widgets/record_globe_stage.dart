import 'package:flutter/material.dart';

import '../../../globe_engine/record_globe_engine.dart';
import '../../../globe_engine/record_globe_engine_controller.dart';
import '../../../globe_engine/record_globe_engine_config.dart';
import '../../presentation/globe_view_model.dart';

class RecordGlobeStage extends StatelessWidget {
  const RecordGlobeStage({
    super.key,
    required this.engine,
    required this.engineController,
    required this.viewModel,
    this.onCountrySelected,
    this.onCountryFocused,
  });

  final RecordGlobeEngine engine;
  final RecordGlobeEngineController engineController;
  final RecordGlobeViewModel viewModel;
  final ValueChanged<String?>? onCountrySelected;
  final ValueChanged<String?>? onCountryFocused;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, child) {
        final viewState = viewModel.state;
        final engineState = engineController.state;
        final config = RecordGlobeEngineConfig.fromScene(
          scene: viewState.sceneSpec,
        );
        return engine.buildStage(
          context,
          config: config,
          controller: engineController,
          state: engineState,
          onCountrySelected: (countryCode) {
            viewModel.selectCountry(countryCode);
            onCountrySelected?.call(countryCode);
          },
          onCountryFocused: (countryCode) {
            viewModel.focusCountry(countryCode);
            onCountryFocused?.call(countryCode);
          },
        );
      },
    );
  }
}
