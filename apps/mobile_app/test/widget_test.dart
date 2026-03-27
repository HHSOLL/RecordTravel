import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/bootstrap/mobile_app_bootstrap.dart';
import 'package:mobile_app/main.dart';
import 'package:feature_record/src/globe/presentation/widgets/record_globe_viewport.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/test_mobile_app_runtime.dart';

void main() {
  testWidgets('app renders shipped atlas home', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final runtime = buildTestMobileAppRuntime();
    await tester.pumpWidget(
      MobileAppBootstrap(runtime: runtime, child: const TravelAtlasApp()),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    expect(find.byType(RecordGlobeViewport), findsOneWidget);
    expect(find.text('record'), findsWidgets);
    expect(find.byIcon(Icons.add_rounded), findsOneWidget);
  });

  testWidgets('app surfaces startup fallback warning banner', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final runtime = buildTestMobileAppRuntime(
      startupWarningMessage: 'fallback',
    );

    await tester.pumpWidget(
      MobileAppBootstrap(runtime: runtime, child: const TravelAtlasApp()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    expect(find.textContaining('로컬 임시 모드'), findsOneWidget);
  });
}
