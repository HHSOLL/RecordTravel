import 'package:flutter/widgets.dart';
import 'package:globe_poc_core/globe_poc_core.dart';

import 'candidate_b_engine.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(GlobePocRunnerApp(binding: CandidateBEngineBinding()));
}
