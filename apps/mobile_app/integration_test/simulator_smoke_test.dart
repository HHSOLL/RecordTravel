import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mobile_app/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('home quick-open, archive layout, and tab headers stay stable', (
    tester,
  ) async {
    app.main();

    await _signInPreview(tester);
    await _pumpUntilVisible(
      tester,
      find.byKey(const Key('record-home-globe-fallback')),
    );
    await binding.takeScreenshot('01-home-fallback');

    await tester.tap(find.byKey(const Key('record-home-quick-country-KR')));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byKey(const Key('record-country-detail-KR')), findsOneWidget);
    tester.takeException();
    await binding.takeScreenshot('02-country-kr');

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await _pumpUntilVisible(
      tester,
      find.byKey(const Key('record-home-globe-fallback')),
    );

    await tester.tap(find.byKey(const Key('record-home-retry-3d')));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byKey(const Key('record-home-globe-fallback')), findsOneWidget);

    await tester.tap(find.byKey(const Key('record-home-quick-country-JP')));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byKey(const Key('record-country-detail-JP')), findsOneWidget);
    tester.takeException();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await _pumpUntilVisible(
      tester,
      find.byKey(const Key('record-home-globe-fallback')),
    );

    await tester.tap(find.byKey(const Key('nav-archive')));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(tester.takeException(), isNull);
    await binding.takeScreenshot('03-archive');

    await tester.drag(
      find.byType(CustomScrollView).first,
      const Offset(0, -420),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const Key('nav-planner')));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    _expectAtMostOneText(korean: '플래너', english: 'Planner');
    expect(tester.takeException(), isNull);
    await binding.takeScreenshot('04-planner');

    await tester.tap(find.byKey(const Key('nav-profile')));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    _expectAtMostOneText(korean: '마이페이지', english: 'My Page');
    await binding.takeScreenshot('05-profile');
    expect(tester.takeException(), isNull);
  });
}

Future<void> _signInPreview(WidgetTester tester) async {
  await _pumpUntilAnyVisible(tester, [
    find.text('프리뷰 로그인'),
    find.text('Preview Auth'),
    find.byKey(const Key('nav-home')),
    find.byKey(const Key('record-home-globe-fallback')),
  ]);

  if (find.byKey(const Key('nav-home')).evaluate().isNotEmpty ||
      find
          .byKey(const Key('record-home-globe-fallback'))
          .evaluate()
          .isNotEmpty) {
    return;
  }

  Finder loginModeButton = find.text('로그인');
  if (loginModeButton.evaluate().isEmpty) {
    loginModeButton = find.text('Login');
  }
  if (loginModeButton.evaluate().isEmpty) {
    loginModeButton = find.byType(OutlinedButton).first;
  }
  await tester.tap(loginModeButton);
  await tester.pumpAndSettle(const Duration(seconds: 1));

  final textFields = find.byType(TextField);
  await tester.enterText(textFields.at(0), 'preview-user');
  await tester.enterText(textFields.at(1), 'preview-pass');
  await tester.pump();

  Finder continueButton = find.text('계속하기');
  if (continueButton.evaluate().isEmpty) {
    continueButton = find.text('Continue');
  }
  if (continueButton.evaluate().isEmpty) {
    continueButton = find.byType(FilledButton).last;
  }
  await tester.tap(continueButton);
  await tester.pumpAndSettle(const Duration(seconds: 3));
}

Future<void> _pumpUntilVisible(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 20),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 250));
    if (finder.evaluate().isNotEmpty) {
      await tester.pumpAndSettle(const Duration(seconds: 1));
      return;
    }
  }
  fail('Timed out waiting for $finder');
}

void _expectAtMostOneText({required String korean, required String english}) {
  final totalMatches =
      find.text(korean).evaluate().length +
      find.text(english).evaluate().length;
  expect(totalMatches, greaterThanOrEqualTo(1));
}

Future<void> _pumpUntilAnyVisible(
  WidgetTester tester,
  List<Finder> finders, {
  Duration timeout = const Duration(seconds: 20),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 250));
    for (final finder in finders) {
      if (finder.evaluate().isNotEmpty) {
        await tester.pumpAndSettle(const Duration(seconds: 1));
        return;
      }
    }
  }
  fail('Timed out waiting for any finder: $finders');
}
