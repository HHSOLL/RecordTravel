import 'package:flutter/foundation.dart';

import '../globe/domain/entities/record_globe_asset_set.dart';
import '../globe/domain/entities/record_globe_scene_spec.dart';

@immutable
class RecordGlobeEngineConfig {
  const RecordGlobeEngineConfig({
    required this.style,
    required this.scene,
    required this.assetSet,
  });

  final RecordGlobeStyle style;
  final RecordGlobeSceneSpec? scene;
  final RecordGlobeAssetSet? assetSet;

  factory RecordGlobeEngineConfig.fromScene({
    required RecordGlobeSceneSpec? scene,
    required RecordGlobeAssetSet? assetSet,
  }) {
    final style = scene?.style ?? RecordGlobeStyle.dark;
    return RecordGlobeEngineConfig(
      style: style,
      scene: scene,
      assetSet: assetSet,
    );
  }
}
