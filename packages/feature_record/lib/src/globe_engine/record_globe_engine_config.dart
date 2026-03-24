import 'package:flutter/foundation.dart';

import '../globe/domain/entities/record_globe_scene_spec.dart';

@immutable
class RecordGlobeEngineConfig {
  const RecordGlobeEngineConfig({
    required this.style,
    required this.scene,
  });

  final RecordGlobeStyle style;
  final RecordGlobeSceneSpec? scene;

  factory RecordGlobeEngineConfig.fromScene({
    required RecordGlobeSceneSpec? scene,
  }) {
    final style = scene?.style ?? RecordGlobeStyle.dark;
    return RecordGlobeEngineConfig(
      style: style,
      scene: scene,
    );
  }
}
