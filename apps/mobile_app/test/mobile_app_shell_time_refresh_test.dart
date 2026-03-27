import 'package:feature_record/feature_record.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/bootstrap/mobile_app_bootstrap.dart';
import 'package:mobile_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/test_mobile_app_runtime.dart';

void main() {
  testWidgets('record time state refreshes on lifecycle resume', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final runtime = buildTestMobileAppRuntime();

    await tester.pumpWidget(
      MobileAppBootstrap(runtime: runtime, child: const TravelAtlasApp()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final container = ProviderScope.containerOf(
      tester.element(find.byType(TravelAtlasApp)),
    );
    final initialTime = DateTime(2026, 1, 1);
    container.read(recordCurrentTimeProvider.notifier).state = initialTime;

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    final refreshed = container.read(recordCurrentTimeProvider);
    expect(refreshed.isAfter(initialTime), isTrue);
  });
}
