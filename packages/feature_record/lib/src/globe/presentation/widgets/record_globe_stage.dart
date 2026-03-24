import 'package:flutter/material.dart';

import '../../domain/entities/record_globe_scene_spec.dart';
import '../../../globe_engine/record_globe_engine.dart';
import '../../../globe_engine/record_globe_engine_config.dart';

class RecordGlobeStage extends StatelessWidget {
  const RecordGlobeStage({
    super.key,
    required this.engine,
    required this.sceneSpec,
    this.onCountrySelected,
  });

  final RecordGlobeEngine engine;
  final RecordGlobeSceneSpec? sceneSpec;
  final ValueChanged<String?>? onCountrySelected;

  @override
  Widget build(BuildContext context) {
    final config = RecordGlobeEngineConfig.fromScene(scene: sceneSpec);
    return engine.buildStage(
      context,
      config: config,
      onCountrySelected: onCountrySelected,
    );
  }
}
