import 'package:flutter/material.dart';

import '../../../globe_engine/record_globe_engine.dart';
import '../globe_view_state.dart';
import 'record_globe_stage.dart';

class RecordGlobeViewport extends StatelessWidget {
  const RecordGlobeViewport({
    super.key,
    required this.engine,
    required this.state,
    this.size,
    this.onCountrySelected,
    this.loadingBuilder,
  });

  final RecordGlobeEngine engine;
  final RecordGlobeViewState state;
  final double? size;
  final ValueChanged<String?>? onCountrySelected;
  final Widget Function(BuildContext context)? loadingBuilder;

  @override
  Widget build(BuildContext context) {
    final sceneSpec = state.sceneSpec;
    if (sceneSpec == null && loadingBuilder != null) {
      return loadingBuilder!(context);
    }
    if (sceneSpec == null) {
      return SizedBox.square(dimension: size);
    }
    return SizedBox.square(
      dimension: size,
      child: RecordGlobeStage(
        engine: engine,
        sceneSpec: sceneSpec,
        onCountrySelected: onCountrySelected,
      ),
    );
  }
}
