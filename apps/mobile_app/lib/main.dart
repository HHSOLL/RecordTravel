import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core_data/core_data.dart';
import 'app/app_preferences.dart';
import 'auth/preview_auth_screen.dart';
import 'bootstrap/mobile_app_bootstrap.dart';
import 'bootstrap/mobile_app_runtime_loader.dart';
import 'bootstrap/mobile_app_runtime.dart';
import 'shell/mobile_app_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TravelAtlasRuntimeApp());
}

class TravelAtlasRuntimeApp extends StatefulWidget {
  const TravelAtlasRuntimeApp({super.key});

  @override
  State<TravelAtlasRuntimeApp> createState() => _TravelAtlasRuntimeAppState();
}

class _TravelAtlasRuntimeAppState extends State<TravelAtlasRuntimeApp> {
  MobileAppRuntime? _runtime;
  Object? _runtimeError;
  bool _startedLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _startRuntimeLoad();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_runtime != null) {
      return MobileAppBootstrap(
        runtime: _runtime!,
        child: const TravelAtlasApp(),
      );
    }

    return MaterialApp(
      title: 'record',
      debugShowCheckedModeBanner: false,
      theme: AtlasTheme.buildTheme(),
      home: AtlasBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: Column(
              children: [
                const Spacer(),
                const AtlasHeroPanel(
                  eyebrow: 'record',
                  title:
                      'Preparing your local archive so the app can open cleanly.',
                  message:
                      'The app paints first, then hydrates local state and sync capabilities in the background.',
                  trailing: AtlasOrbitalGraphic(size: 96),
                ),
                const SizedBox(height: 24),
                const CircularProgressIndicator(),
                if (_runtimeError != null) ...[
                  const SizedBox(height: 16),
                  const AtlasStatusPill(
                    label: 'Fallback runtime active',
                    color: Color(0xFFFFD37A),
                    icon: Icons.storage_rounded,
                  ),
                ] else if (_startedLoading) ...[
                  const SizedBox(height: 16),
                  const AtlasStatusPill(
                    label: 'Loading local atlas',
                    color: Color(0xFF8DEBFF),
                    icon: Icons.sync_rounded,
                  ),
                ],
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _startRuntimeLoad() async {
    if (_startedLoading) return;
    setState(() => _startedLoading = true);
    try {
      final runtime = await loadMobileAppRuntime();
      if (!mounted) return;
      setState(() => _runtime = runtime);
    } catch (error) {
      if (!mounted) return;
      setState(() => _runtimeError = error);
    }
  }
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
      themeMode: prefs.themeMode,
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
