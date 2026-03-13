import 'package:core_navigation/core_navigation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('app tabs stay stable', () {
    expect(AppTab.values.length, 4);
    expect(AppTab.home.label, 'Home');
  });
}
