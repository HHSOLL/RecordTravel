import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core_data/core_data.dart';
import 'app/app_preferences.dart';
import 'auth/preview_auth_screen.dart';
import 'bootstrap/mobile_app_bootstrap.dart';
import 'bootstrap/mobile_app_runtime_loader.dart';
import 'shell/mobile_app_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final runtime = await loadMobileAppRuntime();
  runApp(
    MobileAppBootstrap(runtime: runtime, child: const TravelAtlasApp()),
  );
}

class TravelAtlasApp extends ConsumerWidget {
  const TravelAtlasApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(appPreferencesProvider);
    final session = ref.watch(sessionSnapshotProvider);

    return MaterialApp(
      title: 'record',
      debugShowCheckedModeBanner: false,
      theme: AtlasTheme.buildTheme(brightness: Brightness.light),
      darkTheme: AtlasTheme.buildTheme(brightness: Brightness.dark),
      themeMode: prefs.effectiveThemeMode,
      locale: prefs.locale,
      supportedLocales: const [Locale('ko'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: session.isSignedIn
          ? const MobileAppShell()
          : const PreviewAuthScreen(),
    );
  }
}
