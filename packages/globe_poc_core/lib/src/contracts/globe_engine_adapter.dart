import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../controller/globe_poc_controller.dart';
import '../models/globe_models.dart';

abstract class GlobeEngineBinding {
  GlobeCandidateKind get candidate;
  String get displayName;

  GlobeEngineAdapter createAdapter({
    required GlobeFixture fixture,
    required GlobePocController controller,
  });
}

abstract class GlobeEngineAdapter {
  GlobeCandidateKind get candidate;
  String get displayName;
  ValueListenable<GlobeProbeResult> get probeResult;

  Widget buildRenderer(BuildContext context);
  Future<void> initialize();
  Future<Uint8List?> captureFrame();
  Future<void> dispose();
}
