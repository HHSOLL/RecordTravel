import 'package:flutter_test/flutter_test.dart';

import 'package:candidate_c_low_level/candidate_c_engine.dart';

void main() {
  test('binding metadata is exposed', () {
    const name = 'Candidate C · low-level GL custom';
    expect(CandidateCLowLevelBinding().displayName, name);
  });
}
