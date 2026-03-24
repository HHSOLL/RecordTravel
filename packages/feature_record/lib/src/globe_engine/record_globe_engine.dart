import 'package:flutter/material.dart';

import 'record_globe_engine_config.dart';
import 'record_globe_engine_controller.dart';
import 'record_globe_engine_state.dart';

abstract class RecordGlobeEngine {
  const RecordGlobeEngine();

  RecordGlobeRendererKind get rendererKind;

  Widget buildStage(
    BuildContext context, {
    required RecordGlobeEngineConfig config,
    required RecordGlobeEngineController controller,
    required RecordGlobeEngineState state,
    ValueChanged<String?>? onCountrySelected,
    ValueChanged<String?>? onCountryFocused,
  });
}
