import 'package:flutter/material.dart';

import 'record_globe_engine_config.dart';

abstract class RecordGlobeEngine {
  const RecordGlobeEngine();

  Widget buildStage(
    BuildContext context, {
    required RecordGlobeEngineConfig config,
    ValueChanged<String?>? onCountrySelected,
  });
}
