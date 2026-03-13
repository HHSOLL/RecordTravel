import 'package:flutter_test/flutter_test.dart';

import 'package:candidate_a_three_js/candidate_a_engine.dart';

void main() {
  test('binding metadata is exposed', () {
    const name = 'Candidate A · three_js';
    expect(CandidateAEngineBinding().displayName, name);
  });
}
