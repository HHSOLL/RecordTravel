import 'package:core_ui/core_ui.dart';
import 'package:feature_record/feature_record.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:core_data/core_data.dart';
import 'app/app_preferences.dart';
import 'auth/preview_auth_screen.dart';
import 'bootstrap/mobile_app_bootstrap.dart';
import 'bootstrap/mobile_app_runtime_loader.dart';
import 'shell/mobile_app_shell.dart';

const _runtimeChannel = MethodChannel('travel_atlas/runtime_capabilities');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeDateFormatting();
  await _initializeNaverMapIfConfigured();
  final runtime = await loadMobileAppRuntime();
  runApp(MobileAppBootstrap(runtime: runtime, child: const TravelAtlasApp()));
}

Future<void> _initializeDateFormatting() async {
  await Future.wait([
    initializeDateFormatting('ko'),
    initializeDateFormatting('en'),
  ]);
}

Future<void> _initializeNaverMapIfConfigured() async {
  if (kIsWeb) {
    return;
  }

  switch (defaultTargetPlatform) {
    case TargetPlatform.iOS:
    case TargetPlatform.android:
      try {
        final payload = await _runtimeChannel
            .invokeMapMethod<Object?, Object?>('getMapConfig')
            .timeout(const Duration(seconds: 2));
        final rawClientId = payload?['naverMapClientId'] as String?;
        final clientId = _normalizeRuntimeString(rawClientId);
        if (clientId == null) {
          return;
        }
        await FlutterNaverMap().init(
          clientId: clientId,
          onAuthFailed: (error) {
            debugPrint('record: Naver Map auth failed: $error');
          },
        );
        debugPrint('record: Naver Map init success');
      } catch (error) {
        debugPrint('record: Naver Map init skipped: $error');
      }
    case TargetPlatform.macOS:
    case TargetPlatform.windows:
    case TargetPlatform.linux:
    case TargetPlatform.fuchsia:
      return;
  }
}

String? _normalizeRuntimeString(String? value) {
  if (value == null) {
    return null;
  }
  final trimmed = value.trim();
  if (trimmed.isEmpty || trimmed.startsWith(r'$(')) {
    return null;
  }
  return trimmed;
}

class TravelAtlasApp extends ConsumerWidget {
  const TravelAtlasApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(appPreferencesProvider);
    final session = ref.watch(sessionSnapshotProvider);
    final startupWarning = ref.watch(
      mobileAppRuntimeProvider.select(
        (runtime) => runtime.startupWarningMessage,
      ),
    );

    return MaterialApp(
      title: 'record',
      debugShowCheckedModeBanner: false,
      navigatorObservers: [RecordGlobeViewport.navigatorObserver],
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
      builder: (context, child) {
        if (child == null || startupWarning == null) {
          return child ?? const SizedBox.shrink();
        }
        return Stack(
          children: [
            child,
            _RuntimeStartupBanner(
              locale: prefs.locale,
              message: startupWarning,
            ),
          ],
        );
      },
      home: session.isSignedIn
          ? const MobileAppShell()
          : const PreviewAuthScreen(),
    );
  }
}

class _RuntimeStartupBanner extends StatelessWidget {
  const _RuntimeStartupBanner({required this.locale, required this.message});

  final Locale locale;
  final String message;

  @override
  Widget build(BuildContext context) {
    final isKorean = locale.languageCode == 'ko';
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Align(
        alignment: Alignment.topCenter,
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 680),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF7C2D12).withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isKorean
                        ? '시작 복구 모드: 로컬 임시 모드로 실행되었습니다. 일부 변경사항은 동기화되지 않을 수 있습니다.'
                        : message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
