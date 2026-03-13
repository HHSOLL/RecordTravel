import 'package:core_ui/core_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('theme builds', () {
    expect(AtlasTheme.buildTheme().useMaterial3, isTrue);
  });
}
