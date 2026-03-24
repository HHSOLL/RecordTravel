import 'package:flutter/material.dart';

import '../../../globe_engine/record_globe_engine.dart';
import '../../../globe_engine/record_globe_engine_controller.dart';
import '../../presentation/globe_view_model.dart';
import 'record_globe_stage.dart';

class RecordGlobeViewport extends StatelessWidget {
  const RecordGlobeViewport({
    super.key,
    required this.engine,
    required this.engineController,
    required this.viewModel,
    this.size,
    this.onCountrySelected,
    this.onCountryFocused,
    this.overlayBuilder,
    this.loadingBuilder,
    this.errorBuilder,
  });

  final RecordGlobeEngine engine;
  final RecordGlobeEngineController engineController;
  final RecordGlobeViewModel viewModel;
  final double? size;
  final ValueChanged<String?>? onCountrySelected;
  final ValueChanged<String?>? onCountryFocused;
  final Widget Function(BuildContext context, RecordGlobeViewModel viewModel)?
      overlayBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context, String message)? errorBuilder;

  @override
  Widget build(BuildContext context) {
    final state = viewModel.state;
    if (state.errorMessage != null && errorBuilder != null) {
      return errorBuilder!(context, state.errorMessage!);
    }
    if (state.isLoading && loadingBuilder != null) {
      return loadingBuilder!(context);
    }
    return SizedBox.square(
      dimension: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          RecordGlobeStage(
            engine: engine,
            engineController: engineController,
            viewModel: viewModel,
            onCountrySelected: onCountrySelected,
            onCountryFocused: onCountryFocused,
          ),
          if (overlayBuilder != null) overlayBuilder!(context, viewModel),
        ],
      ),
    );
  }
}
