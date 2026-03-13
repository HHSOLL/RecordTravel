import 'package:flutter_test/flutter_test.dart';

import 'package:candidate_b_three_dart/candidate_b_engine.dart';

void main() {
  test('binding metadata is exposed', () {
    const name = 'Candidate B · Dart-native Three port';
    expect(CandidateBEngineBinding().displayName, name);
  });
}
