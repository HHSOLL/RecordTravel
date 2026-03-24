import 'package:flutter/foundation.dart';

import '../globe/domain/entities/record_globe_scene_spec.dart';

enum RecordGlobeRendererKind {
  threeJs,
}

@immutable
class RecordGlobeEngineConfig {
  const RecordGlobeEngineConfig({
    required this.rendererKind,
    required this.style,
    required this.scene,
  });

  final RecordGlobeRendererKind rendererKind;
  final RecordGlobeStyle style;
  final RecordGlobeSceneSpec? scene;

  factory RecordGlobeEngineConfig.fromScene({
    required RecordGlobeSceneSpec? scene,
  }) {
    final style = scene?.style ?? RecordGlobeStyle.dark;
    return RecordGlobeEngineConfig(
      rendererKind: RecordGlobeRendererKind.threeJs,
      style: style,
      scene: scene,
    );
  }
}
